
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import Foundation

struct CareCircleCloudSnapshot {
    let members: [CareCircleMember]
    let events: [CareActivityEvent]
}

enum FirebaseCareCircleError: LocalizedError {
    case missingConfiguration
    case signedOut
    case missingPet

    var errorDescription: String? {
        switch self {
        case .missingConfiguration:
            return "Firebase is not configured for Care Circle yet."
        case .signedOut:
            return "Sign in to Firebase before using live Care Circle sharing."
        case .missingPet:
            return "Select a pet before syncing Care Circle data."
        }
    }
}

final class FirebaseCareCircleRepository {
    private let database: Firestore?
    private let storage: Storage?

    init() {
        database = FirebaseApp.app() != nil ? Firestore.firestore() : nil
        storage = FirebaseApp.app() != nil ? Storage.storage() : nil
    }

    var isConfigured: Bool {
        database != nil
    }

    var isReadyForLiveSync: Bool {
        isConfigured && Auth.auth().currentUser != nil
    }

    func fetchSnapshot(for petID: UUID?) async throws -> CareCircleCloudSnapshot? {
        let petReference = try petReference(for: petID)
        let membersSnapshot = try await petReference.collection("careCircleMembers").getDocuments()
        let eventsSnapshot = try await petReference.collection("careCircleEvents")
            .order(by: "createdAt", descending: true)
            .limit(to: 12)
            .getDocuments()

        let members = membersSnapshot.documents.compactMap(CareCircleMember.init(document:))
        let events = eventsSnapshot.documents.compactMap(CareActivityEvent.init(document:))

        if members.isEmpty && events.isEmpty {
            return nil
        }

        return CareCircleCloudSnapshot(members: members, events: events)
    }

    func replaceSnapshot(members: [CareCircleMember], events: [CareActivityEvent], pet: PetProfile) async throws {
        let petReference = try petReference(for: pet.id)
        let ownerID = try currentUserID()

        try await petReference.setData([
            "petID": pet.id.uuidString,
            "petName": pet.name,
            "ownerID": ownerID,
            "updatedAt": Timestamp(date: .now)
        ], merge: true)

        try await clearCollection(petReference.collection("careCircleMembers"))
        try await clearCollection(petReference.collection("careCircleEvents"))

        for member in members {
            try await petReference.collection("careCircleMembers")
                .document(member.id.uuidString)
                .setData(member.firestoreData)
        }

        for event in events.prefix(12) {
            try await petReference.collection("careCircleEvents")
                .document(event.id.uuidString)
                .setData(event.firestoreData)
        }

        FirebaseTelemetry.logEvent("care_circle_snapshot_replaced", parameters: [
            "member_count": members.count,
            "event_count": events.count
        ])
    }

    func createInvite(member: CareCircleMember, pet: PetProfile) async throws {
        let petReference = try petReference(for: pet.id)
        try await petReference.collection("careCircleMembers")
            .document(member.id.uuidString)
            .setData(member.firestoreData)

        FirebaseTelemetry.logEvent("care_circle_invite_created", parameters: [
            "has_contact": member.contact.isEmpty ? 0 : 1
        ])
    }

    func updateMemberStatus(_ member: CareCircleMember, pet: PetProfile) async throws {
        let petReference = try petReference(for: pet.id)
        try await petReference.collection("careCircleMembers")
            .document(member.id.uuidString)
            .setData(member.firestoreData, merge: true)

        FirebaseTelemetry.logEvent("care_circle_member_updated", parameters: [
            "status": member.status.rawValue
        ])
    }

    func removeMember(memberID: UUID, pet: PetProfile) async throws {
        let petReference = try petReference(for: pet.id)
        try await petReference.collection("careCircleMembers")
            .document(memberID.uuidString)
            .delete()

        FirebaseTelemetry.logEvent("care_circle_member_removed")
    }

