class BackgroundPlugin: UICorePlugin {
    open class override var name: String {
        return "BackgroundPlugin"
    }

    override func render() {
        setupBackground()
    }

    override func bindEvents() {
        bindCoreEvents()
    }

    private func bindCoreEvents() {
        guard let core = core else { return }
        listenTo(core,
                 eventName: Event.willShowMediaControl.rawValue) { [weak self] _ in self?.show() }
        listenTo(core,
                 eventName: Event.willHideMediaControl.rawValue) { [weak self] _ in self?.hide() }
    }

    private func show() {
        UIView.animate(
            withDuration: ClapprAnimationDuration.mediaControlShow,
            animations: { self.view.alpha = 1 })
    }

    private func hide() {
        UIView.animate(
            withDuration: ClapprAnimationDuration.mediaControlHide,
            animations: { self.view.alpha = 0 })
    }

    private func setupBackground() {
        view.alpha = 0
        view.bindFrameToSuperviewBounds()
        view.backgroundColor = .clapprBlack60Color()
        view.isUserInteractionEnabled = false
    }
}
