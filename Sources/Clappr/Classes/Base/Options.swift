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
        return options[kFullscreenByApp] ?? false
    }

    var fullscreen: Bool {
        return options[kFullscreen] ?? false
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

    public subscript<T> (key: String) -> T? {
        return innerStorage[key] as? T
    }

    public subscript (key: String) -> Double? {
        if let value: Int = self[key] { return Double(value) }
        if let value: String = self[key] { return Double(value) }
        return innerStorage[key] as? Double
    }

    public __consuming func merging(_ other: __owned [String: Any]) -> Options {
        let newDictionary = innerStorage.merging(other, uniquingKeysWith: { _, second in second })
        return Options(newDictionary)
    }

    public func asDictionary() -> [String: Any] {
        return innerStorage
    }
}
