import Foundation
import MapKit
import CoreLocation

struct NearbyPlace: Hashable {
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let distance: CLLocationDistance

    static func == (lhs: NearbyPlace, rhs: NearbyPlace) -> Bool {
        lhs.name == rhs.name
        && lhs.coordinate.latitude  == rhs.coordinate.latitude
        && lhs.coordinate.longitude == rhs.coordinate.longitude
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
    }
}

final class PlacesService {
    func searchBanks(around center: CLLocation, limit: Int = 7, completion: @escaping (Result<[NearbyPlace], Error>) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "bank"
        request.resultTypes = .pointOfInterest
        request.region = MKCoordinateRegion(center: center.coordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08))

        MKLocalSearch(request: request).start { response, error in
            if let error = error { completion(.failure(error)); return }
            guard let response = response else { completion(.success([])); return }

            let places: [NearbyPlace] = response.mapItems.compactMap { item in
                let coord = item.placemark.coordinate
                let distance = center.distance(from: CLLocation(latitude: coord.latitude, longitude: coord.longitude))
                
                var addressParts: [String] = []
                if let street = item.placemark.thoroughfare {
                    var streetLine = street
                    if let house = item.placemark.subThoroughfare {
                        streetLine += " \(house)"
                    }
                    addressParts.append(streetLine)
                }
                if let locality = item.placemark.locality {
                    addressParts.append(locality)
                }
                let address = addressParts.joined(separator: ", ")

                return NearbyPlace(
                    name: item.name ?? "Отделение",
                    address: address.isEmpty ? (item.placemark.title ?? "—") : address,
                    coordinate: coord,
                    distance: distance
                )
            }
            .sorted { $0.distance < $1.distance }
            .prefix(limit) 
            .map { $0 }

            completion(.success(places))
        }
    }
}

enum DistanceFormatter {
    static func string(_ meters: CLLocationDistance) -> String {
        let km = meters / 1000
        return String(format: "%.1f км", km)
    }
}
