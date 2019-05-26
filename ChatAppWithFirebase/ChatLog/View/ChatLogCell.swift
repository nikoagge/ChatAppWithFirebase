//
//  ChatLogCell.swift
//  ChatAppWithFirebase
//
//  Created by Nikolas on 25/05/2019.
//  Copyright © 2019 Nikolas Aggelidis. All rights reserved.
//


import UIKit


class ChatLogCell: UICollectionViewCell {
    
    
    let textView: UITextView = {
        
        let tv = UITextView()
        tv.text = "Sample text"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.textColor = .white
        
        return tv
    }()
    
    let bubbleView: UIView = {
        
        let bv = UIView()
        bv.backgroundColor = UIColor.rgb(ofRed: 0, ofGreen: 137, ofBlue: 249)
        bv.translatesAutoresizingMaskIntoConstraints = false
        bv.layer.cornerRadius = 16
        //In order to cornerRadius have effect on our view, set following as true:
        bv.layer.masksToBounds = true
        
        return bv
    }()
    
    //In order to be bubbleView's widthAnchor accessible from ChatLogController set this variable:
    var bubbleViewWidthAnchor: NSLayoutConstraint?
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupViews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupViews() {
        
        addSubview(bubbleView)
        addSubview(textView)
        
        //Set x, y, width, height constraints for bubbleView:
        bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleViewWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleViewWidthAnchor!.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        //Set x, y, width, height constraints for textView:
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        //In order to textView expand from left to right:
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
}
