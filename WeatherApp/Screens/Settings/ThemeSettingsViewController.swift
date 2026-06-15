import UIKit
import WeatherCore

@MainActor
protocol ThemeSettingsViewControllerDelegate: AnyObject {
    func themeSettingsViewControllerDidFinish(_ controller: ThemeSettingsViewController)
}

final class ThemeSettingsViewController: UIViewController {
    weak var delegate: ThemeSettingsViewControllerDelegate?

    private let palettes = ThemeManager.shared.allThemes
    private let background = GradientView()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let spacing = WeatherDesignSystem.ThemeSettings.gridSpacing
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(
            top: spacing,
            left: spacing,
            bottom: spacing,
            right: spacing
        )
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.alwaysBounceVertical = true
        view.dataSource = self
        view.delegate = self
        view.register(ThemeCardCell.self, forCellWithReuseIdentifier: ThemeCardCell.reuseIdentifier)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = AppL10n.settingsTitle
        overrideUserInterfaceStyle = .dark
        configureBackground()
        configureDoneButton()
        configureCollectionView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        background.frame = view.bounds
    }

    private func configureBackground() {
        background.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        background.gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.addSubview(background)
        applyBackgroundTint()
    }

    private func applyBackgroundTint() {
        let palette = ThemeManager.shared.palette
        background.gradientLayer.colors = [
            palette.tintTop.withAlphaComponent(0.55).cgColor,
            UIColor.black.withAlphaComponent(0.9).cgColor
        ]
    }

    private func configureDoneButton() {
        let done = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneTapped)
        )
        navigationItem.rightBarButtonItem = done
    }

    @objc private func doneTapped() {
        delegate?.themeSettingsViewControllerDidFinish(self)
    }

    private func configureCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ThemeSettingsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        palettes.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ThemeCardCell.reuseIdentifier,
            for: indexPath
        ) as? ThemeCardCell else {
            return UICollectionViewCell()
        }
        let palette = palettes[indexPath.item]
        cell.configure(with: palette, isSelected: palette.theme == ThemeManager.shared.current)
        return cell
    }
}

extension ThemeSettingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let columns = WeatherDesignSystem.ThemeSettings.columns
        let spacing = WeatherDesignSystem.ThemeSettings.gridSpacing
        let totalSpacing = spacing * (columns + 1)
        let width = floor((collectionView.bounds.width - totalSpacing) / columns)
        return CGSize(width: max(0, width), height: WeatherDesignSystem.ThemeSettings.cardHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let palette = palettes[indexPath.item]
        guard palette.theme != ThemeManager.shared.current else { return }
        ThemeManager.shared.apply(palette.theme)
        UISelectionFeedbackGenerator().selectionChanged()
        applyBackgroundTint()
        collectionView.reloadData()
    }
}
