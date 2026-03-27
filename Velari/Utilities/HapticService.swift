import UIKit

enum HapticService {
    static func bookmarkToggle() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func pullToRefresh() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func share() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
