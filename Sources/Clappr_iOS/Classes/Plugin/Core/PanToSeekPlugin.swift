import UIKit

public class PanToSeekPlugin: SimpleCorePlugin {

    var panGesture: UIPanGestureRecognizer!

    open class override var name: String {
        return "PanToSeekPlugin"
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

    public override func bindEvents() {
        activePlayback?.on(Event.didSeek.rawValue) { [weak self] _ in
            self?.initialPosition = self?.activePlayback?.position
        }
    }

    func addGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panSeek))
        panGesture.minimumNumberOfTouches = 2
        coreView.addGestureRecognizer(panGesture)
    }

    private var initialPosition: TimeInterval?

    @objc func panSeek(recognizer: UIPanGestureRecognizer) {
        guard let activePlayback = core?.activePlayback else { return }
        let coreWidth = coreView.frame.width

        if initialPosition == nil {
            initialPosition = activePlayback.position
        }

        let translation = recognizer.translation(in: coreView)
        let pixelsPerSeconds = coreWidth / CGFloat(activePlayback.duration)
        let secondsToSeek = translation.x / pixelsPerSeconds

        impactFeedback()
        activePlayback.seek(TimeInterval(secondsToSeek) + (initialPosition ?? 0))
    }

    private func impactFeedback() {
        UIImpactFeedbackGenerator().impactOccurred()
    }
}
