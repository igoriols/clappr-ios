import Quick
import Nimble

@testable import Clappr

class OptionsTests: QuickSpec {

    override func spec() {
        describe("Options") {
            it("inits and is accessible like a dictionary") {
                let options: Options = ["foo": "bar"]

                let value: String? = options["foo"]

                expect(value).to(equal("bar"))
            }

            it("replaces values when merging") {
                let options: Options = ["foo": "bar"]

                let newOptions = options.merging(["foo": "buzz"])

                let newValue: String? = newOptions["foo"]

                expect(newValue).to(equal("buzz"))
            }

            it("appends key-values when merging") {
                let options: Options = ["foo": "bar"]

                let newOptions = options.merging(["fizz": "buzz"])

                let newFoo: String? = newOptions["foo"]
                let newFizz: String? = newOptions["fizz"]

                expect(newFoo).to(equal("bar"))
                expect(newFizz).to(equal("buzz"))
            }

            describe("immutability") {
                it("does not change original options") {
                    let options: Options = ["foo": "bar"]

                    _ = options.merging(["foo": "biz", "fizz": "buzz"])

                    let oldFoo: String? = options["foo"]
                    let oldFizz: String? = options["fizz"]

                    expect(oldFoo).to(equal("bar"))
                    expect(oldFizz).to(beNil())
                }
            }
        }

        describe("Options+Ext") {
            describe("#double") {
                it("returns a Double value if it's a Double") {
                    let options: Options = [kStartAt: Double(10)]

                    expect(options.double(kStartAt, orElse: 0.0)).to(equal(10.0))
                }

                it("returns a Double value if it's a Int") {
                    let options: Options = [kStartAt: Int(10)]

                    expect(options.double(kStartAt, orElse: 0.0)).to(equal(10.0))
                }

                it("returns a Double value if it's a String") {
                    let options: Options = [kStartAt: String(10)]

                    expect(options.double(kStartAt, orElse: 0.0)).to(equal(10.0))
                }

                it("returns alternative if it's not a String, Int or Double") {
                    let options: Options = [kStartAt: []]

                    expect(options.double(kStartAt, orElse: 0.)).to(equal(0.0))
                }
            }

            describe("#generic subscript") {
                context("when key exists in optionsionary") {
                    it("returns value inside") {
                        let options: Options = ["foo": false]

                        let value: Bool? = options["foo"]
                        expect(value).to(beFalse())
                    }
                }

                context("when key does not exist in optionsionary") {
                    it("returns nil") {
                        let options: Options = [:]

                        let value: Bool? = options["foo"]

                        expect(value).to(beNil())
                    }
                }

                context("when value is of different type") {
                    it("returns nil") {
                        let options: Options = ["foo": 50]

                         let value: Bool? = options["foo"]

                        expect(value).to(beNil())
                    }
                }
            }
        }
    }
}
