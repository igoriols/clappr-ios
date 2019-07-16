import Quick
import Nimble

@testable import Clappr

class OptionsTests: QuickSpec {

    override func spec() {
        describe("Options") {
            it("inits and is accessible like a dictionary") {
                let options: Options = ["foo": "bar"]

                expect(options["foo"] as? String).to(equal("bar"))
            }

            it("replaces values when merging") {
                let options: Options = ["foo": "bar"]

                let newOptions = options.merging(["foo": "buzz"])

                expect(newOptions["foo"] as? String).to(equal("buzz"))
            }

            it("appends key-values when merging") {
                let options: Options = ["foo": "bar"]

                let newOptions = options.merging(["fizz": "buzz"])

                expect(newOptions["foo"] as? String).to(equal("bar"))
                expect(newOptions["fizz"] as? String).to(equal("buzz"))
            }

            describe("immutability") {
                it("does not change original options") {
                    let options: Options = ["foo": "bar"]

                    _ = options.merging(["foo": "biz", "fizz": "buzz"])

                    expect(options["foo"] as? String).to(equal("bar"))
                    expect(options["fizz"]).to(beNil())
                }
            }
        }
    }
}
