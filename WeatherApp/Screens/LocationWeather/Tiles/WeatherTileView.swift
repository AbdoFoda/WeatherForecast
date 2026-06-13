import UIKit
import WeatherCore

final class WeatherTileView: UIView {
    var tileKind: TileKind?

    private let glassView = GlassStyle.makeBlurView()
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
        backgroundColor = .clear
        GlassStyle.applyHairline(to: layer, radius: WeatherDesignSystem.Tile.cornerRadius)
        clipsToBounds = true

        addSubview(glassView)

        titleLabel.font = WeatherDesignSystem.Typography.preferred(.headline)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = GlassStyle.textSecondary

        valueLabel.font = WeatherDesignSystem.Typography.preferred(.title1)
        valueLabel.adjustsFontForContentSizeCategory = true
        valueLabel.textColor = GlassStyle.textPrimary

        subtitleLabel.font = WeatherDesignSystem.Typography.preferred(.subheadline)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.textColor = GlassStyle.textSecondary
        subtitleLabel.numberOfLines = 0

        [titleLabel, valueLabel, subtitleLabel].forEach { addSubview($0) }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        glassView.frame = bounds
        let padding = WeatherDesignSystem.Tile.padding
        let width = max(0, bounds.width - padding * 2)
        let fitting = CGSize(width: width, height: .greatestFiniteMagnitude)

        let titleHeight = ceil(titleLabel.sizeThatFits(fitting).height)
        titleLabel.frame = CGRect(x: padding, y: padding, width: width, height: titleHeight)

        let valueHeight = ceil(valueLabel.sizeThatFits(fitting).height)
        valueLabel.frame = CGRect(
            x: padding,
            y: titleLabel.frame.maxY + WeatherDesignSystem.Tile.valueTopSpacing,
            width: width,
            height: valueHeight
        )

        let hasSubtitle = subtitleLabel.text?.isEmpty == false
        let subtitleHeight = hasSubtitle ? ceil(subtitleLabel.sizeThatFits(fitting).height) : 0
        subtitleLabel.frame = CGRect(
            x: padding,
            y: max(valueLabel.frame.maxY + WeatherDesignSystem.Spacing.xxs, bounds.height - padding - subtitleHeight),
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
