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
}
