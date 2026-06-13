import UIKit

enum WeatherDesignSystem {
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 10
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let section: CGFloat = 32
    }

    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
    }

    enum Typography {
        static let temperatureDisplaySize: CGFloat = 72

        static func preferred(_ style: UIFont.TextStyle) -> UIFont {
            UIFont.preferredFont(forTextStyle: style)
        }

        static func scaledTemperatureDisplay() -> UIFont {
            scaled(.largeTitle, size: temperatureDisplaySize, weight: .thin)
        }

        static func scaled(_ style: UIFont.TextStyle, size: CGFloat, weight: UIFont.Weight) -> UIFont {
            UIFontMetrics(forTextStyle: style)
                .scaledFont(for: UIFont.systemFont(ofSize: size, weight: weight))
        }
    }

    enum Icon {
        static let summaryWeather: CGFloat = 56
        static let graphCell: CGFloat = 28
    }

    enum Layout {
        static let screenHorizontalInset = Spacing.lg
        static let summaryHorizontalInset: CGFloat = 20
        static let permissionHorizontalInset = Spacing.section
        static let graphHeight: CGFloat = 232
        static let tilesInitialHeight: CGFloat = 200
        static let sectionSpacing = Spacing.xxl
        static let attributionBottomInset = Spacing.xxl
        static let summaryTopInset = Spacing.lg
        static let summarySafeAreaExtra = Spacing.md
        static let offlineBannerBottomInset = Spacing.md
        static let permissionMessageVerticalOffset: CGFloat = 40
        static let permissionButtonTopSpacing = Spacing.xxl
    }

    enum Overlay {
        static let loadingScrimAlpha: CGFloat = 0.7
    }

    enum SkyText {
        static let primaryColor = UIColor.white
        static let secondaryAlpha: CGFloat = 0.92
        static let primaryShadowOpacity: Float = 0.45
        static let secondaryShadowOpacity: Float = 0.35
        static let shadowOffset = CGSize(width: 0, height: 1)
        static let shadowRadius: CGFloat = 4
    }

    enum Tile {
        static let padding = Spacing.lg
        static let titleHeight: CGFloat = 22
        static let valueHeight: CGFloat = 28
        static let valueTopSpacing = Spacing.xs
        static let subtitleHeight: CGFloat = 20
        static let gridSpacing = Spacing.lg
        static let backgroundColor: UIColor = .secondarySystemGroupedBackground
        static let cornerRadius = CornerRadius.large
    }

    enum Graph {
        enum Container {
            static let cornerRadius = CornerRadius.medium
            static let backgroundColor: UIColor = .secondarySystemGroupedBackground
            static let contentInsetHorizontal = Spacing.xs
            static let labelTopSpacing = Spacing.xs
            static let intrinsicLabelHeight: CGFloat = 36
        }

        enum Layout {
            static let itemWidth: CGFloat = 88
            static let cellContentHeight: CGFloat = 160
            static let headerBandHeight: CGFloat = 36
            static let headerWidth: CGFloat = 110
            static let headerHeight: CGFloat = 28
        }

        enum Cell {
            static let horizontalPadding: CGFloat = 6
            static let timeHeight = Spacing.lg
            static let temperatureHeight: CGFloat = 18
            static let sectionSpacing: CGFloat = 6
            static let graphBottomInset = Spacing.xs
            static let curveLineWidth: CGFloat = 2.5
            static let dotRadius: CGFloat = 5
            static let dotBorderWidth: CGFloat = 2
            static let curveColor: UIColor = .systemOrange
        }

        enum DayHeader {
            static let cornerRadius = CornerRadius.small
            static let borderWidth: CGFloat = 1
            static let horizontalInset: CGFloat = 10
            static let verticalInset = Spacing.xxs
        }
    }

    enum Banner {
        static let cornerRadius = CornerRadius.medium
        static let verticalPadding = Spacing.md
        static let horizontalPadding = Spacing.lg
        static let backgroundColor: UIColor = .secondarySystemBackground
        static let transitionDuration: TimeInterval = 0.3
        static let backOnlineDisplayDuration: TimeInterval = 2.5
    }
}
