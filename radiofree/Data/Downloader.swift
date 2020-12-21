//
//  Downloader.swift
//  radiofree
//
//  Created by Severin Kämpfer on 01.01.20.
//  Copyright © 2020 Severin Kämpfer. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import UIKit
class Downloader: NSObject{
    
    var Artikel: [Article] = [] 
    
    
    var artsToLoad = 0 {
        didSet{
            if(self.artsToLoad > 0 && self.artsLoaded <= self.artIds.count - 1){
                print("load request")
                self.loadArt(id: artIds[self.artsLoaded], completion: { result in
                    print("got a response")
                    if let article = result {
                        self.Artikel.append(article)
                        self.artsToLoad -= 1
                    }
                })
            }else{
                self.parent.initialShowUp()
                
            }
        }
    }
    var artsLoaded = 0
    var artIds: [Int] = []
    
    var loadedAllIds = false
    var parent: ViewController!
    
    func fchArts(){
        AF.request("https://www.radiofree.org/wp-json/wp/v2/posts?categories=7722&per_page=100").responseJSON(completionHandler: {response in
                                                                                                                switch(response.result){
                                                                                                                case .success(let value):
                                                                                                                    let json = JSON(value)
                                                                                                                    //   print(json)
                                                                                                                    
                                                                                                                    for(index, object) in json{
                                                                                                                        self.artIds.append(object["id"].int!)
                                                                                                                        
                                                                                                                        
                                                                                                                    }
                                                                                                                    self.artsToLoad = json.array!.count
                                                                                                                    
                                                                                                                case .failure(_):
                                                                                                                    
                                                                                                                    print("error")
                                                                                                                    
                                                                                                                }})
    }
    
