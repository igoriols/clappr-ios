struct OverlayFactory {
    static func create(with core: Core) -> Overlay {
        let overlay = Overlay(options: core.options)

        Loader.shared.overlayPlugins.forEach { plugin in
            overlay.addPlugin(plugin.init(context: core))
        }

        return overlay
    }
}
