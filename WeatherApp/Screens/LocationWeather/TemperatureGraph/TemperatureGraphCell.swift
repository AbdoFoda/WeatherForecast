import UIKit
import WeatherCore

final class TemperatureGraphCell: UICollectionViewCell {
    static let reuseIdentifier = "TemperatureGraphCell"

    private enum Metrics {
        static let horizontalPadding: CGFloat = 6
        static let timeHeight: CGFloat = 16
        static let iconSize: CGFloat = 28
        static let temperatureHeight: CGFloat = 18
        static let sectionSpacing: CGFloat = 6
    }

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
        timeLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
    }

    private func setup() {
        timeLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        timeLabel.adjustsFontForContentSizeCategory = true
        timeLabel.textAlignment = .center

        temperatureLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        temperatureLabel.adjustsFontForContentSizeCategory = true
        temperatureLabel.textAlignment = .center
        temperatureLabel.textColor = .secondaryLabel

        iconView.contentMode = .scaleAspectFit

        [timeLabel, iconView, temperatureLabel].forEach { addSubview($0) }

        curveLayer.strokeColor = UIColor.systemOrange.cgColor
        curveLayer.fillColor = UIColor.clear.cgColor
        curveLayer.lineWidth = 2.5
        curveLayer.lineCap = .round
        curveLayer.lineJoin = .round

        dotLayer.fillColor = UIColor.systemOrange.cgColor
        dotLayer.strokeColor = UIColor.systemBackground.cgColor
        dotLayer.lineWidth = 2

        layer.addSublayer(curveLayer)
        layer.addSublayer(dotLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutLabels()
        drawGraph()
    }

    private var graphTop: CGFloat {
        Metrics.timeHeight
            + Metrics.sectionSpacing
            + Metrics.iconSize
            + Metrics.sectionSpacing
            + Metrics.temperatureHeight
            + Metrics.sectionSpacing
    }

    private func layoutLabels() {
        let width = bounds.width
        let padding = Metrics.horizontalPadding
        let contentWidth = width - padding * 2
        var y: CGFloat = 0

        timeLabel.frame = CGRect(x: padding, y: y, width: contentWidth, height: Metrics.timeHeight)
        y += Metrics.timeHeight + Metrics.sectionSpacing

        iconView.frame = CGRect(
            x: (width - Metrics.iconSize) / 2,
            y: y,
            width: Metrics.iconSize,
            height: Metrics.iconSize
        )
        y += Metrics.iconSize + Metrics.sectionSpacing

        temperatureLabel.frame = CGRect(x: padding, y: y, width: contentWidth, height: Metrics.temperatureHeight)
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
            timeLabel.font = UIFont.preferredFont(forTextStyle: .caption1).bold()
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
        let graphHeight = max(0, bounds.height - top - 8)
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
            radius: 5,
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
