//
//  StringExtension.swift
//  radiofree
//
//  Created by Severin Kämpfer on 02.01.20.
//  Copyright © 2020 Severin Kämpfer. All rights reserved.
//

import Foundation
import UIKit
extension String {
    func cut(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
   
    mutating func removeArtefacts(){
        do{

            let regex = try NSRegularExpression(pattern: #"\<!-(.*?)\->"#, options: NSRegularExpression.Options.caseInsensitive)


            let range = NSMakeRange(0, self.count)
            self = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "")

        
        }catch let error{
        }
    }
 func getHTMLText() -> String {
        
        do {
            let regex = try NSRegularExpression(pattern: #"\<p>(.*?)\<\\/p>"#)
            let results = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))
            let textIncludingOtherHTMLTags = results.map {
                String(self[Range($0.range, in: self)!])
            }
            var result = ""
            for element in textIncludingOtherHTMLTags{
              //  result.append(element.cut(from: #"<p>"#, to: #"<\/p>"#))
                result.append(element)
                result.append(" ")
            }
            
            return result
        } catch let error {
            print(error)
            return ""
        }
    }
    /*func convertToTitle() -> String{
        do{
         
            
        }catch let error{
            print(error)
            return(error as! String)
        }
        
    }*/
    func convertUsable() -> String{
        
        var din = ""
        let data = Data(self.utf8)
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            din.append(attributedString.string)
        }
    return din
    }
   
        
   
    var convertHtmlToNSAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        do {
            return try NSAttributedString(data: data,options: [.documentType: NSAttributedString.DocumentType.html,.characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    
    }


