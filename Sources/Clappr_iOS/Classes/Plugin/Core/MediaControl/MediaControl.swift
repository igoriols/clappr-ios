open class MediaControl: UICorePlugin, UIGestureRecognizerDelegate {

    open class Element: UICorePlugin, MediaControlPluginType {
        open var panel: MediaControlPanel {
            return .center
        }

        open var position: MediaControlPosition {
            return .left
        }
    }

    public var tapGesture: UITapGestureRecognizer?

    var mediaControlView: MediaControlView = .fromNib()

    var options: Options? {
        return core?.options
    }

    private var activeContainer: Container? {
        return core?.activeContainer
    }

    private var activePlayback: Playback? {
        return core?.activePlayback
    }

    open class override var name: String {
        return "MediaControl"
    }

    public var hideControlsTimer: Timer?
    public var shortTimeToHideMediaControl = 0.4
    public var longTimeToHideMediaControl = 4.0
    public var mediaControlShow = ClapprAnimationDuration.mediaControlShow
    public var mediaControlHide = ClapprAnimationDuration.mediaControlHide

    private var showControls = true
    private var alwaysVisible = false
    private var currentlyShowing = false
    private var currentlyHiding = false

    required public init(context: UIObject) {
        super.init(context: context)
        alwaysVisible = (core?.options[kMediaControlAlwaysVisible] as? Bool) ?? false
    }

    override open func bindEvents() {
        bindCoreEvents()
        bindContainerEvents()
        bindPlaybackEvents()
    }

    open func bindCoreEvents() {
        if let core = self.core {

            listenTo(core, eventName: Event.didEnterFullscreen.rawValue) { [weak self] _ in
                if self?.hideControlsTimer?.isValid ?? false {
                    self?.disappearAfterSomeTime()
                }
            }

            listenTo(core, eventName: Event.didExitFullscreen.rawValue) { [weak self] _ in
                if self?.hideControlsTimer?.isValid ?? false {
                    self?.disappearAfterSomeTime()
                }
            }

            listenTo(core, eventName: InternalEvent.didTappedCore.rawValue) { [weak self] _ in
                self?.toggleVisibility()
            }

            listenTo(core, eventName: InternalEvent.willBeginScrubbing.rawValue) { [weak self] _ in
                self?.keepVisible()
            }

            listenTo(core, eventName: InternalEvent.didFinishScrubbing.rawValue) { [weak self] _ in
                guard self?.activePlayback?.state == .playing else { return }
                self?.disappearAfterSomeTime()
            }

            listenTo(core, event: .didLoadDrawer) { [weak self] info in
                guard let position = info?["position"] as? DrawerPlugin.Position else { return }
                self?.handleDrawer(for: position)
            }

            listenTo(core, event: .didDragDrawer) { [weak self] info in
                guard let alpha = info?["alpha"] as? CGFloat else { return }
                self?.view.alpha = alpha
            }

            listenTo(core, event: .didOpenDrawer) { [weak self] _ in
                self?.hide()
            }

            listenTo(core, event: .didCloseDrawer) { [weak self] _ in
                self?.show()
            }
        }
    }

    private func handleDrawer(for position: DrawerPlugin.Position) {
        switch position {
        case .top(let placeholderPadding):
            mediaControlView.topMargin.constant = -placeholderPadding
        case .right(let placeholderPadding):
            mediaControlView.rightMargin.constant = -placeholderPadding
        case .bottom(let placeholderPadding):
            mediaControlView.bottomMargin.constant = -placeholderPadding
        case .left(let placeholderPadding):
            mediaControlView.leftMargin.constant = -placeholderPadding
        default:
            Logger.logInfo("Handle other possible drawer positions")
        }
        view.layoutIfNeeded()
    }

    private func bindContainerEvents() {
        if let container = activeContainer {
            listenTo(container,
                     eventName: Event.enableMediaControl.rawValue) { [weak self] _ in self?.show() }
            listenTo(container,
                     eventName: Event.disableMediaControl.rawValue) { [weak self] _ in self?.hide() }
        }
    }

    private func bindPlaybackEvents() {
        if let playback = activePlayback {
            listenTo(playback, eventName: Event.ready.rawValue) { [weak self] _ in
                self?.showControls = true
            }

            listenTo(playback, eventName: Event.didComplete.rawValue) { [weak self] _ in
                self?.hide()
            }

            listenTo(playback, eventName: Event.didPause.rawValue) { [weak self] _ in
                self?.keepVisible()
                self?.listenToOnce(playback, eventName: Event.playing.rawValue) { [weak self] _ in
                    self?.show { [weak self] in
                        self?.disappearAfterSomeTime()
                    }
                }
            }

            listenTo(playback, eventName: Event.error.rawValue) { [weak self] _ in
                self?.showControls = false
            }
        }
    }

    func show(animated: Bool = false, completion: (() -> Void)? = nil) {
        if currentlyShowing {
            completion?()
            return
        }

        let duration = animated ? mediaControlShow : 0

        currentlyShowing = true
        currentlyHiding = false

        core?.trigger(Event.willShowMediaControl.rawValue)

        if view.alpha == 0 {
            view.isHidden = false
        }

        UIView.animate(
            withDuration: duration,
            animations: {
                self.view.alpha = 1
        },
            completion: { [weak self] _ in
                self?.view.isHidden = false
                self?.currentlyShowing = false
                self?.core?.trigger(Event.didShowMediaControl.rawValue)
                completion?()
            }
        )
    }

    func hide(animated: Bool = false, completion: (() -> Void)? = nil) {
        if currentlyHiding {
            completion?()
            return
        }

        if !alwaysVisible {
            core?.trigger(Event.willHideMediaControl.rawValue)

            currentlyShowing = false
            currentlyHiding = true

            let duration = animated ? mediaControlHide : 0

            UIView.animate(
                withDuration: duration,
                animations: {
                    self.view.alpha = 0
            },
                completion: { [weak self] _ in
                    self?.currentlyHiding = false
                    self?.view.isHidden = true
                    self?.core?.trigger(Event.didHideMediaControl.rawValue)
                    completion?()
                }
            )
        }
    }

    public func disappearAfterSomeTime(_ duration: TimeInterval? = nil) {
        hideControlsTimer?.invalidate()
        hideControlsTimer = Timer.scheduledTimer(timeInterval: duration ?? shortTimeToHideMediaControl,
                                                 target: self, selector: #selector(hideAndStopTimer), userInfo: nil, repeats: false)
    }

    public func keepVisible() {
        hideControlsTimer?.invalidate()
    }

    @objc func hideAndStopTimer() {
        hideControlsTimer?.invalidate()
        hide(animated: true)
    }

    @objc func tapped() {
        hideAndStopTimer()
    }
    
    override open func render() {
        view.addSubview(mediaControlView)
        mediaControlView.bindFrameToSuperviewBounds()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        self.tapGesture = tapGesture
        
        view.isHidden = true
        view.backgroundColor = UIColor.clear


        if let constrastView = mediaControlView.contrastView {
            constrastView.backgroundColor = UIColor.clapprBlack60Color()
        }


        showIfAlwaysVisible()
        view.bindFrameToSuperviewBounds()
    }

    func renderPlugins(_ plugins: [Element]) {
        let orderedPlugins = sortPluginsIfNeeded(plugins)
        orderedPlugins.forEach { plugin in
            mediaControlView.addSubview(plugin.view, in: plugin.panel, at: plugin.position)

            do {
                try ObjC.catchException {
                    plugin.render()
                }
            } catch {
                Logger.logError("\((plugin as Plugin).pluginName) crashed during render (\(error.localizedDescription))", scope: "MediaControl")
            }
        }
    }

    private func sortPluginsIfNeeded(_ plugins: [Element]) -> [Element] {
        if let pluginsOrder = core?.options[kMediaControlPluginsOrder] as? [String] {
            var orderedPlugins = [Element]()
            pluginsOrder.forEach { pluginName in
                if let selectedPlugin = plugins.first(where: { $0.pluginName == pluginName }) {
                    orderedPlugins.append(selectedPlugin)
                } else {
                    Logger.logInfo("Plugin \(pluginName) not found.")
                }
            }
            orderedPlugins.append(contentsOf: plugins.filter { !pluginsOrder.contains($0.pluginName) })

            return orderedPlugins
        }

        return plugins
    }

    private func showIfAlwaysVisible() {
        if alwaysVisible {
            show()
        }
    }

    fileprivate func toggleVisibility() {
        if showControls {
            show(animated: true) { [weak self] in
                self?.disappearAfterSomeTime(self?.longTimeToHideMediaControl)
            }
        }
    }

    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}