    func loadArt(id: Int, completion: @escaping (Article?) -> Void){
        var str = "https://www.radiofree.org/wp-json/wp/v2/posts/"
        
        str.append(String(id))
        
        
        AF.request(str).responseJSON(completionHandler: {response in
            switch(response.result){
            
            case .success(let value):
                let json = JSON(value)
                
                
                var title = ""
                let titObject = json["title"]
                title.append(titObject["rendered"].string!)
                var content = ""
                let contObject = json["content"]
                
                content.append(contObject["rendered"].rawString(options: [])!)
                var pld = #"<video controls src=""#
                if let zd = contObject["rendered"].string!.cut(from: #"<video controls src=""#, to: #""></video>"#) , let tryd = zd.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed) {
                    
                    pld.append(zd)
                    pld.append(#"\">"#)
                    var newarticle = Article()
                    newarticle.id = id
                    newarticle.source = URL(string: tryd)!
                    newarticle.title = title.convertHtmlToNSAttributedString
                    newarticle.playerlook = pld
                    newarticle.author = json["postauthor"].string!
                    newarticle.created = json["date"].string!.replacingOccurrences(of: "T", with: " ")
                    self.artsLoaded += 1
                    print("appended")
                    completion(newarticle)
                }
                else {
                    completion(nil)
                }
            case .failure(_):
                print("Error")
            }
        })
    }
    /*      func loadImage(loc: Int, url: URL){
     
     AF.download(url.absoluteString).responseData { response in
     if let data = response.value {
     do{
     let image =   UIImage(data: data)
     print("did load")
     for articel in self.Artikel{
     if(articel.id == loc){
     print("setting the image")
     
     articel.featuredImage = image
     }
     }
     }catch{
     
     }
     }
     }
     }*/
    
    /*   func target(id: Int){
     var str = "https://www.radiofree.org/wp-json/wp/v2/posts/"
     
     str.append(String(id))
     
     
     AF.request(str).responseJSON(completionHandler: {response in
     switch(response.result){
     
     case .success(let value):
     let json = JSON(value)
     
     
     var title = ""
     let titObject = json["title"]
     title.append(titObject["rendered"].string!)
     var content = ""
     let contObject = json["content"]
     
     content.append(contObject["rendered"].string!)
     let zd = contObject["rendered"].string!.cut(from: #"<video controls src=""#, to: #""></video>"#)
     let tryd = zd!.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
     
     var newarticle = Article()
     newarticle.id = id
     newarticle.source = URL(string: tryd!)!
     newarticle.title = title
     newarticle.author = json["postauthor"].string!
     newarticle.created = json["date"].string!.replacingOccurrences(of: "T", with: "")
     self.Artikel.append(newarticle)
     self.artsToLoad -= 1
     if(self.artsToLoad == 0){
     self.parent.initialShowUp()
     }
     case .failure(_):
     print("Error")
     }
     })
     
     
     
     }*/
    
    func loadImage(loc: Int, url: URL){
        
        AF.download(url.absoluteString).responseData { response in
            if let data = response.value {
                do{
                    let image =   UIImage(data: data)
                    print("did load")
                    for articel in self.Artikel{
                        if(articel.id == loc){
                            print("setting the image")
                            
                            articel.featuredImage = image
                        }
                    }
                }catch{
                    
                }
            }
        }
    }
    //The following part is not used, because currently all links are got from html parsing. but this party may be used, it would work.
    
    /* func fetchArticle(id: Int){
     let d = String(id)
     var url = "https://www.radiofree.org/wp-json/wp/v2/posts/"
     url.append(d)
     print("fetching article")
     print(String(id))
     AF.request(url).responseJSON(completionHandler: {response in
     
     switch(response.result){
     
     case .success:
     
     self.addArticlesWithVideo(id: id)
     case .failure(_):
     print("Error")
     }
     })
     }
     func addArticlesWithVideo(id: Int){
     
     let d = String(id)
     var url = "https://www.radiofree.org/wp-json/wp/v2/media?media_type=video&parent="
     url.append(d)
     print("Now requesting")
     print(url)
     AF.request(url).responseJSON(completionHandler: {response in
     switch(response.result){
     
     case .success(let value):
     let json = JSON(value)
     
     var count = 0
     for(index, object) in json{
     print("found entry")
     if(count == 0){
     print("found a video")
     print(id)
     let newarticle = Article()
     newarticle.id = id
     newarticle.loaded = false
     newarticle.source = object["source_url"].url!
     print("last component")
     print(object["source_url"].url!)
     newarticle.loaded = false
     self.Artikel.append(newarticle)
     count += 1
     print("foud a video")
     }
     }
     case .failure(_):
     print("Error")
     }
     })
     
     }
     
     func loadArticle(from: Int, amaountOfArticles: Int){
     /*    var target = from + amaountOfArticles
     var pointer = from
     while (pointer <= target){
     var name = "Downloading Qeue "
     name.append(String(pointer))
     pointer += 1
     
     let downloadTask = DispatchQueue(label: name)
     downloadTask.async {
     self.loadVideoForArticle(id: pointer)
     self.loadArticleContent(id: pointer)
     print("Downloading")
     }
     }*/
     }
     func loadVideoForArticle(id: Int){
     for arts in Artikel{
     if(id == arts.id!){
     
     var target = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
     
     target.appendPathExtension(arts.source!.lastPathComponent)
     
     AF.download(arts.source!).responseData { response in
     if let data = response.value {
     do{
     try data.write(to: target)
     arts.localUrl = target
     arts.loaded = true
     }catch let error{
     print("error")
     
     }
     }
     }
     
     }
     }
     }
     func loadArticleImage(id: Int, imageURL: URL){
     var target = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
     
     target.appendPathExtension(imageURL.lastPathComponent)
     AF.download(imageURL).responseData { response in
     if let data = response.value {
     do{
     let img = UIImage(data: data)
     for arts in self.Artikel{
     if(arts.id! == id){
     arts.featuredImage = img!
     }
     }
     }catch let error{
     print(error)
     }
     }
     
     }
     }
     func loadArticleContent(id: Int){
     /* let idstring = String(id)
     var str = "https://www.radiofree.org/wp-json/wp/v2/posts/"
     str.append(idstring)
     
     for arts in Artikel{
     if(arts.id! == id){
     AF.request(str).responseJSON(completionHandler: {response in
     switch(response.result){
     
     case .success(let value):
     let json = JSON(value)
     
     print(json)
     
     var title = ""
     let titObject = json["title"]
     title.append(titObject["rendered"].string!.convertUsable())
     print(titObject["rendered"].string!.convertUsable())
     var content = ""
     let contObject = json["content"]
     
     content.append(contObject["rendered"].string!.convertUsable())
     print(contObject["rendered"].string!.convertUsable())
     arts.title = title
     arts.content = content
     self.loadArticleImage(id: id, imageURL: json["featured_image_url"].url!)
     case .failure(_):
     print("Error")
     }
     })
     }
     }*/
     }*/
    
    
    func removeArtefacts(text: String) -> String{
        do{
            
            let regex = try NSRegularExpression(pattern: #"\<!-(.*?)\->"#, options: NSRegularExpression.Options.caseInsensitive)
            
            
            let range = NSMakeRange(0, text.count)
            return regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "")
            
            
        }catch let error{
            return ""
        }
    }
    func loadImages(){
        for art in self.Artikel{
            art.loadOwnContent()
        }
    }
    
}
