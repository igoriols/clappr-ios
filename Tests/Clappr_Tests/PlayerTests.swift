import Quick
import Nimble
import AVFoundation

@testable import Clappr

class PlayerTests: QuickSpec {
    static let specialSource = "specialSource"

    override func spec() {
        describe(".Player") {
            let options: Options = [kSourceUrl: "http://clappr.com/video.mp4"]
            var player: Player!
            var playback: Playback!

            context("#init") {
                context("when listening Playback events") {
                    var callbackWasCalled = false

                    beforeEach {
                        Loader.shared.resetPlugins()
                        Player.register(playbacks: [SpecialStubPlayback.self, StubPlayback.self])
                        player = Player(options: options)
                        playback = player.activePlayback
                        callbackWasCalled = false
                    }

                    it("calls a callback function to handle ready event") {
                        player.on(.ready) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.ready)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle error event") {
                        player.on(.error) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.error)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle didComplete event") {
                        player.on(.didComplete) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.didComplete)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle didPause event") {
                        player.on(.didPause) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.didPause)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle didStop event") {
                        player.on(.didStop) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.didStop)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle stalling event") {
                        player.on(.stalling) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.stalling)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle didUpdateBuffer event") {
                        player.on(.didUpdateBuffer) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.didUpdateBuffer)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle didUpdatePosition event") {
                        player.on(.didUpdatePosition) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.didUpdatePosition)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle didUpdateAirPlayStatus event") {
                        player.on(.didUpdateAirPlayStatus) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.didUpdateAirPlayStatus)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle willPlay event") {
                        player.on(.willPlay) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.willPlay)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle playing event") {
                        player.on(.playing) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.playing)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle willPause event") {
                        player.on(.willPause) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.willPause)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle willStop event") {
                        player.on(.willStop) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.willStop)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle willSeek event") {
                        player.on(.willSeek) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.willSeek)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle didSeek event") {
                        player.on(.didSeek) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.didSeek)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle didSelectSubtitle event") {
                        player.on(.didSelectSubtitle) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.didSelectSubtitle)

                        expect(callbackWasCalled).to(beTrue())
                    }

                    it("calls a callback function to handle didSelectAudio event") {
                        player.on(.didSelectAudio) { _ in
                            callbackWasCalled = true
                        }
                        playback.trigger(.didSelectAudio)

                        expect(callbackWasCalled).to(beTrue())
                    }

                }

                context("core dependency") {
                    it("is initialized") {
                        let player = Player(options: options)
                        expect(player.core).toNot(beNil())
                    }

                    it("has active container") {
                        let player = Player(options: options)
                        expect(player.core?.activeContainer).toNot(beNil())
                    }
                }

                context("external playbacks") {
                    it("sets external playback as active") {
                        Loader.shared.resetPlaybacks()
                        Player.register(playbacks: [StubPlayback.self])
                        let player = Player(options: [kSourceUrl: "video"])

                        expect(player.activePlayback).to(beAKindOf(StubPlayback.self))
                    }

                    it("changes external playback based on source") {
                        Loader.shared.resetPlaybacks()
                        Player.register(playbacks: [SpecialStubPlayback.self])
                        let player = Player(options: options)

                        player.load(PlayerTests.specialSource)

                        expect(player.activePlayback).to(beAKindOf(SpecialStubPlayback.self))
                    }
                }

                context("third party plugins") {
                    it("pass plugins to core") {
                        Loader.shared.resetPlugins()

                        Player.register(plugins: [LoggerPlugin.self])
                        player = Player(options: options)

                        let loggerPlugin = player.getPlugin(name: LoggerPlugin.name)
                        expect(loggerPlugin).to(beAKindOf(LoggerPlugin.self))
                    }
                    
                    it("pass plugins to container") {
                        Loader.shared.resetPlugins()
                        
                        Player.register(plugins: [FakeContainerPlugin.self])
                        player = Player(options: options)
                        
                        let fakeContainerPlugin = player.getPlugin(name: FakeContainerPlugin.name)
                        expect(fakeContainerPlugin).to(beAKindOf(FakeContainerPlugin.self))
                    }

                    it("pass plugins to Loader") {
                        Loader.shared.resetPlugins()

                        Player.register(plugins: [LoggerPlugin.self])
                        player = Player(options: options)

                        let loggerPlugin = Loader.shared.corePlugins.first { $0.name == LoggerPlugin.name }
                        expect(loggerPlugin).to(beAKindOf(LoggerPlugin.Type.self))
                    }

                    it("ignore plugins registered after player initialization") {
                        Loader.shared.resetPlugins()
                        Player.register(playbacks: [SpecialStubPlayback.self, StubPlayback.self])
                        player = Player(options: options)

                        Player.register(plugins: [LoggerPlugin.self])

                        let loggerPlugin = player.getPlugin(name: LoggerPlugin.name)
                        expect(loggerPlugin).to(beNil())
                    }
                }
            }

            describe("#configure") {
                it("changes Core options") {
                    Loader.shared.resetPlugins()
                    Player.register(playbacks: [SpecialStubPlayback.self, StubPlayback.self])
                    player = Player(options: options)
                    player.configure(options: ["foo": "bar"])

                    let playerOptionValue = player.core?.options["foo"] as? String

                    expect(playerOptionValue).to(equal("bar"))
                }
            }

            describe("#attachTo") {
                it("triggers didAttachView") {
                    let player = Player(options: [:])

                    var didTriggerEvent = false
                    player.listenTo(player.core!, eventName: Event.didAttachView.rawValue) { _ in
                        didTriggerEvent = true
                    }

                    player.core?.render()

                    expect(didTriggerEvent).to(beTrue())
                }
            }

            describe("lifecycle") {
                it("triggers events of destruction correctly") {
                    var triggeredEvents = [String]()
                    player = Player(options: options)
                    player.listenTo(player.core!, eventName: Event.didDestroy.rawValue) { _ in
                        triggeredEvents.append("core")
                    }
                    player.listenTo(player.activeContainer!, eventName: Event.didDestroy.rawValue) { _ in
                        triggeredEvents.append("container")
                    }
                    player.destroy()

                    expect(triggeredEvents).toEventually(equal(["container", "core"]))
                    expect(player.core).to(beNil())
                    expect(player.activeContainer).to(beNil())
                }
            }
        }
    }

    class StubPlayback: Playback {
        override class var name: String {
            return "StubPlayback"
        }

        override class func canPlay(_: Options) -> Bool {
            return true
        }
    }

    class SpecialStubPlayback: Playback {
        override class var name: String {
            return "SpecialStubPlayback"
        }

        override class func canPlay(_ options: Options) -> Bool {
            return options[kSourceUrl] as! String == PlayerTests.specialSource
        }
    }

    class LoggerPlugin: UICorePlugin {
        override class var name: String { return "Logger" }

        required init(context: UIObject) {
            super.init(context: context)
        }

        override public func bindEvents() {
            bindPlaybackEvents()
        }

        private func bindPlaybackEvents() {
            if let core = self.core {
                listenTo(core, eventName: Event.didChangeActivePlayback.rawValue) {  (_: EventUserInfo) in
                    print("Log didChangeActivePlayback!!!!")
                }
            }
        }
    }
    
    class FakeContainerPlugin: UIContainerPlugin {
        override class var name: String {
            return "FakeContainerPlugin"
        }

        override func bindEvents() { }
    }
}
