//
//  JSONExtension.swift
//  radiofree
//
//  Created by Severin Kämpfer on 01.01.20.
//  Copyright © 2020 Severin Kämpfer. All rights reserved.
//

import SwiftyJSON
import Foundation
extension JSON {
    public var date: NSDate? {
        get {
            if let str = self.string {
                return JSON.jsonDateFormatter.date(from: str) as NSDate?
            }
            return nil
        }
    }
    
    private static let jsonDateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        fmt.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
        return fmt
    }()
}
