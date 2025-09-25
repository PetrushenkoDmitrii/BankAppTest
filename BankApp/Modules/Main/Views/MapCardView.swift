import UIKit

protocol MapCardViewDelegate: AnyObject {
    func mapCardViewDidSelect(place: NearbyPlace)
}

final class MapCardView: UIView, UITableViewDataSource, UITableViewDelegate {

    weak var delegate: MapCardViewDelegate?

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Ближайшие отделения"
        l.font = .systemFont(ofSize: 18, weight: .semibold)
        l.textColor = .white
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Используется ваше местоположение"
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor.white.withAlphaComponent(0.7)
        return l
    }()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.showsVerticalScrollIndicator = false
        tv.isScrollEnabled = false
        return tv
    }()

    private var tableHeight: NSLayoutConstraint!
    private var data: [NearbyPlace] = []
    private static let rowHeight: CGFloat = 76

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white.withAlphaComponent(0.10)
        layer.cornerRadius = 16

        let header = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        header.axis = .vertical
        header.alignment = .leading
        header.spacing = 4

        let stack = UIStackView(arrangedSubviews: [header, tableView])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 14

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PlaceCell.self, forCellReuseIdentifier: "PlaceCell")

        tableHeight = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableHeight.isActive = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func update(places: [NearbyPlace]) {
        data = places
        tableView.reloadData()
        tableHeight.constant = CGFloat(data.count) * Self.rowHeight
        layoutIfNeeded()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { data.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as! PlaceCell
        let p = data[indexPath.row]
        cell.configure(name: p.name,
                       subtitle: p.address,
                       statusText: nil,
                       distance: DistanceFormatter.string(p.distance))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.mapCardViewDidSelect(place: data[indexPath.row])
    }
}
