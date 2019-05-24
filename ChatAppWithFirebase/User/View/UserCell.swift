//
//  UserCell.swift
//  ChatAppWithFirebase
//
//  Created by Nikolas on 20/05/2019.
//  Copyright © 2019 Nikolas Aggelidis. All rights reserved.
//


import UIKit
import Firebase


class UserCell: UITableViewCell {

    
    var message: Message? {
        
        didSet {
            
            setupNameAndProfileImage()
            
            detailTextLabel?.text = message?.text
            
            guard let seconds = message?.timestamp?.doubleValue else { return }
            
            
            let timestampDate = NSDate(timeIntervalSince1970: seconds)
            
            //To give the date format I want, I do this:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm:ss a"
            
            timeLabel.text = dateFormatter.string(from: timestampDate as Date)
        }
    }
    
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        //x=56 because 8 pixels from left gap between imageView and the super view, 48 from widthanchor of imageView, 8 pixels from right gap between imageView and the textLabel.
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2 , width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        //Same one for the detailTextLabel.
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    
    let profileImageView: UIImageView = {
       
        let piv = UIImageView()
        //cornerRadius is the half of widthAnchor of imageView, 48 pixels thus we set it to 20 pixels.
        piv.layer.cornerRadius = 24
        piv.layer.masksToBounds = true
        piv.translatesAutoresizingMaskIntoConstraints = false
        piv.contentMode = .scaleAspectFill
        
        return piv
    }()
    
    let timeLabel: UILabel = {
        
        let tl = UILabel()
//        tl.text = "HH:MM:SS"
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.font = UIFont.systemFont(ofSize: 12)
        tl.textColor = .lightGray
        
        return tl
    }()
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupViews() {
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        //Define x, y, width, height anchors:
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        
        //Define x, y, width, height constraints for timeLabel:
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100)
        timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
    }
    
    
    private func setupNameAndProfileImage() {
        
        let chatPartnerId: String?
        
        if message?.fromSenderUserId == Auth.auth().currentUser?.uid {
            
            chatPartnerId = message?.toReceiverUserId
        } else {
            
            chatPartnerId = message?.fromSenderUserId
        }
        
        if let userId = chatPartnerId {
            
            let firebaseDatRef = Database.database().reference().child("users").child(userId)
            firebaseDatRef.observe(.value) { (dataSnapshot) in
                
                guard let dictionaryOfValues = dataSnapshot.value as? [String: AnyObject] else { return }
                
                self.textLabel?.text = dictionaryOfValues["name"] as? String
                
                guard let profileImageURL = dictionaryOfValues["profileImageURL"] as? String else { return }
                
                self.profileImageView.loadImageUsingCache(withURLString: profileImageURL)
            }
        }
    }
}
