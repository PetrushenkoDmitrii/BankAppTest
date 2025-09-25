import UIKit
import MapKit
import CoreLocation

struct RouteRequest { let place: NearbyPlace }

final class MapViewController: BaseViewController {

    private let mapView = MKMapView()
    private let searchController = UISearchController(searchResultsController: nil)
    private let locationProvider = LocationProvider()
    private let placesService = PlacesService()

    private var userLocation: CLLocation?
    private var currentAnnotations: [MKAnnotation] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Карта"
        setupMap()
        setupSearch()
        requestLocation()
        NotificationCenter.default.addObserver(self, selector: #selector(onOpenRouteRequest(_:)),
                                               name: .openRouteRequest, object: nil)
    }

    private func setupMap() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupSearch() {
        searchController.searchBar.placeholder = "Поиск банков и адресов"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func requestLocation() {
        locationProvider.requestOnce { [weak self] result in
            guard let self else { return }
            if case .success(let loc) = result {
                self.userLocation = loc
                let region = MKCoordinateRegion(center: loc.coordinate,
                                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                DispatchQueue.main.async { self.mapView.setRegion(region, animated: false) }
            }
        }
    }

    private func runSearch(query: String) {
        guard let center = userLocation else { return }
        let req = MKLocalSearch.Request()
        req.naturalLanguageQuery = query
        req.resultTypes = .pointOfInterest
        req.region = MKCoordinateRegion(center: center.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08))
        MKLocalSearch(request: req).start { [weak self] resp, err in
            guard let self, err == nil, let resp else { return }
            self.showSearchResults(resp.mapItems)
        }
    }

    private func showSearchResults(_ items: [MKMapItem]) {
        mapView.removeAnnotations(currentAnnotations)
        currentAnnotations.removeAll()

        let anns: [MKPointAnnotation] = items.map {
            let a = MKPointAnnotation()
            a.title = $0.name
            a.subtitle = [$0.placemark.thoroughfare, $0.placemark.subThoroughfare]
                .compactMap { $0 }.joined(separator: " ")
            a.coordinate = $0.placemark.coordinate
            return a
        }
        currentAnnotations = anns
        mapView.addAnnotations(anns)
        mapView.showAnnotations(anns, animated: true)
    }

    private func buildRoute(to dest: CLLocationCoordinate2D) {
        guard let src = userLocation?.coordinate else { return }
        mapView.removeOverlays(mapView.overlays)

        let req = MKDirections.Request()
        req.source = MKMapItem(placemark: .init(coordinate: src))
        req.destination = MKMapItem(placemark: .init(coordinate: dest))
        req.transportType = .automobile

        MKDirections(request: req).calculate { [weak self] resp, _ in
            guard let self, let route = resp?.routes.first else { return }
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect,
                                           edgePadding: .init(top: 80, left: 40, bottom: 120, right: 40),
                                           animated: true)
        }
    }

    @objc private func onOpenRouteRequest(_ note: Notification) {
        guard let req = note.object as? RouteRequest else { return }
        let ann = MKPointAnnotation()
        ann.title = req.place.name
        ann.subtitle = req.place.address
        ann.coordinate = req.place.coordinate

        mapView.removeAnnotations(currentAnnotations)
        currentAnnotations = [ann]
        mapView.addAnnotation(ann)
        mapView.selectAnnotation(ann, animated: true)
        buildRoute(to: req.place.coordinate)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let r = MKPolylineRenderer(overlay: overlay)
        r.lineWidth = 5
        r.strokeColor = .systemBlue
        return r
    }
}

extension MapViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let q = (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !q.isEmpty { runSearch(query: q) }
    }
}

extension Notification.Name { static let openRouteRequest = Notification.Name("openRouteRequest") }