    func appendActivity(_ event: CareActivityEvent, pet: PetProfile) async throws {
        let petReference = try petReference(for: pet.id)
        try await petReference.collection("careCircleEvents")
            .document(event.id.uuidString)
            .setData(event.firestoreData, merge: true)
    }

    func sharedMediaRootPath(for petID: UUID?) throws -> String {
        guard let petID else { throw FirebaseCareCircleError.missingPet }
        _ = try currentUserID()
        return "care-circle/pets/\(petID.uuidString)"
    }

    func storageReference(for petID: UUID?) throws -> StorageReference {
        guard let storage else { throw FirebaseCareCircleError.missingConfiguration }
        return storage.reference(withPath: try sharedMediaRootPath(for: petID))
    }

    private func clearCollection(_ collection: CollectionReference) async throws {
        let snapshot = try await collection.getDocuments()
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }

    private func petReference(for petID: UUID?) throws -> DocumentReference {
        guard let database else { throw FirebaseCareCircleError.missingConfiguration }
        guard let petID else { throw FirebaseCareCircleError.missingPet }
        _ = try currentUserID()
        return database.collection("pets").document(petID.uuidString)
    }

    private func currentUserID() throws -> String {
        guard isConfigured else { throw FirebaseCareCircleError.missingConfiguration }
        guard let userID = Auth.auth().currentUser?.uid else { throw FirebaseCareCircleError.signedOut }
        return userID
    }

    func record(error: Error, context: String) {
        FirebaseTelemetry.record(error: error, context: context)
    }
}

extension CareCircleMember: Equatable {
    static func == (lhs: CareCircleMember, rhs: CareCircleMember) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.contact == rhs.contact &&
        lhs.relationshipLabel == rhs.relationshipLabel &&
        lhs.role == rhs.role &&
        lhs.status == rhs.status &&
        lhs.note == rhs.note &&
        lhs.invitedAt == rhs.invitedAt
    }
}

extension CareActivityEvent: Equatable {
    static func == (lhs: CareActivityEvent, rhs: CareActivityEvent) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.detail == rhs.detail &&
        lhs.createdAt == rhs.createdAt &&
        lhs.systemImage == rhs.systemImage &&
        lhs.tone == rhs.tone
    }
}

private extension CareCircleMember {
    var firestoreData: [String: Any] {
        [
            "id": id.uuidString,
            "name": name,
            "contact": contact,
            "relationshipLabel": relationshipLabel,
            "role": role.rawValue,
            "status": status.rawValue,
            "note": note,
            "invitedAt": Timestamp(date: invitedAt)
        ]
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard
            let name = data["name"] as? String,
            let roleRaw = data["role"] as? String,
            let role = CareCircleRole(rawValue: roleRaw),
            let statusRaw = data["status"] as? String,
            let status = CareCircleMemberStatus(rawValue: statusRaw)
        else {
            return nil
        }

        self.init(
            id: UUID(uuidString: document.documentID) ?? UUID(),
            name: name,
            contact: data["contact"] as? String ?? "",
            relationshipLabel: data["relationshipLabel"] as? String ?? "",
            role: role,
            status: status,
            note: data["note"] as? String ?? "",
            invitedAt: (data["invitedAt"] as? Timestamp)?.dateValue() ?? .now
        )
    }
}

private extension CareActivityEvent {
    var firestoreData: [String: Any] {
        [
            "id": id.uuidString,
            "title": title,
            "detail": detail,
            "createdAt": Timestamp(date: createdAt),
            "systemImage": systemImage,
            "tone": tone.rawValue
        ]
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard
            let title = data["title"] as? String,
            let detail = data["detail"] as? String,
            let systemImage = data["systemImage"] as? String,
            let toneRaw = data["tone"] as? String,
            let tone = PaletteTone(rawValue: toneRaw)
        else {
            return nil
        }

        self.init(
            id: UUID(uuidString: document.documentID) ?? UUID(),
            title: title,
            detail: detail,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? .now,
            systemImage: systemImage,
            tone: tone
        )
    }
}
