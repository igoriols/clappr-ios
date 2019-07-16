import MediaPlayer
import AVKit
import AVFoundation

class AVFoundationNowPlayingService {

    var nowPlayingBuilder: AVFoundationNowPlayingBuilder?

    func setBuilder(with options: Options) {
        let metaData: [String: Any] = options[kMetaData] ?? [:]
        nowPlayingBuilder = AVFoundationNowPlayingBuilder(metadata: metaData)
    }

    func setItems(to playerItem: AVPlayerItem, with options: Options) {
        setBuilder(with: options)
        let items = nowPlayingBuilder?.build() ?? []

        if !items.isEmpty {
            playerItem.externalMetadata = items
        }

        nowPlayingBuilder?.getArtwork(with: options) { artwork in
            if let artwork = artwork {
                playerItem.externalMetadata.append(artwork)
            }
        }
    }
}
