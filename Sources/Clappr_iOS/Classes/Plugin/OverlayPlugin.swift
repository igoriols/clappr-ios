class OverlayPlugin: UICorePlugin {
    open class override var name: String {
        return "OverlayPlugin"
    }

    open var isModal: Bool = false
}

class DrawerPlugin: OverlayPlugin {
    open class override var name: String {
        return "OverlayPlugin"
    }

    open var isOpen: Bool = false

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
        let blurEffect = UIBlurEffect(style: .light)
        view = UIVisualEffectView(effect: blurEffect)
    }

    enum Position {
        case left
        case right
        case top
        case bottom
        case none

        func placeHolderSize() -> CGFloat {
            return 30
        }
    }
}

class BottomDrawer: DrawerPlugin {
    open class override var name: String {
        return "BottomDrawer"
    }

    override var position: DrawerPlugin.Position {
        return .bottom
    }

    override var width: CGFloat {
        return core?.view.bounds.width ?? .zero
    }

    override var height: CGFloat {
        return coreViewBounds.height / 2
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
        let isDraggable = canDrag(with: newYCoordinate)

        if gesture.state == .changed && isDraggable {
            recognizerView.center.y = newYCoordinate
            gesture.setTranslation(.zero, in: recognizerView)
        }
    }

    private func canDrag(with newYPosition: CGFloat) -> Bool {
        let hiddenHeight = height - position.placeHolderSize()
        let canDragUp = initialCenterY - newYPosition < hiddenHeight
        let canDragDown = initialCenterY > newYPosition
        return canDragUp && canDragDown
    }

    @objc func onTap(_ gesture: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5, animations: toggleDrawer)
    }

    private func toggleDrawer() {
        let newY = isOpen ? initialY : openedY
        view.frame = CGRect(x: .zero, y: newY, width: width, height: height)
        isOpen.toggle()
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
