// DISCLAIMER: This App is developed as an educational project. Certain materials are included under the fair use exemption of the
// U.S. Copyright Law and have been prepared according to the multimedia fair use guidelines and are restricted from further use.

//  ViewController.swift
//  MusicPlayer
//
//  Created by Sonia Khan on 3/13/23.
//
// * = highlighted sections

import UIKit
import AVKit // include this kit for sound
import AVFoundation

class ViewController: UIViewController {
    
    // variable function objects
    var SplitViewMP: MusicPlayer = MusicPlayer()
    var globalMP = MusicPlayer()
    var audioManager = AudioManager()
    var isPlaying: Bool = false
    var progressUpdateTimer: Timer?
    var isComplete: Bool = false
    
    // button, label, and slider app feature objects
    @IBOutlet weak var LblGenre: UILabel!
    @IBOutlet weak var LblAlbumCover: UIImageView!
    @IBOutlet weak var LblSongTitle: UILabel!
    @IBOutlet weak var LblArtistName: UILabel!
    @IBOutlet weak var LblAlbumName: UILabel!
    @IBOutlet weak var PausePlaybtn: UIButton!
    @IBOutlet weak var Backbtn: UIButton!
    @IBOutlet weak var Fwdbtn: UIButton!
    @IBOutlet weak var songProgressSlider: UISlider!
    @IBOutlet weak var LblProgress: UILabel!
    @IBOutlet weak var LblDuration: UILabel!
    @IBOutlet weak var Likebtn: UIButton!
    
    
    
   // loads app view
    override func viewDidLoad() {
        super.viewDidLoad()
        setLabels()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destController = segue.destination as! WebViewController
        
        if segue.identifier == "wikiSegue" {
            destController.receivedURL = URL(string: globalMP.ArtistWiki)
        } else if segue.identifier == "lyricsSegue" {
            destController.receivedURL = URL(string: globalMP.ArtistLyrics)
        }
    }
    
