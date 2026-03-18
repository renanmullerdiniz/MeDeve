import Foundation

struct HapticHelper {
    static func success() {
        #if canImport(UIKit)
        let g = UINotificationFeedbackGenerator()
        g.prepare()
        g.notificationOccurred(.success)
        #endif
    }

    static func warning() {
        #if canImport(UIKit)
        let g = UINotificationFeedbackGenerator()
        g.prepare()
        g.notificationOccurred(.warning)
        #endif
    }

    static func error() {
        #if canImport(UIKit)
        let g = UINotificationFeedbackGenerator()
        g.prepare()
        g.notificationOccurred(.error)
        #endif
    }
}

#if canImport(UIKit)
import UIKit
#endif
