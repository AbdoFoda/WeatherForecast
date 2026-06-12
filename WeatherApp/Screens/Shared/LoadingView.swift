import UIKit

final class LoadingView: UIView {
    private let spinner = UIActivityIndicatorView(style: .large)

    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        isUserInteractionEnabled = false
        backgroundColor = UIColor.systemBackground.withAlphaComponent(WeatherDesignSystem.Overlay.loadingScrimAlpha)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startAnimating() {
        isHidden = false
        isUserInteractionEnabled = true
        spinner.startAnimating()
    }

    func stopAnimating() {
        spinner.stopAnimating()
        isHidden = true
        isUserInteractionEnabled = false
    }
}
