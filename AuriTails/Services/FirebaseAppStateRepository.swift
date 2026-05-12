import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Foundation

struct CloudAppStateSnapshot {
    let state: PersistedAppState
    let updatedAt: Date
}

enum FirebaseAppStateSyncError: LocalizedError {
    case missingConfiguration
    case signedOut
    case encodingFailed

    var errorDescription: String? {
        switch self {
        case .missingConfiguration:
            return "Firebase is not configured for app data sync yet."
        case .signedOut:
            return "Sign in before syncing AuriTails data to Firebase."
        case .encodingFailed:
            return "AuriTails could not prepare the app data for cloud sync."
        }
    }
}

final class FirebaseAppStateRepository {
    private let database: Firestore?
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init() {
        database = FirebaseApp.app() != nil ? Firestore.firestore() : nil

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    var isReadyForLiveSync: Bool {
        database != nil && Auth.auth().currentUser != nil
    }

    func fetchSnapshot() async throws -> CloudAppStateSnapshot? {
        let document = try appStateDocument()
        let snapshot = try await document.getDocument()
        guard let data = snapshot.data(),
              let payload = data["payload"] as? String,
              let payloadData = Data(base64Encoded: payload)
        else {
            return nil
        }

        let state = try decoder.decode(PersistedAppState.self, from: payloadData)
            .normalizedForMultiPet()
        let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue() ?? .distantPast
        return CloudAppStateSnapshot(state: state, updatedAt: updatedAt)
    }

    func save(_ state: PersistedAppState) async throws {
        let document = try appStateDocument()
        let cloudState = state.cloudSyncCopy()
        let payloadData = try encoder.encode(cloudState)
        let payload = payloadData.base64EncodedString()
        guard !payload.isEmpty else {
            throw FirebaseAppStateSyncError.encodingFailed
        }

        try await document.setData([
            "payload": payload,
            "format": "persisted_app_state_v1",
            "mediaPolicy": "metadata_only",
            "petCount": cloudState.pets.count,
            "routineCount": cloudState.routines.count,
            "memoryCount": cloudState.memories.count,
            "medicationCount": cloudState.medications.count,
            "symptomCount": cloudState.symptoms.count,
            "updatedAt": Timestamp(date: .now)
        ], merge: true)

        FirebaseTelemetry.logEvent("app_state_cloud_saved", parameters: [
            "pet_count": cloudState.pets.count,
            "routine_count": cloudState.routines.count,
            "memory_count": cloudState.memories.count,
            "metadata_only": 1
        ])
    }

    func record(error: Error, context: String) {
        FirebaseTelemetry.record(error: error, context: context)
    }

    private func appStateDocument() throws -> DocumentReference {
        guard let database else { throw FirebaseAppStateSyncError.missingConfiguration }
        guard let userID = Auth.auth().currentUser?.uid else { throw FirebaseAppStateSyncError.signedOut }
        return database.collection("users").document(userID).collection("appState").document("current")
    }
}

private extension PersistedAppState {
    func cloudSyncCopy() -> PersistedAppState {
        var state = self
        state.ownerPhotoData = nil
        state.pets = state.pets.map { pet in
            var pet = pet
            pet.photoData = nil
            pet.bondPhotoData = nil
            return pet
        }
        state.vaccinations = state.vaccinations.map { vaccine in
            var vaccine = vaccine
            vaccine.certificateData = nil
            return vaccine
        }
        state.memories = state.memories.map { memory in
            var memory = memory
            memory.photoData = nil
            return memory
        }
        return state
    }
}
