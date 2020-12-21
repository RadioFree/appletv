//
//  ViewController.swift
//  radiofree
//
//  Created by Severin Kämpfer on 01.01.20.
//  Copyright © 2020 Severin Kämpfer. All rights reserved.
//

import UIKit
import Alamofire
import Foundation
import SwiftyJSON
import AVKit
import SwiftGifOrigin

class ViewController: UIViewController {
    @IBOutlet var upAndDown: UISwipeGestureRecognizer!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titlabl: TitleLabel!
    @IBOutlet weak var loadingImage: UIImageView!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var videoNavigation: UIProgressView!
   var stopAndNavigate: UITapGestureRecognizer!
    var leave: UITapGestureRecognizer!
    @IBOutlet weak var loadingViewLayer: UIView!
    @IBOutlet var rightGesture: UISwipeGestureRecognizer!
    var touchCount = 0
    
    @IBOutlet var leftGesture: UISwipeGestureRecognizer!
    
    @IBOutlet weak var textContent: UITextView!
    
    @IBOutlet weak var authorname: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var calendar: UIImageView!
    
    @IBOutlet weak var imgview: UIImageView!
    var inVideoNavigation = false
    var lyer: AVPlayerLayer? = nil
    var hiddenRect: CGRect!
    var articleQeue: [Article] = []
    
