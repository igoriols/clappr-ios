import Foundation

@objc open class SharedData: NSObject {
    @objc public var storeDictionary = [String: Any]()
    @objc public weak var container: Container?
}
