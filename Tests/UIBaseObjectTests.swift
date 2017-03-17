import Quick
import Nimble
import Clappr

class UIBaseObjectTests: QuickSpec {
    
    override func spec() {
        describe("UIBaseObject") {
            it("Should handle EventListeners callbacks when triggered") {
                let uiObject = UIBaseObject()
                var callbackWasCalled = false
                
                _ = uiObject.on("some-event") { userInfo in
                    callbackWasCalled = true
                }
                uiObject.trigger("some-event")
                
                expect(callbackWasCalled) == true
            }
        }
    }
}
