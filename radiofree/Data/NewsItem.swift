//
//  NewsItem.swift
//  radiofree
//
//  Created by Severin Kämpfer on 01.01.20.
//  Copyright © 2020 Severin Kämpfer. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import Alamofire
import SwiftyJSON
class Article: NSObject{
    var title: NSAttributedString?
    var content: NSAttributedString?
    var id: Int? = nil
    var playerlook = ""
    var source: URL? = nil
     var asset: AVAsset?
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    private var playerItemContext = 0
    
    let requiredAssetKeys = [
        "playable",
        "hasProtectedContent"
    ]
    var featuredImage: UIImage? = nil
    var created: String? = nil
    var author: String? = nil
    var shortStop = false
    var isActiveVideo = false {
        didSet{
            if(readyForPlay && self.isActiveVideo ){
                player!.play()
            }
        }
    }
    var readyForPlay = false {
        didSet{
            if(self.readyForPlay  && isActiveVideo && self.shortStop == false){
                player!.play()
            }
        }
    }
    func preload() {
        // Create the asset to play
        
        asset = AVAsset(url: source!)
        
        // Create a new AVPlayerItem with the asset and an
        // array of asset keys to be automatically loaded
        playerItem = AVPlayerItem(asset: asset!,
                                  automaticallyLoadedAssetKeys: requiredAssetKeys)
        playerItem!.preferredForwardBufferDuration = 40.00
        
        // Register as an observer of the player item's status property
        playerItem!.addObserver(self,
                               forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp),
                               options: [.old, .new],
                               context: &playerItemContext)
        
        // Associate the player item with the player
        player = AVPlayer(playerItem: playerItem!)
    }
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }
        
        if keyPath == #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp) {
            var status: Bool = false
            if let statusNumber = change?[.newKey] as? Bool {
                status = statusNumber
            } else {
            }
            if(status == true){
                print("likely to keep up")
               readyForPlay = true
            }else{
                print("unlikely to keep up")
            }
            
        }
    }
    func playerPlay(){
        do{
      try  self.player!.play()
        }catch{
            
        }
    }
    func goto(time: CMTime){
        
    }
    func removeFromMemory(){
        player!.pause()
        player = nil
        asset = nil
    playerItem = nil
    }
    func loadOwnContent(){
    gts()
    }
    func loadImage(url: URL){
        AF.download(url).responseData { response in
            if let data = response.value {
                do{
                    let image =  try UIImage(data: data)
                    self.featuredImage = image
                }catch{
                    
                }
                
            }
        }
    }
    func removeArtefacts(text: String) -> String{
        do{
            
            let regex = try NSRegularExpression(pattern: #"\<(.*?)\>"#, options: NSRegularExpression.Options.caseInsensitive)
            
            
            let range = NSMakeRange(0, text.count)
            let readyString = regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "")
            return readyString
            
        }catch let error{
            return ""
        }
    }
    func gts(){
        var url = "https://radiofree.org/wp-json/wp/v2/posts/"
        url.append(String(id!))
        if let url = URL(string: url) {
            do {
                let contents = try String(contentsOf: url)
                
                if(contents.contains("jpeg")){
                    let featImage = contents.cut(from: #"featured_image_url":""#, to: #"","#)
                  
                    let imgUrl = URL(string:  featImage!.replacingOccurrences(of: #"https:\/\/"#, with: "https://").replacingOccurrences(of: #"\/"#, with: #"/"#))
                    if((imgUrl?.absoluteString.count)! > 0){
                        loadImage(url: imgUrl!)
                    }
                      if((imgUrl?.absoluteString.count)! > 0){
                        loadImage(url: imgUrl!)
                        
                    }
                }
                var text = contents.cut(from: #"content":{"rendered":""#, to: #"","protected":false}"#)?.getHTMLText().replacingOccurrences(of: #"\n"#, with: #""#)
                self.content = text?.convertHtmlToNSAttributedString
            }catch(let error){
                
            }
        } else {
            // the URL was bad!
        }
    }
    
}



    



