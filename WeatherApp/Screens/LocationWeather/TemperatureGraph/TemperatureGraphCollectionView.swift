import UIKit
import WeatherCore

final class TemperatureGraphCollectionView: UIView {
    private var items: [HourlyDisplayItem] = []
    private let graphLayout = TemperatureGraphLayout()
    private let sectionLabel = UILabel()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: graphLayout)
        view.backgroundColor = WeatherDesignSystem.Graph.Container.backgroundColor
        view.layer.cornerRadius = WeatherDesignSystem.Graph.Container.cornerRadius
        view.clipsToBounds = true
        view.showsHorizontalScrollIndicator = false
        view.dataSource = self
        view.delegate = self
        view.contentInset = UIEdgeInsets(
            top: 0,
            left: WeatherDesignSystem.Graph.Container.contentInsetHorizontal,
            bottom: 0,
            right: WeatherDesignSystem.Graph.Container.contentInsetHorizontal
        )
        view.register(
            TemperatureGraphCell.self,
            forCellWithReuseIdentifier: TemperatureGraphCell.reuseIdentifier
        )
        view.register(
            DayHeaderReusableView.self,
            forSupplementaryViewOfKind: TemperatureGraphLayout.dayHeaderKind,
            withReuseIdentifier: DayHeaderReusableView.reuseIdentifier
        )
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        sectionLabel.text = "Hourly Forecast"
        sectionLabel.font = WeatherDesignSystem.Typography.preferred(.headline)
        sectionLabel.adjustsFontForContentSizeCategory = true
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sectionLabel)
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            sectionLabel.topAnchor.constraint(equalTo: topAnchor),
            sectionLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: WeatherDesignSystem.Layout.screenHorizontalInset
            ),
            sectionLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -WeatherDesignSystem.Layout.screenHorizontalInset
            ),

            collectionView.topAnchor.constraint(
                equalTo: sectionLabel.bottomAnchor,
                constant: WeatherDesignSystem.Graph.Container.labelTopSpacing
            ),
            collectionView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: WeatherDesignSystem.Layout.screenHorizontalInset
            ),
            collectionView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -WeatherDesignSystem.Layout.screenHorizontalInset
            ),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: graphLayout.totalHeight + WeatherDesignSystem.Graph.Container.intrinsicLabelHeight
        )
    }

    func configure(with items: [HourlyDisplayItem]) {
        self.items = items
        graphLayout.dayHeaders = items.enumerated().compactMap { index, item in
            guard let label = item.dayLabel else { return nil }
            return (itemIndex: index, label: label)
        }
        graphLayout.invalidateLayout()
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        invalidateIntrinsicContentSize()
    }

    func invalidateGraphLayout() {
        graphLayout.invalidateLayout()
    }
}

extension TemperatureGraphCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TemperatureGraphCell.reuseIdentifier,
            for: indexPath
        ) as? TemperatureGraphCell else {
            return UICollectionViewCell()
        }

        let item = items[indexPath.item]
        let prevY = indexPath.item > 0
            ? items[indexPath.item - 1].temperatureDotY
            : item.temperatureDotY
        let nextY = indexPath.item < items.count - 1
            ? items[indexPath.item + 1].temperatureDotY
            : item.temperatureDotY

        cell.configure(with: item, prevNormalizedY: prevY, nextNormalizedY: nextY)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == TemperatureGraphLayout.dayHeaderKind,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: DayHeaderReusableView.reuseIdentifier,
                for: indexPath
              ) as? DayHeaderReusableView else {
            return UICollectionReusableView()
        }

        if let headerInfo = graphLayout.dayHeaders.first(where: { $0.itemIndex == indexPath.item }) {
            header.configure(with: headerInfo.label)
        }
        return header
    }
}

extension TemperatureGraphCollectionView: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        graphLayout.invalidateLayout()
    }
}
