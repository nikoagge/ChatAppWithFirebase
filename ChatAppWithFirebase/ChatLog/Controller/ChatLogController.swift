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

    var containerViewBottomAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupInputComponents()
        setupCollectionView()
        setupKeyboardObservers()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        
        //To avoid to have a memory leak, in our case if I omit the following line of code, in order to hide the keyboard the relevant function the first time that ChatLogController shows up must be called once in order to work, the second time two times, the third times three times, the fourth time four times and so on...
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func setupInputComponents() {

        view.addSubview(containerView)

        containerView.addSubview(sendButton)
        containerView.addSubview(inputMessageTextField)
        containerView.addSubview(separatorLineView)

        //Set x, y, width, height constraints for containerView:
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewBottomAnchor?.isActive = true
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
        //In order to set some extra padding to the collectionView's cell:
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 39, right: 0)
        //Also need to change scrollIndicatorInsets:
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        //In order to integrate interactivity to our keyboard:
        //collectionView.keyboardDismissMode = .interactive
    }
    
    
    func setupKeyboardObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillDisplay), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc func sendButtonTapped() {
        
        let firebaseDatRef = Database.database().reference().child("messages")
        let childRef = firebaseDatRef.childByAutoId()
        
        guard let safelyUnwrappedInputMessageText = inputMessageTextField.text, let safelyUnwrappedUserName = user?.name, let safelyUnwrappedToReceiverUserId = user!.id, let safelyUnwrappedFromSenderUserId = Auth.auth().currentUser?.uid else { return }
        
        let timestamp = Int(NSDate().timeIntervalSince1970)
        
        let dictionaryOfValues = ["text": safelyUnwrappedInputMessageText, "name": safelyUnwrappedUserName, "fromSenderUserId": safelyUnwrappedFromSenderUserId, "toReceiverUserId": safelyUnwrappedToReceiverUserId, "timestamp": timestamp] as [String : Any]
        
        //childRef.updateChildValues(dictionaryOfValues)
        childRef.updateChildValues(dictionaryOfValues) { (error, databaseRef) in
            
            if error != nil {
                
                print(error)
                
                return
            }
            
            //In order to clear the inputMessageTextField everytime I send a new message:
            self.inputMessageTextField.text = nil
            
            //With this reference I create a subfolder user-messages for every sender((safelyUnwrappedFromSenderUserId):
            guard let messageId = childRef.key else { return }
            let senderUserMessagesRef = Database.database().reference().child("user-messages").child(safelyUnwrappedFromSenderUserId).child(safelyUnwrappedToReceiverUserId).child(messageId)
            senderUserMessagesRef.setValue([safelyUnwrappedFromSenderUserId: 1])
            
            let receiverUserMessagesRef = Database.database().reference().child("user-messages").child(safelyUnwrappedToReceiverUserId).child(safelyUnwrappedFromSenderUserId).child(messageId)
            receiverUserMessagesRef.setValue([safelyUnwrappedToReceiverUserId: 1])
        }
    }
    
    
    @objc func handleKeyboardWillDisplay(withNotification notification: Notification) {
        
        let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? AnyObject)?.cgRectValue
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? AnyObject)?.doubleValue
        
        //Move the input area up
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        
        UIView.animate(withDuration: keyboardDuration!) {
            
            self.view.layoutIfNeeded()
        }
    }
    
    
    @objc func handleKeyboardWillHide(withNotification notification: Notification) {
        
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? AnyObject)?.doubleValue
        
        containerViewBottomAnchor?.constant = 0
        
        UIView.animate(withDuration: keyboardDuration!) {
            
            self.view.layoutIfNeeded()
        }
    }
    
    
    //Whenever we hit enter this function is called:
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        sendButtonTapped()
        
        return true
    }
    
    
    func observeUserMessages() {
        
        guard let userId = Auth.auth().currentUser?.uid, let toReceiverUserId = user?.id else { return }
        
        let userMessagesReference = Database.database().reference().child("user-messages").child(userId).child(toReceiverUserId)
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
                
                //In order not to display irrelevant-messages of other users, but now we don't need to do this because we have structured our database and specifically user-messages very deeply.
                //if message.chatPartnerId() == self.user?.id {
                    
                self.messages.append(message)
                    
                //Because I 'm in background thread, I call DispatchQueue.main.async
                DispatchQueue.main.async {
                        
                    self.collectionView.reloadData()
                }
                //}
            })
        }
    }
    
    
    private func estimateFrame(forText text: String) -> CGRect {
        
        //Set value of height arbitrary very large, and the width equal to the widthAnchor of textView as it's set on ChatLogCell's relevant function:
        let size = CGSize(width: 200, height: 1300)
        
        //Font set it as it's set on textView on ChatLogCell
        return NSString(string: text).boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    
    private func setupChatLogCell(forChatLogCell chatLogCell: ChatLogCell, forMessage message: Message) {
        
        guard let profileImageURL = self.user?.profileImageURL else { return }
        
        chatLogCell.profileImageView.loadImageUsingCache(withURLString: profileImageURL)
        
        if message.fromSenderUserId == Auth.auth().currentUser?.uid {
            
            //Outgoing message
            chatLogCell.bubbleView.backgroundColor = ChatLogCell.blueColor
            chatLogCell.textView.textColor = .white
            chatLogCell.profileImageView.isHidden = true
            chatLogCell.bubbleViewRightAnchor?.isActive = true
            chatLogCell.bubbleViewLeftAnchor?.isActive = false
        } else {
            
            //Incoming message
            chatLogCell.bubbleView.backgroundColor = UIColor.rgb(ofRed: 240, ofGreen: 240, ofBlue: 240)
            chatLogCell.textView.textColor = .black
            chatLogCell.profileImageView.isHidden = false
            chatLogCell.bubbleViewRightAnchor?.isActive = false
            chatLogCell.bubbleViewLeftAnchor?.isActive = true
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ChatLogCell
        cell.textView.text = messages[indexPath.item].text
        
        setupChatLogCell(forChatLogCell: cell, forMessage: messages[indexPath.item])
        
        cell.bubbleViewWidthAnchor?.constant = estimateFrame(forText: messages[indexPath.item].text!).width + 32 //Arbitrary add 32 pixels to add some more space so to display the whole textView.
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        if let text = messages[indexPath.item].text {
            
            height = estimateFrame(forText: text).height + 20 //Add some extra more space
        }
        
        return CGSize(width: view.frame.width, height: 80)
    }
    
    
    //In order cells be displayed properly everytime the device rotates:
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
}
