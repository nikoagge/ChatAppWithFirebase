//
//  ChatLogController.swift
//  ChatAppWithFirebase
//
//  Created by Nikolas on 22/05/2019.
//  Copyright © 2019 Nikolas Aggelidis. All rights reserved.
//


import UIKit
import Firebase


//Declare UICollectionViewDelegateFlowLayout in order to set the size of each collectionView's cell.
class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {

    
    let containerView: UIView = {
       
        let cv = UIView()
        cv.backgroundColor = .white
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
    
    var user: User? {
        
        didSet {
            
            navigationItem.title = user?.name
            
            observeUserMessages()
        }
    }
    
    var messages = [Message]()
    
    let cellIdentifier = "cellId"
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupInputComponents()
        setupCollectionView()
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
    
    
    func setupCollectionView() {
        
        //In order to the collectionView bounces vertical:
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        collectionView.register(ChatLogCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }
    
    
    @objc func sendButtonTapped() {
        
        let firebaseDatRef = Database.database().reference().child("messages")
        let childRef = firebaseDatRef.childByAutoId()
        
        guard let safelyUnwrappedInputMessageText = inputMessageTextField.text, let safelyUnwrappedUserName = user?.name, let safelyUnwrappedToReceiverUserId = user!.id, let safelyUnwrappedFromSenderUserId = Auth.auth().currentUser?.uid else { return }
        
        let timestamp = Int(NSDate().timeIntervalSince1970)
        
        let dictionaryOfValues = ["text": safelyUnwrappedInputMessageText, "name": safelyUnwrappedUserName, "fromSenderUserId": safelyUnwrappedFromSenderUserId, "toReceiverUserId": safelyUnwrappedToReceiverUserId, "timestamp": timestamp] as [String : Any]
        
        //childRef.updateChildValues(dictionaryOfValues)
        childRef.setValue(dictionaryOfValues) { (error, databaseRef) in
            
            if error != nil {
                
                print(error)
                
                return
            }
            
            //With this reference I create a subfolder user-messages for every sender((safelyUnwrappedFromSenderUserId):
            guard let messageId = childRef.key else { return }
            let senderUserMessagesRef = Database.database().reference().child("user-messages").child(safelyUnwrappedFromSenderUserId).child(messageId)
            senderUserMessagesRef.setValue([safelyUnwrappedFromSenderUserId: 1])
            
            let receiverUserMessagesRef = Database.database().reference().child("user-messages").child(safelyUnwrappedToReceiverUserId).child(messageId)
            receiverUserMessagesRef.setValue([safelyUnwrappedToReceiverUserId: 1])
        }
    }
    
    
    //Whenever we hit enter this function is called:
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        sendButtonTapped()
        
        return true
    }
    
    
    func observeUserMessages() {
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let userMessagesReference = Database.database().reference().child("user-messages").child(userId)
        userMessagesReference.observe(.childAdded) { (dataSnapshot) in
            
            let messageId = dataSnapshot.key
            
            let messagesReference = Database.database().reference().child("messages").child(messageId)
            messagesReference.observeSingleEvent(of: .value, with: { (dataSnapshot) in
                
                guard let dictionaryOfValues = dataSnapshot.value as? [String: AnyObject] else { return }
                
                let message = Message()
                message.fromSenderUserId = dictionaryOfValues["fromSenderUserId"] as? String
                message.name = dictionaryOfValues["name"] as? String
                message.text = dictionaryOfValues["text"] as? String
                message.timestamp = dictionaryOfValues["timestamp"] as? NSNumber
                message.toReceiverUserId = dictionaryOfValues["toReceiverUserId"] as? String
                
                //In order not to display irrelevant-messages of other users:
                if message.chatPartnerId() == self.user?.id {
                    
                    self.messages.append(message)
                    
                    //Because I 'm in background thread, I call DispatchQueue.main.async
                    DispatchQueue.main.async {
                        
                        self.collectionView.reloadData()
                    }
                }
            })
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ChatLogCell
        cell.textView.text = messages[indexPath.item].text
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 80)
    }
}
