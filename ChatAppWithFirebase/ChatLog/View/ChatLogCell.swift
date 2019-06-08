//
//  ChatLogCell.swift
//  ChatAppWithFirebase
//
//  Created by Nikolas on 25/05/2019.
//  Copyright © 2019 Nikolas Aggelidis. All rights reserved.
//


import UIKit
import AVFoundation


class ChatLogCell: UICollectionViewCell {
    
    
    let textView: UITextView = {
        
        let tv = UITextView()
        tv.text = "Sample text"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.isEditable = false
        
        return tv
    }()
    
    let bubbleView: UIView = {
        
        let bv = UIView()
        bv.backgroundColor = blueColor
        bv.translatesAutoresizingMaskIntoConstraints = false
        bv.layer.cornerRadius = 16
        //In order to cornerRadius have effect on our view, set following as true:
        bv.layer.masksToBounds = true
        
        return bv
    }()
    
    let profileImageView: UIImageView = {
        
        let piv = UIImageView()
        piv.image = UIImage(named: "nedstark")
        piv.translatesAutoresizingMaskIntoConstraints = false
        //Set cornerRadius to half of profileImageView's width:
        piv.layer.cornerRadius = 16
        piv.layer.masksToBounds = true
        piv.contentMode = .scaleAspectFill
        
        return piv
    }()
    
    let messageImageView: UIImageView = {
        
        let miv = UIImageView()
        //miv.image = UIImage(named: "nedstark")
        miv.translatesAutoresizingMaskIntoConstraints = false
        miv.layer.cornerRadius = 16
        miv.layer.masksToBounds = true
        miv.contentMode = .scaleAspectFill
        miv.isUserInteractionEnabled = true
        
        miv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTapped)))
        
        
        return miv
    }()
    
    let playButton: UIButton = {
        
        let image = UIImage(named: "play")
        
        let pb = UIButton(type: .system)
        pb.setTitle("Play Video", for: .normal)
        pb.setImage(image, for: .normal)
        pb.tintColor = .white
        pb.translatesAutoresizingMaskIntoConstraints = false
        
        pb.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        
        return pb
    }()
    
    let activityIndicatorView: UIActivityIndicatorView = {
        
        let uiaiv = UIActivityIndicatorView(style: .whiteLarge)
        uiaiv.translatesAutoresizingMaskIntoConstraints = false
        uiaiv.hidesWhenStopped = true
        
        return uiaiv
    }()
    
    
    //In order to be bubbleView's widthAnchor accessible from ChatLogController set this variable:
    var bubbleViewWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    //To handle safer our variables-colors
    static let blueColor = UIColor.rgb(ofRed: 0, ofGreen: 137, ofBlue: 249)
    
    var chatLogController: ChatLogController?
    
    var message: Message?
    
    var player: AVPlayer?
    
    var playerLayer: AVPlayerLayer?
    
    
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
        addSubview(profileImageView)
        
        bubbleView.addSubview(messageImageView)
        bubbleView.addSubview(playButton)
        bubbleView.addSubview(activityIndicatorView)
        
        //Set x, y, width, height constraints for bubbleView:
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleViewRightAnchor!.isActive = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        //By default the following line is set to false, just showing it for demonstration purposes:
        //bubbleViewLeftAnchor?.isActive = false
        bubbleViewWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleViewWidthAnchor!.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        //Set x, y, width, height constraints for textView:
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        //In order to textView expand from left to right:
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        //Set x, y, width, heigt constraints for profileImageView:
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        //Set x, y, width, height constraints for messageImageView:
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        //Set x, y, width, height constraints for playButton:
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //Set x, y, width, height constraints for activityIndicatorView:
        activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    
    @objc func handleZoomTapped(forTapGesture tapGesture: UITapGestureRecognizer) {
        
        if message?.videoURL != nil {
            
            return
        }
        
        //It's best practice, not to perform lot of custom logic inside of a view class.
        
        guard let imageView = tapGesture.view as? UIImageView else { return }
        chatLogController?.performZoomIn(forStartingImageView: imageView)
    }
    
    
    @objc func playButtonTapped() {
        
        guard let videoURLString = message?.videoURL, let url = URL(string: videoURLString) else { return }
        
        player = AVPlayer(url: url)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = bubbleView.bounds
        
        bubbleView.layer.addSublayer(playerLayer!)
        
        activityIndicatorView.startAnimating()
        playButton.isHidden = true
        
        player?.play()
    }
    
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        playerLayer?.removeFromSuperlayer()
        
        player?.pause()
        
        activityIndicatorView.stopAnimating()
    }
}
