//
//  ChatInputContainerView.swift
//  ChatAppWithFirebase
//
//  Created by Nikolas on 09/06/2019.
//  Copyright © 2019 Nikolas Aggelidis. All rights reserved.
//


import UIKit


class ChatInputContainerView: UIView, UITextFieldDelegate {

  
    var chatLogController: ChatLogController? {
        
        didSet {
            
            //In order to call a selector from the view, which belongs to Controller do this:
            sendButton.addTarget(chatLogController, action: #selector(ChatLogController.sendButtonTapped), for: .touchUpInside)
            
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(ChatLogController.uploadImageViewTapped)))
        }
    }
    
    let sendButton: UIButton = {
        
        let sb = UIButton(type: .system)
        sb.setTitle("Send", for: .normal)
        sb.translatesAutoresizingMaskIntoConstraints = false
        
        return sb
    }()
    
    lazy var inputMessageTextField: UITextField = {
        
        let imtf = UITextField()
        imtf.placeholder = "Enter message..."
        imtf.translatesAutoresizingMaskIntoConstraints = false
        imtf.delegate = self
        
        return imtf
    }()
    
    let separatorLineView: UIView = {
        
        let slv = UIView()
        slv.backgroundColor = .rgb(ofRed: 220, ofGreen: 220, ofBlue: 220)
        slv.translatesAutoresizingMaskIntoConstraints = false
        
        return slv
    }()
    
    lazy var uploadImageView: UIImageView = {
        
        let uiv = UIImageView()
        uiv.image = UIImage(named: "upload_image_icon")
        uiv.translatesAutoresizingMaskIntoConstraints = false
        uiv.isUserInteractionEnabled = true
//        uiv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(uploadImageViewTapped)))
        
        return uiv
    }()
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        backgroundColor = .white
        
        setupViews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupViews() {
        
        addSubview(sendButton)
        addSubview(inputMessageTextField)
        addSubview(separatorLineView)
        addSubview(uploadImageView)
        
        //Set x, y, width, height constraints for sendButton:
        sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        //Set x, y, width, height constraints for inputMessageTextField:
        inputMessageTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant:  8).isActive = true
        inputMessageTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        inputMessageTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputMessageTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        //Set x, y, width, height constraints for separatorLineView:
        separatorLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //Set x, y, width, height constraints for uploadImageView:
        uploadImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        //44 pixels is Apple's recommended size:
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    
    //Whenever we hit enter this function is called:
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        chatLogController?.sendButtonTapped()
        
        return true
    }
}
