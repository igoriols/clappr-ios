public class BottomDrawerPlugin: DrawerPlugin {
    open class override var name: String {
        return "BottomDrawerPlugin"
    }

    override var position: DrawerPlugin.Position {
        return .bottom(placeholder: 30)
    }

    override public var width: CGFloat {
        return core?.view.bounds.width ?? .zero
    }

    override public var height: CGFloat {
        return coreViewBounds.height / 2
    }

    override public var isOpen: Bool {
        return initialY != view.frame.origin.y
    }

    private var hiddenHeight: CGFloat {
        return height - position.placeHolderSize()
    }

    private var coreViewBounds: CGRect {
        return core?.view.bounds ?? .zero
    }

    private var initialCenterY: CGFloat = .zero

    private var initialY: CGFloat {
        return coreViewBounds.height - position.placeHolderSize()
    }

    private var openedY: CGFloat {
        return coreViewBounds.height - view.frame.height
    }

    required init(context: UIObject) {
        super.init(context: context)
        addDragGesture()
        addTapGesture()
    }

    override public func bindEvents() {
        super.bindEvents()
        bindCoreEvents()
        bindContainerEvents()
    }

    private func bindCoreEvents() {
        guard let core = core else { return }
        listenTo(core, event: .willShowMediaControl) { [weak self] _ in
            self?.closeDrawer()
        }

        listenTo(core, event: .didEnterFullscreen) { [weak self] _ in
            self?.render()
        }

        listenTo(core, event: .didExitFullscreen) { [weak self] _ in
            self?.render()
        }
    }

    private func bindContainerEvents() {
        guard let container = core?.activeContainer else { return }
        listenTo(container, event: .didResize) { [weak self] _ in
            self?.updateWidth()
        }
    }

    private func updateWidth() {
        view.frame = CGRect(
            x: view.frame.origin.x,
            y: view.frame.origin.y,
            width: coreViewBounds.width,
            height: height)
    }

    @objc func onDrag(_ gesture: UIPanGestureRecognizer) {
        guard let recognizerView = gesture.view else { return }
        
        let translation = gesture.translation(in: recognizerView)
        let newYCoordinate = recognizerView.center.y + translation.y

        switch gesture.state {
        case .began, .changed:
            handleGestureChange(for: newYCoordinate, within: recognizerView)
        case .ended, .failed:
            handleGestureEnded(for: newYCoordinate)
        default:
            Logger.logInfo("undandled gesture state")
        }

        gesture.setTranslation(.zero, in: view)
    }

    private func handleGestureChange(for newYCoordinate: CGFloat, within view: UIView) {
        if canDrag(with: newYCoordinate) {
            view.center.y = newYCoordinate
            let portionShown = initialCenterY - newYCoordinate
            let alpha = hiddenHeight / portionShown * 0.1
            core?.trigger(.didDragDrawer, userInfo: ["alpha": alpha])
        }
    }

    private func handleGestureEnded(for newYCoordinate: CGFloat) {
        let portionShown = initialCenterY - newYCoordinate
        let isHalfWayOpen = portionShown / hiddenHeight > 0.5

        if isHalfWayOpen {
            openDrawer()
        } else {
            closeDrawer()
        }
    }

    private func canDrag(with newYCoordinate: CGFloat) -> Bool {
        let canDragUp = initialCenterY - newYCoordinate < hiddenHeight
        let canDragDown = initialCenterY > newYCoordinate
        return canDragUp && canDragDown
    }

    @objc func onTap(_ gesture: UITapGestureRecognizer) {
        openDrawer()
    }

    private func openDrawer() {
        UIView.animate(withDuration: ClapprAnimationDuration.mediaControlShow) {
            self.view.frame = CGRect(
                x: .zero,
                y: self.openedY,
                width: self.width,
                height: self.height
            )
        }
        core?.trigger(.didOpenDrawer)
    }

    private func closeDrawer() {
        UIView.animate(withDuration: ClapprAnimationDuration.mediaControlHide) {
            self.view.frame = CGRect(
                x: .zero,
                y: self.initialY,
                width: self.width,
                height: self.height
            )
        }
        core?.trigger(.didCloseDrawer)
    }

    override public func render() {
        view.frame = CGRect(x: .zero, y: initialY, width: width, height: height)
        view.layoutIfNeeded()
        initialCenterY = view.center.y
        core?.trigger(.didLoadDrawer, userInfo: ["position": position])
    }

    private func addDragGesture() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(onDrag))
        view.addGestureRecognizer(gesture)
    }

    private func addTapGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        view.addGestureRecognizer(gesture)
    }
}