    // motion events
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        LblAlbumCover.alpha = 0
        LblSongTitle.alpha = 0
        LblAlbumName.alpha = 0
        LblArtistName.alpha = 0
        LblGenre.alpha = 0
        LblProgress.alpha = 0
        LblDuration.alpha = 0
        songProgressSlider.alpha = 0
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        UIView.animate(withDuration: 3, animations: {
            self.LblAlbumCover.alpha = 1
            self.LblSongTitle.alpha = 1
            self.LblAlbumName.alpha = 1
            self.LblArtistName.alpha = 1
            self.LblGenre.alpha = 1
            self.LblProgress.alpha = 1
            self.LblDuration.alpha = 1
            self.songProgressSlider.alpha = 1
        })
        btnShuffle((Any).self) // * triggers another button action function
    }
    
    
    // built-in button/slider functions
    @IBAction func btnPlaySong(_ sender: UIButton) {
        if isPlaying {
            isPlaying = false
            PausePlaybtn.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            audioManager.pausePlayer(ArtistSongFile: globalMP.ArtistSongFile)
            stopProgressUpdateTimer() // * stops timer aligned with slider and song playing
        } else {
            isPlaying = true
            PausePlaybtn.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
            if isComplete {
                isComplete = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.audioManager.startPlayer(ArtistSongFile: self.globalMP.ArtistSongFile)
                    self.startProgressUpdateTimer()
                }
            } else {
                audioManager.startPlayer(ArtistSongFile: globalMP.ArtistSongFile)
                startProgressUpdateTimer() // * begins timer aligned with slider and song playing (continues where it left off)
            }
        }
    }
    
    @IBAction func btnLikeIt(_ sender: Any) {
        
        if Likebtn.currentImage == UIImage(systemName: "heart") {
            Likebtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            UserDefaults.standard.set(LblSongTitle.text, forKey: "favorite")
        } else {
            Likebtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            UserDefaults.standard.set("", forKey: "favorite")
        }
    }
    
    @IBAction func btnShuffle(_ sender: Any) {
        stopProgressUpdateTimer()
        isPlaying = false
        setLabels(rand: true)
    }
    
    @IBAction func songProgressSliderValueChanged(_ sender: UISlider) { // * value change function to update slider with timer
        
        let newPlaybackTime = TimeInterval(sender.value) * audioManager.duration()
        audioManager.player!.currentTime = newPlaybackTime
        
    }

    @IBAction func btnBackTen(_ sender: UIButton) { // * goes back 10 seconds in audio player & updates slider
        let currentTime = audioManager.current()
        
        if currentTime - 10.0 < 0.0 {
            audioManager.player!.currentTime = 0.0
        } else {
            audioManager.player!.currentTime -= 10.0
        }
        updateProgress(currentTime: audioManager.current(), durationTime: audioManager.duration())
    }

    @IBAction func btnFwdTen(_ sender: Any) { // * goes forward 10 seconds in audio player & updates slider
        let currentTime = audioManager.current()
        let duration = audioManager.duration()
        
        if currentTime + 10.0 > duration {
            audioManager.player!.currentTime = duration
        } else {
            audioManager.player!.currentTime += 10.0
        }
        updateProgress(currentTime: audioManager.current(), durationTime: audioManager.duration())
    }
    
    func convertToImage(urlString: String) -> UIImage {
        let imgURL = URL(string:urlString)!
        
        let imgData = try? Data(contentsOf: imgURL)
        print(imgData ?? "Error. Image does not exist at URL \(imgURL)")
        
        let img = UIImage(data: imgData!)
        
        return img!
    }
    
    // created functions
    func setLabels(rand: Bool = false) {
        
        let selectedSong = SplitViewMP
        
        globalMP = selectedSong
        LblArtistName.text =  selectedSong.ArtistName
        LblSongTitle.text =  selectedSong.ArtistSongTitle
        LblAlbumName.text =  selectedSong.ArtistAlbum
        LblAlbumCover.image = convertToImage(urlString: selectedSong.ArtistAlbumImage)
        LblGenre.text =  selectedSong.ArtistGenre
        audioManager.initPlayer(ArtistSongFile: globalMP.ArtistSongFile) // * must initialize audio to get the song's duration
    
        LblProgress.text = formatTime(TI:audioManager.current())
        LblDuration.text = formatTime(TI:audioManager.duration())
        
        isPlaying = false
        PausePlaybtn.sendActions(for: .touchUpInside) // * triggers another button action by button name
        
        let like = UserDefaults.standard.string(forKey: "favorite")
        
        if like == selectedSong.ArtistSongTitle {
            Likebtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            Likebtn.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
    
    func formatTime(TI: TimeInterval) -> String { // * changes TimeInterval: Double format to minutes:seconds for progress label
        let minutes = Int(TI / 60)
        let seconds = Int(TI.truncatingRemainder(dividingBy: 60))
        if String(seconds).count == 1 {
            return String(minutes) + ":0" + String(seconds)
        } else {
            return String(minutes) + ":" + String(seconds)
        }
    }
    
    func updateProgress(currentTime: TimeInterval, durationTime: TimeInterval) { // * gets audio progress and audio length
        if LblProgress.text == LblDuration.text {
            isComplete = true
            LblProgress.text = formatTime(TI: currentTime)
            stopProgressUpdateTimer()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.btnShuffle((Any).self)
            }
        }
        
        LblProgress.text = formatTime(TI: currentTime)
        LblDuration.text = formatTime(TI: durationTime)
        songProgressSlider.value = Float(currentTime) / Float(durationTime)
    }

    func startProgressUpdateTimer() { // * begins timer with 10 milliseconds intervals
        progressUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            self.updateProgress(currentTime: self.audioManager.current(), durationTime: self.audioManager.duration())
        }
    }
    
    func stopProgressUpdateTimer() { // * stops timer
        progressUpdateTimer?.invalidate()
    }
}

