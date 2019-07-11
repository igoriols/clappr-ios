class BottomDrawerPlugin: DrawerPlugin {
    open class override var name: String {
        return "BottomDrawerPlugin"
    }

    override var position: DrawerPlugin.Position {
        return .bottom(placeholder: 20)
    }

    override var width: CGFloat {
        return core?.view.bounds.width ?? .zero
    }

    override var height: CGFloat {
        return coreViewBounds.height / 2
    }

    private var hiddenHeight: CGFloat {
        return height - position.placeHolderSize()
    }

    private var coreViewBounds: CGRect {
        return core?.view.bounds ?? .zero
    }

    private var initialCenterY = CGFloat.zero

    private var initialY: CGFloat {
        return coreViewBounds.height - position.placeHolderSize()
    }

    private var openedY: CGFloat {
        return coreViewBounds.height - view.frame.height
    }

    override func bindEvents() {
        super.bindEvents()

        guard let core = core, let container = core.activeContainer else { return }
        listenTo(container, event: .didResize) { [weak self] _ in
            self?.updateWidth()
        }

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

    override var isOpen: Bool {
        return initialY != view.frame.origin.y
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
        let isDraggable = canDrag(with: newYCoordinate)

        if gesture.state == .changed && isDraggable {
            recognizerView.center.y = newYCoordinate
            gesture.setTranslation(.zero, in: recognizerView)

            let portionShown = initialCenterY - newYCoordinate
            let alpha = hiddenHeight / portionShown * 0.1
            core?.trigger(.didDragDrawer, userInfo: ["alpha": alpha])
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
        UIView.animate(withDuration: 0.5) {
            self.view.frame = CGRect(
                x: .zero,
                y: self.openedY,
                width: self.width,
                height: self.height
            )
            self.core?.trigger(.didOpenDrawer)
        }
    }

    private func closeDrawer() {
        UIView.animate(withDuration: 0.5) {
            self.view.frame = CGRect(
                x: .zero,
                y: self.initialY,
                width: self.width,
                height: self.height
            )
            self.core?.trigger(.didCloseDrawer)
        }
    }

    override func render() {
        view.frame = CGRect(x: .zero, y: initialY, width: width, height: height)
        view.layoutIfNeeded()
        initialCenterY = view.center.y

        addDragGesture()
        addTapGesture()

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
