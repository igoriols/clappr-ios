public class DrawerPlugin: OverlayPlugin {

    open class override var name: String {
        return "OverlayPlugin"
    }

    open var isOpen: Bool {
        return false
    }

    var position: Position {
        return .modal(placeholder: 0)
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

    override public func bindEvents() {
        bindCoreEvents()
        bindPlaybackEvents()
    }

    private func bindPlaybackEvents() {
        guard let playback = core?.activePlayback else { return }
        listenTo(playback, event: .didComplete) { [weak self] _ in
            self?.animateNewAlpha(to: 0, duration: ClapprAnimationDuration.mediaControlHide)
        }
    }

    private func bindCoreEvents() {
        guard let core = core else { return }
        listenTo(core, event: .willHideMediaControl) { [weak self] _ in
            if self?.isOpen == false {
                self?.animateNewAlpha(to: 0, duration: ClapprAnimationDuration.mediaControlHide)
            }
        }

        listenTo(core, event: .willShowMediaControl) { [weak self] _ in
            self?.animateNewAlpha(to: 1, duration: ClapprAnimationDuration.mediaControlShow)
        }
    }

    private func animateNewAlpha(to newAlpha: CGFloat, duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.view.alpha = newAlpha
        }
    }
}
