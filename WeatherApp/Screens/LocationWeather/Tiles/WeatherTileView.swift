import UIKit
import WeatherCore

final class WeatherTileView: UIView {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        clipsToBounds = true

        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .secondaryLabel

        valueLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        valueLabel.adjustsFontForContentSizeCategory = true

        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0

        [titleLabel, valueLabel, subtitleLabel].forEach { addSubview($0) }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let padding: CGFloat = 16
        let width = bounds.width - padding * 2

        titleLabel.frame = CGRect(x: padding, y: padding, width: width, height: 22)
        valueLabel.frame = CGRect(x: padding, y: titleLabel.frame.maxY + 8, width: width, height: 28)

        let subtitleHeight = subtitleLabel.text?.isEmpty == false ? 20.0 : 0.0
        subtitleLabel.frame = CGRect(
            x: padding,
            y: bounds.height - padding - subtitleHeight,
            width: width,
            height: subtitleHeight
        )
    }

    func configure(with item: TileDisplayItem) {
        titleLabel.text = item.title
        valueLabel.text = item.value
        subtitleLabel.text = item.subtitle
        setNeedsLayout()
    }
}
