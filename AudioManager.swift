//
//  AudioManager.swift
//  MusicPlayer
//
//  Created by Sonia Khan on 3/14/23.
//

import Foundation
import AVKit
import CoreAudioKit

class AudioManager: ObservableObject {
    var player: AVAudioPlayer?
    
    
    func initPlayer(ArtistSongFile: String) {
        
        let songLink = URL(string: ArtistSongFile)
        URLSession.shared.dataTask(with: songLink!) { [weak self] data, response, error in guard let self = self else { return }
            if let error = error {
                print("Failed to fetch audio file:", error)
                return
            }

            guard let data = data else {
                print("No data received for audio file")
                return
            }
            
            do {
                self.player = try AVAudioPlayer(data: data)
                self.player?.prepareToPlay()
                self.player?.play()
            } catch {
                print("Failed to initialize audio player:", error)
            }
        }.resume()
    }
    
    func startPlayer(ArtistSongFile: String) {
        self.player?.play()
    }
    
    func pausePlayer(ArtistSongFile: String) {
        self.player?.pause()
    }
    
    func current() -> TimeInterval {
        return self.player?.currentTime ?? 0
    }
    
    func duration() -> TimeInterval {
        return self.player?.duration ?? 1
    }
}

