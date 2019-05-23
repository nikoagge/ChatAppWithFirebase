//
//  ChatLogController.swift
//  ChatAppWithFirebase
//
//  Created by Nikolas on 22/05/2019.
//  Copyright © 2019 Nikolas Aggelidis. All rights reserved.
//


import UIKit
import Firebase


class ChatLogController: UICollectionViewController, UITextFieldDelegate {

    
    let containerView: UIView = {
       
        let cv = UIView()
        cv.translatesAutoresizingMaskIntoConstraints = false
        
        return cv
    }()
    
    let sendButton: UIButton = {
        
        let sb = UIButton(type: .system)
        sb.setTitle("Send", for: .normal)
        sb.translatesAutoresizingMaskIntoConstraints = false
        sb.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        
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
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationItem.title = "Chat Log Controller"
        
        collectionView.backgroundColor = .white
        
        setupInputComponents()
    }
    
    
    func setupInputComponents() {
        
        view.addSubview(containerView)
        
        containerView.addSubview(sendButton)
        containerView.addSubview(inputMessageTextField)
        containerView.addSubview(separatorLineView)
        
        //Set x, y, width, height constraints for containerView:
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //Set x, y, width, height constraints for sendButton:
        sendButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        //Set x, y, width, height constraints for inputMessageTextField:
        inputMessageTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant:  8).isActive = true
        inputMessageTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputMessageTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputMessageTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        //Set x, y, width, height constraints for separatorLineView:
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    
    @objc func sendButtonTapped() {
        
        let firebaseDatRef = Database.database().reference().child("messages")
        let childRef = firebaseDatRef.childByAutoId()
        
        guard let inputMessageText = inputMessageTextField.text else { return }
        
        let dictionaryOfValues = ["text": inputMessageText]
        
        childRef.updateChildValues(dictionaryOfValues)
    }
    
    
    //Whenever we hit enter this function is called:
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        sendButtonTapped()
        
        return true
    }
}
