public class CustomBottomDrawerPlugin: BottomDrawerPlugin {
    open class override var name: String {
        return "CustomBottomDrawerPlugin"
    }

    private var label = UILabel()
    private var backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .light))

    required init(context: UIObject) {
        super.init(context: context)
        view.addSubviewMatchingConstraints(backgroundView)
        view.addSubviewMatchingConstraints(label)
    }

    override func bindEvents() {
        super.bindEvents()
    }

    override func render() {
        super.render()
        label.text = "Hey! I'm a bottom drawer plugin!"
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 0, height: 1)
    }
}
