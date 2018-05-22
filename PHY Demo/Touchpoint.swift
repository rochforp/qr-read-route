//
//  Touchpoint.swift
//  phy-browser
//
//  Created by john on 20/10/2017.
//  Copyright © 2017 com.bkon. All rights reserved.
//

import UIKit

enum TouchpointType: String {
    case unknown = "Unknown"
    case beacon = "Bluetooth Beacon"
    case qrcode = "QR Code"
    case nfc = "NFC"
    case persistent = "Persistent"
}

class Touchpoint: NSObject {
    
    var title: String!
    var content: String!
    var scanUrl: String!
    var destinationUrl: String!
    var headerImage: UIImage!
    var favouriteIcon: UIImage!
    var rssi: String!
    var txPower: String!
    var dateFavourited: String!

    var type: TouchpointType = .unknown
    var identifier: String!
    
    var waitingForMetadata = false
    
    override init() {
        super.init()
        identifier = generateRandomIdentifier(length: 10)
    }
    
    func generateRandomIdentifier(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
}
