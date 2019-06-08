//
//  Message.swift
//  ChatAppWithFirebase
//
//  Created by Nikolas on 23/05/2019.
//  Copyright © 2019 Nikolas Aggelidis. All rights reserved.
//


import UIKit
import Firebase


class Message: NSObject {
    
    
    var fromSenderUserId: String?
    var name: String?
    var text: String?
    var timestamp: NSNumber?
    var toReceiverUserId: String?
    var imageURL: String?
    var imageHeight: NSNumber?
    var imageWidth: NSNumber?
    var videoURL: String?
    
    func chatPartnerId() -> String? {
        
        guard let chatPartnerId = fromSenderUserId == Auth.auth().currentUser?.uid ? toReceiverUserId : fromSenderUserId else { return nil }
        
        return chatPartnerId
    }
    
    
    init(withDictionary dictionary: [String:AnyObject]) {
        
        super.init()
        
        fromSenderUserId = dictionary["fromSenderUserId"] as? String
        name = dictionary["name"] as? String
        text = dictionary["text"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        toReceiverUserId = dictionary["toReceiverUserId"] as? String
        imageURL = dictionary["imageURL"] as? String
        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber
        videoURL = dictionary["videoURL"] as? String
    }
}
