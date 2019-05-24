//
//  Message.swift
//  ChatAppWithFirebase
//
//  Created by Nikolas on 23/05/2019.
//  Copyright © 2019 Nikolas Aggelidis. All rights reserved.
//


import UIKit


class Message: NSObject {
    
    
    var fromSenderUserId: String?
    var name: String?
    var text: String?
    var timestamp: NSNumber?
    var toReceiverUserId: String?
}
