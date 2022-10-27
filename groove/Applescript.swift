import Foundation
import SwiftUI

extension NSAppleScript {
  static var appleMusicName: String {
    if #available(OSX 10.15, *) {
      return "com.apple.Music"
    } else {
      return "iTunes"
    }
  }

  static func loadAppleMusicArtwork() -> String {
    return """
    tell application id "\(appleMusicName)"
      try
        if player state is not stopped then
            set alb to (get album of current track)
            tell artwork 1 of current track
                if format is JPEG picture then
                    set imgFormat to ".jpg"
                else
                    set imgFormat to ".png"
                end if
            end tell
            set rawData to (get raw data of artwork 1 of current track)
            return rawData
        else
            return
        end if
      on error
        return
      end try
    end tell
    """
  }

  static func loadSpotifyArtwork() -> String {
    return """
    if application "Spotify" is running then
        tell application "Spotify"
                return artwork url of current track
        end tell
    end if
    """
  }
}
