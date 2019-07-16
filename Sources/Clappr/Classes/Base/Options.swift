public let kPosterUrl = "posterUrl"
public let kSourceUrl = "sourceUrl"
public let kMediaControl = "mediaControl"
public let kFullscreen = "fullscreen"
public let kFullscreenDisabled = "fullscreenDisabled"
public let kFullscreenByApp = "fullscreenByApp"
public let kStartAt = "startAt"
public let kPlaybackNotSupportedMessage = "playbackNotSupportedMessage"
public let kMimeType = "mimeType"
public let kDefaultSubtitle = "defaultSubtitle"
public let kDefaultAudioSource = "defaultAudioSource"
public let kMinDvrSize = "minDvrSize"
public let kMediaControlAlwaysVisible = "mediaControlAlwaysVisible"

// List of MediaControl Plugins
public let kMediaControlPlugins = "mediaControlPlugins"
// Order of MediaControl Plugins
public let kMediaControlPluginsOrder = "mediaControlPluginsOrder"

public let kLoop = "loop"
public let kMetaData = "metadata"
public let kMetaDataContentIdentifier = "mdContentIdentifier"
public let kMetaDataWatchedTime = "mdWatchedTime"
public let kMetaDataTitle = "mdTitle"
public let kMetaDataDescription = "mdDescription"
public let kMetaDataDate = "mdDate"
public let kMetaDataArtwork = "mdArtwork"

struct OptionsUnboxer {
    let options: Options

    var fullscreenControledByApp: Bool {
        return options[kFullscreenByApp] as? Bool ?? false
    }

    var fullscreen: Bool {
        return options[kFullscreen] as? Bool ?? false
    }
}

@objc
public class Options: NSObject, ExpressibleByDictionaryLiteral {
    public typealias Key = String
    public typealias Value = Any

    private let innerStorage: [String: Any]

    required public init(dictionaryLiteral elements: (String, Any)...) {
        innerStorage = Dictionary(uniqueKeysWithValues: elements)
    }

    public init(_ dictionary: [String: Any]) {
        innerStorage = dictionary
    }

    public subscript (key: String) -> Any? {
        return innerStorage[key]
    }

    public __consuming func merging(_ other: __owned [String: Any]) -> Options {
        let newDictionary = innerStorage.merging(other, uniquingKeysWith: { _, second in second })
        return Options(newDictionary)
    }
}

extension Options {
    var startAt: Double? {
        switch self[kStartAt] {
        case is Double:
            return self[kStartAt] as? Double
        case let startAt as Int:
            return Double(startAt)
        case let startAt as String:
            return Double(startAt)
        default:
            return nil
        }
    }

    func double(_ option: String, orElse alternative: Double) -> Double {
        switch self[option] {
        case let startAt as Double:
            return startAt
        case let startAt as Int:
            return Double(startAt)
        case let startAt as String:
            return Double(startAt) ?? alternative
        default:
            return alternative
        }
    }

    func bool(_ option: String, orElse alternative: Bool = false) -> Bool {
        return get(option, orElse: alternative)
    }

    func get<T>(_ option: String, orElse alternative: T) -> T {
        if let value = self[option] as? T {
            return value
        }
        return alternative
    }
}
