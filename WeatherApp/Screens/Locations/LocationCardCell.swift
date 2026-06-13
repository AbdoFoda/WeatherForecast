import UIKit

final class LocationCardCell: UITableViewCell {
    static let reuseIdentifier = "LocationCardCell"

    private let shadowContainer = UIView()
    private let card = LocationCardView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.backgroundColor = .clear

        shadowContainer.translatesAutoresizingMaskIntoConstraints = false
        shadowContainer.backgroundColor = .clear
        shadowContainer.layer.cornerRadius = Metrics.cornerRadius
        shadowContainer.layer.cornerCurve = .continuous
        shadowContainer.layer.shadowColor = UIColor.black.cgColor
        shadowContainer.layer.shadowOpacity = 0.14
        shadowContainer.layer.shadowRadius = 10
        shadowContainer.layer.shadowOffset = CGSize(width: 0, height: 4)

        card.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(shadowContainer)
        shadowContainer.addSubview(card)

        NSLayoutConstraint.activate([
            shadowContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.verticalInset),
            shadowContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metrics.verticalInset),
            shadowContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            shadowContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            card.topAnchor.constraint(equalTo: shadowContainer.topAnchor),
            card.bottomAnchor.constraint(equalTo: shadowContainer.bottomAnchor),
            card.leadingAnchor.constraint(equalTo: shadowContainer.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: shadowContainer.trailingAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with model: LocationCardView.Model) {
        card.configure(with: model)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        let transform: CGAffineTransform = highlighted
            ? CGAffineTransform(scaleX: 0.97, y: 0.97)
            : .identity
        let shadowOpacity: Float = highlighted ? 0.08 : 0.14
        UIView.animate(
            withDuration: highlighted ? 0.12 : 0.28,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            self.shadowContainer.transform = transform
            self.shadowContainer.layer.shadowOpacity = shadowOpacity
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        shadowContainer.layer.shadowPath = UIBezierPath(
            roundedRect: shadowContainer.bounds,
            cornerRadius: Metrics.cornerRadius
        ).cgPath
    }

    private enum Metrics {
        static let cornerRadius: CGFloat = 22
        static let verticalInset: CGFloat = 6
    }
}
