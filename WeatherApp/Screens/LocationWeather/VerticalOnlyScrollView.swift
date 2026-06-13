import UIKit

final class VerticalOnlyScrollView: UIScrollView {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === panGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: self)
            if abs(translation.x) > abs(translation.y), translation != .zero {
                return false
            }
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}
