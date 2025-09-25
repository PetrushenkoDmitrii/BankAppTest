import UIKit
import MapKit

final class MainViewController: BaseViewController {
    private let mainView = MainView()
    private let locationProvider = LocationProvider()
    private let places = PlacesService()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        loadRates()
        loadNearbyBranches()
        mainView.mapCardView.delegate = self
    }

    private func setupLayout() {
        view.addSubview(mainView)
        mainView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadRates() {
        RatesProvider.shared.loadTopRates { [weak self] rates, usdUnit in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.mainView.ratesView.update(rates: rates)
                if let usdUnit { self.updateConverterPreview(usdUnit: usdUnit) }
            }
        }
    }

    private func updateConverterPreview(usdUnit: Double) {
        let byn = Currency(code: "BYN", name: "Белорусский рубль", symbol: "Br", flag: "🇧🇾")
        let usd = Currency(code: "USD", name: "Доллар США",        symbol: "$",  flag: "🇺🇸")
        let bynToUsd = 1.0 / usdUnit
        let ex = ExchangeRate(base: byn, quote: usd, rate: Decimal(bynToUsd), updatedAt: Date())
        mainView.converterPreview.model = ConverterPreviewModel(amountBase: 0, rate: ex)
    }

    private func loadNearbyBranches() {
        locationProvider.requestOnce { [weak self] res in
            guard let self = self else { return }

            func apply(_ places: [NearbyPlace]) {
                DispatchQueue.main.async { self.mainView.mapCardView.update(places: places) }
            }

            switch res {
            case .failure:
                apply([])
            case .success(let location):
                self.places.searchBanks(around: location) { result in
                    apply((try? result.get()) ?? [])
                }
            }
        }
    }
}

extension MainViewController: MapCardViewDelegate {
    func mapCardViewDidSelect(place: NearbyPlace) {
        tabBarController?.selectedIndex = 1
        let req = RouteRequest(place: place)
        NotificationCenter.default.post(name: .openRouteRequest, object: req)
    }
}
