//
//  UserCell.swift
//  ChatAppWithFirebase
//
//  Created by Nikolas on 20/05/2019.
//  Copyright © 2019 Nikolas Aggelidis. All rights reserved.
//


import UIKit


class UserCell: UITableViewCell {

    
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
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupViews() {
        
        addSubview(profileImageView)
        
        //Define x, y, width, height anchors:
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
}
