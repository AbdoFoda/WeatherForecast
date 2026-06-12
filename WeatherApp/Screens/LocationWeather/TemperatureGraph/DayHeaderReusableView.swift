import UIKit

final class DayHeaderReusableView: UICollectionReusableView {
    static let reuseIdentifier = "DayHeaderReusableView"

    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        layer.cornerRadius = WeatherDesignSystem.Graph.DayHeader.cornerRadius
        layer.borderWidth = WeatherDesignSystem.Graph.DayHeader.borderWidth
        layer.borderColor = UIColor.separator.cgColor
        clipsToBounds = true

        label.font = WeatherDesignSystem.Typography.preferred(.footnote)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        addSubview(label)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds.insetBy(
            dx: WeatherDesignSystem.Graph.DayHeader.horizontalInset,
            dy: WeatherDesignSystem.Graph.DayHeader.verticalInset
        )
    }

    func configure(with text: String) {
        label.text = text
    }
}
