import UIKit
import WeatherCore

final class TemperatureGraphCell: UICollectionViewCell {
    static let reuseIdentifier = "TemperatureGraphCell"

    private let timeLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let iconView = UIImageView()
    private let curveLayer = CAShapeLayer()
    private let dotLayer = CAShapeLayer()
    private var imageTask: Task<Void, Never>?

    private var prevNormalizedY: CGFloat = 0.5
    private var currentNormalizedY: CGFloat = 0.5
    private var nextNormalizedY: CGFloat = 0.5

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        iconView.image = nil
        timeLabel.font = WeatherDesignSystem.Typography.preferred(.caption1)
    }

    private func setup() {
        timeLabel.font = WeatherDesignSystem.Typography.preferred(.caption1)
        timeLabel.adjustsFontForContentSizeCategory = true
        timeLabel.textAlignment = .center

        temperatureLabel.font = WeatherDesignSystem.Typography.preferred(.caption1)
        temperatureLabel.adjustsFontForContentSizeCategory = true
        temperatureLabel.textAlignment = .center
        temperatureLabel.textColor = .secondaryLabel

        iconView.contentMode = .scaleAspectFit

        [timeLabel, iconView, temperatureLabel].forEach { addSubview($0) }

        curveLayer.strokeColor = WeatherDesignSystem.Graph.Cell.curveColor.cgColor
        curveLayer.fillColor = UIColor.clear.cgColor
        curveLayer.lineWidth = WeatherDesignSystem.Graph.Cell.curveLineWidth
        curveLayer.lineCap = .round
        curveLayer.lineJoin = .round

        dotLayer.fillColor = WeatherDesignSystem.Graph.Cell.curveColor.cgColor
        dotLayer.strokeColor = UIColor.systemBackground.cgColor
        dotLayer.lineWidth = WeatherDesignSystem.Graph.Cell.dotBorderWidth

        layer.addSublayer(curveLayer)
        layer.addSublayer(dotLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutLabels()
        drawGraph()
    }

    private var graphTop: CGFloat {
        WeatherDesignSystem.Graph.Cell.timeHeight
            + WeatherDesignSystem.Graph.Cell.sectionSpacing
            + WeatherDesignSystem.Icon.graphCell
            + WeatherDesignSystem.Graph.Cell.sectionSpacing
            + WeatherDesignSystem.Graph.Cell.temperatureHeight
            + WeatherDesignSystem.Graph.Cell.sectionSpacing
    }

    private func layoutLabels() {
        let width = bounds.width
        let padding = WeatherDesignSystem.Graph.Cell.horizontalPadding
        let contentWidth = width - padding * 2
        var y: CGFloat = 0

        timeLabel.frame = CGRect(
            x: padding,
            y: y,
            width: contentWidth,
            height: WeatherDesignSystem.Graph.Cell.timeHeight
        )
        y += WeatherDesignSystem.Graph.Cell.timeHeight + WeatherDesignSystem.Graph.Cell.sectionSpacing

        iconView.frame = CGRect(
            x: (width - WeatherDesignSystem.Icon.graphCell) / 2,
            y: y,
            width: WeatherDesignSystem.Icon.graphCell,
            height: WeatherDesignSystem.Icon.graphCell
        )
        y += WeatherDesignSystem.Icon.graphCell + WeatherDesignSystem.Graph.Cell.sectionSpacing

        temperatureLabel.frame = CGRect(
            x: padding,
            y: y,
            width: contentWidth,
            height: WeatherDesignSystem.Graph.Cell.temperatureHeight
        )
    }

    func configure(
        with item: HourlyDisplayItem,
        prevNormalizedY: CGFloat,
        nextNormalizedY: CGFloat
    ) {
        timeLabel.text = item.time
        temperatureLabel.text = item.temperature
        self.prevNormalizedY = prevNormalizedY
        currentNormalizedY = item.temperatureDotY
        self.nextNormalizedY = nextNormalizedY

        if item.isCurrentHour {
            timeLabel.font = WeatherDesignSystem.Typography.preferred(.caption1).bold()
            temperatureLabel.textColor = .label
        } else {
            temperatureLabel.textColor = .secondaryLabel
        }

        imageTask?.cancel()
        guard let iconURL = item.iconURL else {
            iconView.image = nil
            return
        }

        imageTask = Task { [weak self] in
            do {
                let (data, _) = try await URLSession.shared.data(from: iconURL)
                guard !Task.isCancelled, let image = UIImage(data: data) else { return }
                await MainActor.run {
                    self?.iconView.image = image
                }
            } catch {}
        }

        setNeedsLayout()
    }

    private func drawGraph() {
        let top = graphTop
        let graphHeight = max(0, bounds.height - top - WeatherDesignSystem.Graph.Cell.graphBottomInset)
        let cellWidth = bounds.width

        let path = TemperatureGraphRenderer.curvePath(
            cellWidth: cellWidth,
            graphTop: top,
            graphHeight: graphHeight,
            prevNormalizedY: prevNormalizedY,
            currentNormalizedY: currentNormalizedY,
            nextNormalizedY: nextNormalizedY
        )
        curveLayer.frame = bounds
        curveLayer.path = path.cgPath

        let dotCenter = TemperatureGraphRenderer.dotCenter(
            cellWidth: cellWidth,
            graphTop: top,
            graphHeight: graphHeight,
            normalizedY: currentNormalizedY
        )
        let dotPath = UIBezierPath(
            arcCenter: dotCenter,
            radius: WeatherDesignSystem.Graph.Cell.dotRadius,
            startAngle: 0,
            endAngle: .pi * 2,
            clockwise: true
        )
        dotLayer.path = dotPath.cgPath
    }
}

private extension UIFont {
    func bold() -> UIFont {
        UIFont(descriptor: fontDescriptor.withSymbolicTraits(.traitBold) ?? fontDescriptor, size: pointSize)
    }
}
