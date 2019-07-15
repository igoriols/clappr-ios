open class Overlay: UIObject {
    private(set) var plugins: [Plugin] = []
    @objc open var options: Options {
        didSet {
            trigger(Event.didUpdateOptions)
        }
    }

    public init(options: Options = [:]) {
        Logger.logDebug("loading with \(options)", scope: "\(type(of: self))")
        self.options = options
        super.init()
        view = PassthroughView()
        view.backgroundColor = .clear
        view.accessibilityIdentifier = "Overlay"
    }

    open override func render() {
        plugins.forEach(renderPlugin)
    }

    fileprivate func renderPlugin(_ plugin: Plugin) {
        if let plugin = plugin as? UICorePlugin {
            view.addSubview(plugin.view)
            do {
                try ObjC.catchException {
                    plugin.render()
                }
            } catch {
                Logger.logError("\((plugin as Plugin).pluginName) crashed during render (\(error.localizedDescription))", scope: "Container")
            }
        }
    }

    func addPlugin(_ plugin: Plugin) {
        plugins.append(plugin)
    }

    @objc open func destroy() {
        Logger.logDebug("destroying", scope: "Container")

        plugins.removeAll()
        view.removeFromSuperview()

        trigger(Event.didDestroy.rawValue)
        Logger.logDebug("destroying listeners", scope: "Container")
        stopListening()
        Logger.logDebug("destroyed", scope: "Container")
    }
}
