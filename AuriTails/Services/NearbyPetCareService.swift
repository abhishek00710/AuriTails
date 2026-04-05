import Combine
import CoreLocation
import Foundation
import MapKit

struct PetCarePlace: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let phoneNumber: String?
    let mapItem: MKMapItem
    let distanceMeters: CLLocationDistance
    let distanceText: String
}

@MainActor
final class NearbyPetCareService: NSObject, CLLocationManagerDelegate {
    @Published private(set) var places: [PetCarePlace] = []
    @Published private(set) var isLoading = false
    @Published private(set) var statusMessage = L10n.tr(
        "Find nearby pet hospitals and emergency care around you.",
        default: "Find nearby pet hospitals and emergency care around you."
    )

    private let locationManager: CLLocationManager
    private var hasRequestedAuthorization = false

    init(locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func refresh() {
        Task {
            let servicesEnabled = await Self.locationServicesEnabled()
            applyRefresh(locationServicesEnabled: servicesEnabled)
        }
    }

    private func applyRefresh(locationServicesEnabled: Bool) {
        guard locationServicesEnabled else {
            places = []
            isLoading = false
            statusMessage = L10n.tr(
                "Location Services are off. Turn them on to find nearby pet hospitals.",
                default: "Location Services are off. Turn them on to find nearby pet hospitals."
            )
            return
        }

        let status = locationManager.authorizationStatus
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            requestNearbySearch()
        case .notDetermined:
            places = []
            isLoading = false
            statusMessage = L10n.tr(
                "Allow location access to find nearby pet hospitals and emergency care.",
                default: "Allow location access to find nearby pet hospitals and emergency care."
            )
            guard !hasRequestedAuthorization else { return }
            hasRequestedAuthorization = true
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            places = []
            isLoading = false
            statusMessage = L10n.tr(
                "Location access is unavailable. You can enable it in Settings to search nearby care.",
                default: "Location access is unavailable. You can enable it in Settings to search nearby care."
            )
        @unknown default:
            places = []
            isLoading = false
            statusMessage = L10n.tr(
                "Nearby pet hospital search is temporarily unavailable.",
                default: "Nearby pet hospital search is temporarily unavailable."
            )
        }
    }

    nonisolated private static func locationServicesEnabled() async -> Bool {
        await Task.detached(priority: .userInitiated) {
            CLLocationManager.locationServicesEnabled()
        }.value
    }

    private func requestNearbySearch() {
        if let location = locationManager.location {
            Task {
                await search(near: location.coordinate)
            }
            return
        }

        isLoading = true
        statusMessage = L10n.tr(
            "Finding nearby pet hospitals…",
            default: "Finding nearby pet hospitals…"
        )
        locationManager.requestLocation()
    }

    private func search(near coordinate: CLLocationCoordinate2D) async {
        isLoading = true
        statusMessage = L10n.tr(
            "Finding nearby pet hospitals…",
            default: "Finding nearby pet hospitals…"
        )

        do {
            let origin = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            async let hospitals = searchResults(query: "veterinary hospital", near: coordinate, origin: origin)
            async let emergency = searchResults(query: "emergency vet", near: coordinate, origin: origin)
            let searches = try await [hospitals, emergency]

            var deduped: [String: PetCarePlace] = [:]
            for result in searches.flatMap({ $0 }) {
                let key = "\(result.name.lowercased())|\(result.address.lowercased())"
                deduped[key] = result
            }

            let sorted = deduped.values.sorted { lhs, rhs in
                lhs.distanceMeters < rhs.distanceMeters
            }

            places = Array(sorted.prefix(6))
            isLoading = false

            if places.isEmpty {
                statusMessage = L10n.tr(
                    "No nearby pet hospitals showed up just now. Try again in a moment or move the map area.",
                    default: "No nearby pet hospitals showed up just now. Try again in a moment or move the map area."
                )
            } else {
                statusMessage = L10n.tr(
                    "Nearby pet hospitals ready",
                    default: "Nearby pet hospitals ready"
                )
            }
        } catch {
            places = []
            isLoading = false
            statusMessage = L10n.tr(
                "Nearby pet hospitals couldn't be loaded right now.",
                default: "Nearby pet hospitals couldn't be loaded right now."
            )
        }
    }

    private func searchResults(
        query: String,
        near coordinate: CLLocationCoordinate2D,
        origin: CLLocation
    ) async throws -> [PetCarePlace] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 30_000,
            longitudinalMeters: 30_000
        )

        let response = try await MKLocalSearch(request: request).start()
        return response.mapItems.compactMap { item in
            guard let location = item.placemark.location else { return nil }
            let distance = location.distance(from: origin)
            return PetCarePlace(
                name: item.name ?? L10n.tr("Pet care", default: "Pet care"),
                address: formattedAddress(for: item.placemark),
                phoneNumber: item.phoneNumber,
                mapItem: item,
                distanceMeters: distance,
                distanceText: Measurement(value: distance / 1000, unit: UnitLength.kilometers)
                    .formatted(.measurement(width: .abbreviated, usage: .road))
            )
        }
    }

    private func formattedAddress(for placemark: MKPlacemark) -> String {
        let parts = [
            placemark.subThoroughfare,
            placemark.thoroughfare,
            placemark.locality,
            placemark.administrativeArea,
        ]
        .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }

        if parts.isEmpty {
            return placemark.title ?? L10n.tr("Address unavailable", default: "Address unavailable")
        }

        return parts.joined(separator: ", ")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        refresh()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else {
            isLoading = false
            return
        }

        Task {
            await search(near: coordinate)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoading = false
        statusMessage = L10n.tr(
            "Nearby pet hospitals couldn't be loaded right now.",
            default: "Nearby pet hospitals couldn't be loaded right now."
        )
    }
}
