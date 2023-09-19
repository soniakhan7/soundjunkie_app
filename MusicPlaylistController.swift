//
//  MusicPlaylistController.swift
//  MusicPlayer
//
//  Created by Sonia Khan on 4/22/23.
//

import Foundation
import UIKit

class MusicPlaylistController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GetJSONData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // segue knows destination controller
        let destController = segue.destination as! ViewController
        
        // finds the selected row index from the tableView
        let index = tableView.indexPathForSelectedRow
        
        // finds the matching row in the object array
        let selectedRowMP = musicplayerObjectArray[index!.row]
        
        // sets the selectedrow MP object to the destination controller object
        destController.SplitViewMP = selectedRowMP
    }
    
//    override func
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicplayerObjectArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCell(withIdentifier: "myCellID")
        let cellIndex = indexPath.row
        let song = musicplayerObjectArray[cellIndex]
        var content = myCell?.defaultContentConfiguration()
        
        content!.image = convertToImage(urlString: song.ArtistAlbumImage)
        content!.imageProperties.maximumSize = CGSize(width: 80, height: 80)
        
        content!.text = song.ArtistSongTitle
        content!.textProperties.font = UIFont.boldSystemFont(ofSize: 18)
        
        content!.secondaryText = song.ArtistName
        
        myCell!.contentConfiguration = content
        
        return myCell!
    }
    
    
    func convertToImage(urlString: String) -> UIImage {
        let imgURL = URL(string:urlString)!
        
        let imgData = try? Data(contentsOf: imgURL)
        print(imgData ?? "Error. Image does not exist at URL \(imgURL)")
        
        let img = UIImage(data: imgData!)
        
        return img!
    }
    
    var musicplayerObjectArray = [MusicPlayer]()
    
    
    func GetJSONData() {
        // Use the String address and convert it to a URL type
        let endPointString  = "https://raw.githubusercontent.com/soniakhan7/soundjunkie_app/main/songs.json"
        let endPointURL = URL(string: endPointString)
        
        // Pass it to the Data function
        let dataBytes = try? Data(contentsOf:endPointURL!)

        // Receive the bytes
        print(dataBytes!) // just for developers to see what is received. this will help in debugging

        if (dataBytes != nil) {
            // get the JSON Objects and convert it to a Dictionary
            let dictionary:NSDictionary = (try! JSONSerialization.jsonObject(with: dataBytes!, options:JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary

            print("Dictionary --:  \(dictionary) ---- \n") // for debugging purposes

                

            // Split the Dictionary into two parts. Keep the Songs Part and discard the other

            let mpDictionary = dictionary["Songs"]! as! [[String:AnyObject]]

            for index in 0...mpDictionary.count - 1  {

                // Dictionary to Single Object (Song)
                let singleSong = mpDictionary[index]
                
                // create the Music Player Object
                let mp = MusicPlayer()

                //reterive each object from the dictionary
                mp.ArtistName = singleSong["ArtistName"] as! String
                mp.ArtistSongTitle = singleSong["ArtistSongTitle"] as! String
                mp.ArtistAlbum = singleSong["ArtistAlbum"] as! String
                mp.ArtistLyrics = singleSong["ArtistLyrics"] as! String
                mp.ArtistAlbumImage = singleSong["ArtistAlbumImage"] as! String
                mp.ArtistGenre = singleSong["ArtistGenre"] as! String
                mp.ArtistWiki = singleSong["ArtistWiki"] as! String
                mp.ArtistSongFile = singleSong["ArtistSongFile"] as! String

                musicplayerObjectArray.append(mp)

            }
        }
    }
}