    var currentDisplaying = 0 {
        didSet{
            
        }
    }
    var loaded: [Int] = []
    var downloadingService: Downloader!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        contentView.backgroundColor = UIColor(red:1.00, green:0.86, blue:0.08, alpha:1.0)
        rightGesture.isEnabled = false
        leftGesture.isEnabled = false
        imgview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imgview.contentMode = .scaleAspectFit
        hiddenRect = contentView.bounds
        loadingViewLayer.backgroundColor = UIColor.black
        contentView.isHidden = true
        imgview.isHidden = false 
        downloadingService = Downloader()
        downloadingService.parent = self
        downloadingService.fchArts()
        self.view.bringSubviewToFront(loadingImage)
      startLoadingGif()
        stopAndNavigate = UITapGestureRecognizer(target: self, action: #selector(stopandnavigate))
        stopAndNavigate!.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue), NSNumber(value: UIPress.PressType.select.rawValue)];
        self.view.addGestureRecognizer(stopAndNavigate!)
        leave = UITapGestureRecognizer(target: self, action: #selector(forceLeave))
        leave!.allowedPressTypes = [NSNumber(value: UIPress.PressType.select.rawValue)];
        contentView.addGestureRecognizer(leave)
        
    }
    @objc func forceLeave(){
        contentView.fadeIn(to: hiddenRect)
        upAndDown.isEnabled = true
        stopAndNavigate!.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue), NSNumber(value: UIPress.PressType.select.rawValue)];
        backButton.isEnabled = false
        backButton.isUserInteractionEnabled = false
        stopAndNavigate.isEnabled = true
        textContent.isUserInteractionEnabled = false
        textContent.isSelectable = false
        textContent.isScrollEnabled = false
        rightGesture.isEnabled = true
        leftGesture.isEnabled = true
        leave.isEnabled = false
    }
    func initialShowUp(){
        //This function gets triggered by the downloader as soon as everything is great :)
        print(currentDisplaying)
        navigate(goForward: nil)
    }
    func pausingLoadingGif(){
        loadingViewLayer.isHidden = true
        loadingImage.image = .none
    }
    func startLoadingGif(){
loadingViewLayer.isHidden = false
        self.view.bringSubviewToFront(loadingViewLayer)
                let gif = UIImage.gif(name: "loading")
        loadingImage.backgroundColor = UIColor.black

        loadingImage.image = gif
        self.view.bringSubviewToFront(loadingImage)
    }
    func removeFromMemory(place: Int){
        
        downloadingService.Artikel[place].player?.replaceCurrentItem(with: nil)
        downloadingService.Artikel[place].asset?.cancelLoading()
        downloadingService.Artikel[place].playerItem = nil
        downloadingService.Artikel[place].isActiveVideo = false
        downloadingService.Artikel[place].readyForPlay = false
        lyer = nil
        downloadingService.Artikel[place].removeFromMemory()

    }
    func loadVideo(place: Int){
        if(place + 1 <= self.downloadingService.Artikel.count){
             downloadingService.Artikel[place].preload()
        print("loadVideo")
        }
    }
        
    func navigate(goForward: Bool?){
        
        if(goForward == true){
            for i in downloadingService.Artikel{
                i.player?.pause()
                i.isActiveVideo = false
            }
            startLoadingGif()

            print("pausing current")
            print(currentDisplaying)
            print(loaded)
            downloadingService.Artikel[currentDisplaying].player!.pause()
            if(currentDisplaying + 3 <= downloadingService.Artikel.count - 1){
                print("can still move freely")
                removeFromMemory(place: loaded.first!)
                loaded.removeFirst()
                loaded.append(currentDisplaying + 3)
                loadVideo(place: currentDisplaying + 3)
                currentDisplaying += 1
            
                
            }else{
                print("can make steps in our loaded")
                if(currentDisplaying != downloadingService.Artikel.count - 1){
                    print("lets get it")
                    removeFromMemory(place: loaded.first!)
                    loaded.removeFirst()
                    print("removing the first")

                    currentDisplaying += 1
                    print(currentDisplaying)
                    loadVideo(place: currentDisplaying + 1)

                    loaded.append(currentDisplaying)
                    
                }else{
                    print("that was the last one")
                }
            }
            updateView()

        }else if(goForward == false){
            for i in downloadingService.Artikel{
                i.player?.pause()
                i.isActiveVideo = false
            }
        downloadingService.Artikel[currentDisplaying].player!.pause()
            

            if(currentDisplaying + 2 == downloadingService.Artikel.count && currentDisplaying != 0){
                //Can go two before and will go back.
           
           
              
                if(currentDisplaying - 1 >= 0){
                    let k = loaded.count
                    print(k)
                   
                    let newlast = loaded[1]
                    let newmiddle = loaded[0]
                   
                    downloadingService.Artikel[loaded[0]].player!.pause()
                    downloadingService.Artikel[loaded[0]].isActiveVideo = false
                    downloadingService.Artikel[loaded[1]].player!.pause()
                    downloadingService.Artikel[loaded[1]].isActiveVideo = false
                    if(loaded.count == 3){
                        if(downloadingService.Artikel[loaded[2]].player != nil){
                            downloadingService.Artikel[loaded[2]].player!.pause()
                            downloadingService.Artikel[loaded[2]].isActiveVideo = false
removeFromMemory(place: loaded[2])

                        }
                    }
                  
                    loaded.removeAll()
                    loaded.append(currentDisplaying - 1)
                    loadVideo(place: currentDisplaying - 1)
                    loaded.append(newmiddle)
                    loaded.append(newlast)
                    currentDisplaying -= 1
                    
                }else{
                    print("Upsi thats the end.")
                }
            }else if(currentDisplaying + 1 == downloadingService.Artikel.count - 1 && currentDisplaying != 0){
                //Can load one before and will go back
                print("load one")
               
                    let newlast = loaded[0]
                    downloadingService.Artikel[newlast].player!.pause()
                    downloadingService.Artikel[newlast].isActiveVideo = false

                    loaded.removeAll()
                    loaded.append(currentDisplaying - 1)
                    loadVideo(place: currentDisplaying - 1)
                    loaded.append(newlast)
                    currentDisplaying -= 1
               
            }else{
                //Can loade 0, but will go back
                if(currentDisplaying != 0){
                currentDisplaying -= 1
                    var cd = loaded.last
                loaded.removeAll()
                
                loaded.append(currentDisplaying)
                    loaded.append(cd!)
                loadVideo(place: currentDisplaying)
                }
            }
            updateView()

        
        }else{
            //Firt navigation, load up all 3.
            for i in 0...2{
                if(i <= downloadingService.Artikel.count){
                loaded.append(i)
                    downloadingService.Artikel[i].preload()
                    downloadingService.Artikel[i].gts()
                }
            }
            
            updateView()
            rightGesture.isEnabled = true
            leftGesture.isEnabled = true
        }
    }
    func updateView(){
        
        if let lyer = lyer{
            lyer.removeFromSuperlayer()
        }
        textContent.text = ""

        lyer =   AVPlayerLayer(player:  downloadingService.Artikel[currentDisplaying].player)

        if let lyer = lyer{
            lyer.videoGravity = .resizeAspect
            lyer.frame = self.view.bounds
        }

 if let lyer = lyer{
    self.view.layer.addSublayer(lyer)
        }

        titlabl.text = downloadingService.Artikel[currentDisplaying].title!.string

        downloadingService.Artikel[currentDisplaying].isActiveVideo = true
        var content = downloadingService.Artikel[currentDisplaying].content?.string
        textContent.text = content?.replacingOccurrences(of: #"<\/em>"#, with: " ").replacingOccurrences(of: #"<\/p>"#, with: " ").replacingOccurrences(of: #"\a"#, with: #" "#)
        
        

        authorname.text = downloadingService.Artikel[currentDisplaying].author
        postDate.text = downloadingService.Artikel[currentDisplaying].created
        if(downloadingService.Artikel[currentDisplaying].featuredImage != nil){
            imgview.image = downloadingService.Artikel[currentDisplaying].featuredImage
        }else{
            imgview.image = .none
        }

    }
    func encd(text: String){
        
        var din = ""
        let data = Data(text.utf8)
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            din.append(attributedString.string)
        }
        din.removeArtefacts()
        print(din)
    }
    @IBAction func showContent(_ sender: Any) {
       print("detection")
        self.view.bringSubviewToFront(contentView)
        stopAndNavigate!.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)];
