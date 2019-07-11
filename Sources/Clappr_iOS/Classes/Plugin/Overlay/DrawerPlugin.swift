class DrawerPlugin: OverlayPlugin {

    enum Position {
        case left(placeholder: CGFloat)
        case right(placeholder: CGFloat)
        case top(placeholder: CGFloat)
        case bottom(placeholder: CGFloat)
        case none

        func placeHolderSize() -> CGFloat {
            switch self {
            case .left(let placeholder):
                return placeholder
            case .right(let placeholder):
                return placeholder
            case .top(let placeholder):
                return placeholder
            case .bottom(let placeholder):
                return placeholder
            case .none:
                return .zero
            }
        }
    }

    open class override var name: String {
        return "OverlayPlugin"
    }

    open var isOpen: Bool {
        return false
    }

    open var position: Position {
        return .none
    }

    open var width: CGFloat {
        return 0
    }

    open var height: CGFloat {
        return 0
    }

    required init(context: UIObject) {
        super.init(context: context)
        view.alpha = 0
    }

    override func bindEvents() {
        guard let core = core, let playback = core.activePlayback else { return }
        listenTo(core, event: .willHideMediaControl) { [weak self] _ in
            if self?.isOpen == false {
                self?.animateNewAlpha(to: 0, duration: ClapprAnimationDuration.mediaControlHide)
            }
        }

        listenTo(core, event: .willShowMediaControl) { [weak self] _ in
            self?.animateNewAlpha(to: 1, duration: ClapprAnimationDuration.mediaControlShow)
        }

        listenTo(playback, event: .didComplete) { [weak self] _ in
            self?.animateNewAlpha(to: 0, duration: ClapprAnimationDuration.mediaControlHide)
        }
    }

    private func animateNewAlpha(to newAlpha: CGFloat, duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.view.alpha = newAlpha
        }
    }
}
