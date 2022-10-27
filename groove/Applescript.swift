import Foundation
import SwiftUI

extension NSAppleScript {
  static var itunesMusicName: String {
    if #available(OSX 10.15, *) {
      return "Music"
    } else {
      return "iTunes"
    }
  }
    
  static func itunesArtwork() -> String {
    return """
    if application "\(itunesMusicName)" is running then
    tell application "\(itunesMusicName)"
        if exists artworks of current track then
            return (get data of artwork 1 of current track)
        end if
    end tell
    end if
    """
  }
    
  static func loadSpotifyAlbumArtwork() -> String {
    return """
    if application "Spotify" is running then
        tell application "Spotify"
                return artwork url of current track
        end tell
    end if
    """
  }
    
  static func deleteAlbum() -> String {
    """
    if application "\(itunesMusicName)" is running then
        -- get the raw bytes of the artwork into a var
            tell application "\(itunesMusicName)" to tell artwork 1 of current track
                set srcBytes to raw data
        -- figure out the proper file extension
                if format is «class PNG » then
                    set ext to ".png"
                else
                    set ext to ".jpg"
                end if
            end tell
        -- get the filename to ~/Desktop/cover.ext
        set fileName to (((path to desktop) as text) & "cover" & ext)
        tell application "System Events"
            delete alias fileName
        end tell
    end if
    """
  }
}