contentView.fadeIn(duration: 0.005, to: self.view.bounds)
        upAndDown.isEnabled = false
        rightGesture.isEnabled = false
        leftGesture.isEnabled = false
        backButton.isEnabled = true
        stopAndNavigate.isEnabled = false
        leave.isEnabled = true
        textContent.isUserInteractionEnabled = true
        textContent.isSelectable = true
        textContent.isScrollEnabled = true
        textContent.panGestureRecognizer.allowedTouchTypes = [UITouch.TouchType.indirect.rawValue] as [NSNumber]
       
    }
    
    @IBAction func getBack(_ sender: Any) {
        contentView.fadeIn(to: hiddenRect)
        upAndDown.isEnabled = true
        stopAndNavigate!.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue), NSNumber(value: UIPress.PressType.select.rawValue)];
        backButton.isEnabled = false
backButton.isUserInteractionEnabled = false
       stopAndNavigate.isEnabled = true
        textContent.isUserInteractionEnabled = false
        textContent.isSelectable = false
        textContent.isScrollEnabled = false
        rightGesture.isEnabled = true
        leftGesture.isEnabled = true
    }
    @IBAction func right(_ sender: Any) {
        //Next video
        if(inVideoNavigation){
            if(downloadingService.Artikel[currentDisplaying].player != nil){
                print("navigating in video")
               let onestep = 1.00 / currentPlayerDuration()
                var n = "First pos: "
                n.append(String(videoNavigation.progress))
                n.append(" Step; ")
                n.append(String(n))
                if(videoNavigation.progress + Float(onestep) != 1.00){
                videoNavigation.progress += Float(onestep)
                }
                n.append(" new pos: ")
                n.append(String(videoNavigation.progress))
                print(n)
                
            }

        }else{
            navigate(goForward: true)

        }
    }
    @IBAction func left(_ sender: Any) {
        //Last video
        if(inVideoNavigation){
            if(downloadingService.Artikel[currentDisplaying].player != nil){
                print("navigating in video")
                let onestep = 1.00 / currentPlayerDuration()
                var n = "First pos: "
                n.append(String(videoNavigation.progress))
                n.append(" Step; ")
                n.append(String(n))
                if(videoNavigation.progress - Float(onestep) != 0.00){
                    videoNavigation.progress -= Float(onestep)
                }
                n.append(" new pos: ")
                n.append(String(videoNavigation.progress))
                print(n)
                
            }
        }else{
            navigate(goForward: false)

        }
    }
    func currentPlayerTime() -> Double{
   return downloadingService.Artikel[currentDisplaying].player!.currentTime().seconds
    }
    
    @objc func stopandnavigate() {

            if(downloadingService.Artikel[currentDisplaying].player != nil){
                print("Allowing user interaction")
                if(touchCount == 0){
                    inVideoNavigation = true

                    downloadingService.Artikel[currentDisplaying].shortStop = true
                      downloadingService.Artikel[currentDisplaying].player!.pause()
                    touchCount += 1
                    videoNavigation.progress = 1.00 / Float(currentPlayerDuration()) * Float(currentPlayerTime())
                    var d = "Current video location: "
                    d.append(String(1.00 / Float(currentPlayerDuration()) * Float(currentPlayerTime())))
                    print(d)
                    self.view.bringSubviewToFront(videoNavigation)
                    videoNavigation.isHidden = false
                    upAndDown.isEnabled = false
                }else{
                    let newpos = videoNavigation.progress *  Float(currentPlayerDuration())
                    print(String(newpos))
                      downloadingService.Artikel[currentDisplaying].player!.seek(to: CMTime(seconds: Double(newpos), preferredTimescale: 60000))
                       downloadingService.Artikel[currentDisplaying].player!.play()
                    inVideoNavigation = false
                    upAndDown.isEnabled = true
                    touchCount = 0
                    videoNavigation.isHidden = true
            }
          
        }
        
    
    }
    
    func currentPlayerDuration() -> Double{
        return downloadingService.Artikel[currentDisplaying].player!.currentItem!.duration.seconds
    }
   
}

