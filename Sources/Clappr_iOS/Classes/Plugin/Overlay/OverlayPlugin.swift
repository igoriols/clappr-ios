public class OverlayPlugin: UICorePlugin {
    open class override var name: String {
        return "OverlayPlugin"
    }

    enum Position {
        case left(placeholder: CGFloat)
        case right(placeholder: CGFloat)
        case top(placeholder: CGFloat)
        case bottom(placeholder: CGFloat)
        case modal(placeholder: CGFloat)

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
            case .modal:
                return 0
            }
        }
    }
}
