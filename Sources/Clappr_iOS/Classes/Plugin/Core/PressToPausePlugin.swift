import UIKit

public class PressToPausePlugin: CorePlugin {

    var pressGesture: UILongPressGestureRecognizer!

    open class override var name: String {
        return "PressToPausePlugin"
    }

    private var activePlayback: Playback? {
        return core?.activePlayback
    }

    private var coreView: UIView {
        return core?.view ?? UIView()
    }

    required init(context: UIObject) {
        super.init(context: context)
        addGesture()
    }

    private func addGesture() {
        pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onPress))
        pressGesture.minimumPressDuration = 0.15
        coreView.addGestureRecognizer(pressGesture)
    }

    @objc private func onPress(recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            core?.trigger(InternalEvent.didPressToPause.rawValue)
            activePlayback?.pause()
            impactFeedback()
        case .ended:
            core?.trigger(InternalEvent.didReleasePressToPause.rawValue)
            activePlayback?.play()
            impactFeedback()
        default:
            Logger.logDebug("No action for \(recognizer.state) LongPress state")
        }
    }

    private func impactFeedback() {
        UIImpactFeedbackGenerator().impactOccurred()
    }
}
