import UIKit

public class PanToSeekPlugin: UICorePlugin {
    var panGesture: UIPanGestureRecognizer!
    var label: UILabel!
    private var seekableStates: [PlaybackState] = [.playing, .paused]

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
        
        label = UILabel()
        view = label
    }

    override public func render() {
        label.frame = coreView.bounds
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 14)

        label.anchorInCenter()
    }

    public override func bindEvents() {
        activePlayback?.on(Event.didSeek.rawValue) { [weak self] _ in
            self?.initialPosition = self?.activePlayback?.position
        }

        core?.on(Event.willShowMediaControl.rawValue) { [weak self] _ in
            self?.removeGesture()
        }

        core?.on(Event.willHideMediaControl.rawValue) { [weak self] _ in
            self?.addGesture()
        }
    }

    func addGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panSeek))
        panGesture.minimumNumberOfTouches = 1
        coreView.addGestureRecognizer(panGesture)
    }

    func removeGesture() {
        coreView.removeGestureRecognizer(panGesture)
    }

    private var initialPosition: TimeInterval?

    @objc func panSeek(recognizer: UIPanGestureRecognizer) {
        guard let activePlayback = core?.activePlayback, seekableStates.contains(activePlayback.state) else { return }
        let coreWidth = coreView.frame.width

        if initialPosition == nil {
            initialPosition = activePlayback.position
        }

        let translation = recognizer.translation(in: coreView)
        let pixelsPerSeconds = coreWidth / CGFloat(activePlayback.duration)
        let secondsToSeek = translation.x / pixelsPerSeconds

        if secondsToSeek > 0 {
            label.text = "     \(Int(secondsToSeek)) seconds \u{25BA}\u{25BA}"
        } else {
            label.text = "\u{25C4}\u{25C4} \(abs(Int(secondsToSeek))) seconds       "
        }

        coreView.bringSubviewToFront(view)

        control(state: recognizer.state, secondsToSeek: TimeInterval(secondsToSeek) + (initialPosition ?? 0))
    }

    private func control(state: UIPanGestureRecognizer.State, secondsToSeek: TimeInterval) {
        switch state {
        case .began, .changed:
            hideLabel(false)
        case .ended:
            hideLabel(true)
            impactFeedback()
            core?.activePlayback?.seek(secondsToSeek)
        default:
            hideLabel(true)
        }
    }

    private func hideLabel(_ hide: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.label.isHidden = hide
        }
    }

    private func impactFeedback() {
        UIImpactFeedbackGenerator().impactOccurred()
    }
}
