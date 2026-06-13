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
        let width = bounds.width - padding * 2

        titleLabel.frame = CGRect(x: padding, y: padding, width: width, height: WeatherDesignSystem.Tile.titleHeight)
        valueLabel.frame = CGRect(
            x: padding,
            y: titleLabel.frame.maxY + WeatherDesignSystem.Tile.valueTopSpacing,
            width: width,
            height: WeatherDesignSystem.Tile.valueHeight
        )

        let subtitleHeight = subtitleLabel.text?.isEmpty == false
            ? WeatherDesignSystem.Tile.subtitleHeight
            : 0
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
