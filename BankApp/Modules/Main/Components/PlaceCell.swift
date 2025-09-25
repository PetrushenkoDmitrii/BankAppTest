//
//  PlaceCell.swift
//  BankApp
//
//  Created by Дмитрий Петрушенко on 16/09/2025.
//

import UIKit

final class PlaceCell: UITableViewCell {

    private let bubble = UIView()
    private let dot = UIView()
    private let nameLabel = UILabel()
    private let statusLabel = UILabel()
    private let distanceLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        bubble.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        bubble.layer.cornerRadius = 16

        dot.backgroundColor = .systemOrange
        dot.layer.cornerRadius = 6
        dot.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dot.widthAnchor.constraint(equalToConstant: 12),
            dot.heightAnchor.constraint(equalToConstant: 12)
        ])

        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .white

        statusLabel.font = .systemFont(ofSize: 14, weight: .regular)
        statusLabel.textColor = UIColor.white.withAlphaComponent(0.8)

        distanceLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        distanceLabel.textColor = .white
        distanceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        subtitleLabel.numberOfLines = 2

        contentView.addSubview(bubble)
        bubble.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            bubble.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            bubble.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bubble.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

        let topRow = UIStackView(arrangedSubviews: [dot, nameLabel, UIView(), statusLabel, distanceLabel])
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.spacing = 8

        let vStack = UIStackView(arrangedSubviews: [topRow, subtitleLabel])
        vStack.axis = .vertical
        vStack.alignment = .fill
        vStack.spacing = 6

        bubble.addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 12),
            vStack.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 12),
            vStack.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -12),
            vStack.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(name: String, subtitle: String, statusText: String?, distance: String) {
        nameLabel.text = name
        subtitleLabel.text = subtitle
        distanceLabel.text = distance

        if let text = statusText, !text.isEmpty {
            statusLabel.isHidden = false
            statusLabel.text = text
        } else {
            statusLabel.isHidden = true
            statusLabel.text = nil
        }
    }
}
