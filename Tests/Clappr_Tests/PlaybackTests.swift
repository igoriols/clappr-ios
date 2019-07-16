import Quick
import Nimble
@testable import Clappr

class PlaybackTests: QuickSpec {

    override func spec() {
        describe("Playback") {
            var playback: StubPlayback!
            let options: Options = [kSourceUrl: "http://globo.com/video.mp4"]

            beforeEach {
                playback = StubPlayback(options: options as Options)
            }

            describe("#name") {
                it("throws an exception because it is an `abstract` class") {
                    let expectedExceptionName = "MissingPlaybackName"
                    let expectedExceptionReason = "Playbacks should always declare a name. Playback does not."

                    expect(Playback.name).to(raiseException(named: expectedExceptionName, reason: expectedExceptionReason))
                }
            }

            it("sets frame of Playback to CGRect.zero") {
                expect(playback.view.frame) == CGRect.zero
            }

            it("sets backgroundColor to clear") {
                expect(playback.view.backgroundColor).to(beNil())
            }

            it("sets isUserInteractionEnabled to false") {
                expect(playback.view.isUserInteractionEnabled) == false
            }

            it("has a play method") {
                let responds = playback.responds(to: #selector(Playback.play))
                expect(responds).to(beTrue())
            }

            it("has a pause method") {
                let responds = playback.responds(to: #selector(Progress.pause))
                expect(responds).to(beTrue())
            }

            it("has a stop method") {
                let responds = playback.responds(to: #selector(NetService.stop))
                expect(responds).to(beTrue())
            }

            it("has a seek method receiving a time") {
                let responds = playback.responds(to: #selector(Playback.seek(_:)))
                expect(responds).to(beTrue())
            }

            it("has a duration var with a default value 0") {
                expect(playback.duration) == 0
            }

            it("have a type var with a default value Unknown") {
                expect(playback.playbackType).to(equal(PlaybackType.unknown))
            }

            it("has a isHighDefinitionInUse var with a default value false") {
                expect(playback.isHighDefinitionInUse).to(beFalse())
            }

            it("is removed from superview when destroy is called") {
                let container = UIView()
                container.addSubview(playback.view)

                expect(playback.view.superview).toNot(beNil())
                playback.destroy()
                expect(playback.view.superview).to(beNil())
            }

            it("stops listening to events after destroy has been called") {
                var callbackWasCalled = false

                playback.on("some-event") { _ in
                    callbackWasCalled = true
                }

                playback.destroy()
                playback.trigger("some-event")

                expect(callbackWasCalled) == false
            }

            it("has a class function to check if a source can be played with default value false") {
                let canPlay = Playback.canPlay([:])
                expect(canPlay) == false
            }

            it("has a canPlay flag set to false") {
                let playback = StubPlayback(options: [:])
                expect(playback.canPlay).to(beFalse())
            }

            it("has a canPause flag set to false") {
                let playback = StubPlayback(options: [:])
                expect(playback.canPause).to(beFalse())
            }

            it("has a canSeek flag set to false") {
                let playback = StubPlayback(options: [:])
                expect(playback.canSeek).to(beFalse())
            }

            context("StartAt") {
                it("set start at property from options") {
                    let playback = StubPlayback(options: [kStartAt: 10.0])
                    expect(playback.startAt) == 10.0
                }

                it("has startAt with 0 if no time is set on options") {
                    let playback = StubPlayback(options: [:])
                    expect(playback.startAt) == 0.0
                }

                context("when video is live") {
                    it("doesn't seek video when rendering if startAt is set") {
                        let playback = StubPlayback(options: [kStartAt: 15.0])
                        playback.type = .live
                        playback.render()
                        playback.play()
                        expect(playback.seekWasCalled).to(beFalse())
                    }
                }
            }

            context("Playback source") {
                it("has a source property with the url sent via options") {
                    let playback = StubPlayback(options: [kSourceUrl: "someUrl"])
                    expect(playback.source) == "someUrl"
                }

                it("has a source property with nil if no source is set") {
                    let playback = StubPlayback(options: [:])
                    expect(playback.source).to(beNil())
                }
            }

            describe("#options") {
                it("triggers didUpdateOptions when setted") {
                    var didUpdateOptionsTriggered = false
                    playback.on(Event.didUpdateOptions.rawValue) { _ in
                        didUpdateOptionsTriggered = true
                    }

                    playback.options = [:]

                    expect(didUpdateOptionsTriggered).toEventually(beTrue())
                }
            }
        }
    }

    class StubPlayback: Playback {
        var playWasCalled = false
        var seekWasCalled = false
        var seekWasCalledWithValue: TimeInterval = -1
        var type: PlaybackType = .unknown

        override class var name: String {
            return "stupPlayback"
        }

        override func play() {
            trigger(.ready)
            playWasCalled = true
        }

        override func seek(_ timeInterval: TimeInterval) {
            seekWasCalledWithValue = timeInterval
            seekWasCalled = true
        }

        override var playbackType: PlaybackType {
            return type
        }
    }
}
