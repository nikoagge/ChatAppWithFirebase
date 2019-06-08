//
//  MessagesController.swift
//  GOC
//
//  Created by Nikolas on 17/05/2019.
//  Copyright © 2019 Nikolas Aggelidis. All rights reserved.
//


import UIKit
import Firebase


class MessagesController: UITableViewController {
    
    
    var messages = [Message]()

    //Use this in order to have one message per user. Actually the most recent message:
    var messagesDictionary = [String: Message]()
    
    var cellIdentifier = "cellId"
    
    var timer: Timer?
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupTableView()
        setupNavigationBarButtons()
        checkIfUserIsLoggedIn()
        //observeMessages()
    }
    
    
    func setupTableView() {
        
        tableView.tableFooterView = UIView()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    
    func setupNavigationBarButtons() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutBarButtonTapped))
        
        let newMessageImage = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: newMessageImage, style: .plain, target: self, action: #selector(newMessageBarButtonTapped))
    }
    
    
    @objc func logoutBarButtonTapped() {
        
        do {
            
            try Auth.auth().signOut()
        } catch let logoutError {
            
            print(logoutError)
        }
        
        let loginOrRegisterController = LoginOrRegisterController()
        loginOrRegisterController.messagesController = self
        
        present(loginOrRegisterController, animated: true, completion: nil)
    }
    
    
    @objc func newMessageBarButtonTapped() {
        
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navigationController = UINavigationController(rootViewController: newMessageController)
        
        present(navigationController, animated: true, completion: nil)
    }
    
    
    func checkIfUserIsLoggedIn() {
        
        //User is not logged in.
        if Auth.auth().currentUser?.uid == nil {
            
            //In order not to get any warning message about presenting too many viewControllers, do this:
            perform(#selector(logoutBarButtonTapped), with: nil, afterDelay: 0) //Actually despite 0 that gives it a little necessary delay.
        } else {
            
            fetchUserFromFirebaseAndSetupNavigationBarTitle()
        }
    }
    
    
    func observeMessages() {
        
        let firebaseDatRef = Database.database().reference().child("messages")
        firebaseDatRef.observe(.childAdded) { (databaseSnapshot) in
            
            guard let dictionaryOfValues = databaseSnapshot.value as? [String: AnyObject] else { return }
            
            let message = Message(withDictionary: dictionaryOfValues)
//            message.fromSenderUserId = dictionaryOfValues["fromSenderUserId"] as? String
//            message.name = dictionaryOfValues["name"] as? String
//            message.text = dictionaryOfValues["text"] as? String
//            message.timestamp = dictionaryOfValues["timestamp"] as? NSNumber
//            message.toReceiverUserId = dictionaryOfValues["toReceiverUserId"] as? String
            
            guard let safelyUnwrappedToReceiverUserId = message.toReceiverUserId else { return }
            
            //self.messages.append(message)
            
            self.messagesDictionary[safelyUnwrappedToReceiverUserId] = message
            
            self.messages = Array(self.messagesDictionary.values)
            
            //That's to sort messages by time ascending orded.
            self.messages.sort(by: { (firstMessage, secondmessage) -> Bool in

                guard let safelyUnwrappedFirstTimestamp = firstMessage.timestamp, let safelyUnwrappedSecondTimestamp = secondmessage.timestamp else { return false }
                //For ascending order:
                return safelyUnwrappedFirstTimestamp.intValue > safelyUnwrappedSecondTimestamp.intValue
            })
         
            //In order not to crash because of background thread, run this on main thread:
            
        }
        
        //In order to update tableView when removing child directly from Firebase console:
        firebaseDatRef.observe(.childRemoved) { (dataSnashot) in
            
            self.messagesDictionary.removeValue(forKey: dataSnashot.key)
            
            //A little problem there, check again it later.
            self.attemptReloadOfTableView()
        }
    }
    
    
    func observeUserMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        
        ref.observe(.childAdded) { (dataSnapshot) in
            
            let userId = dataSnapshot.key
            
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (dataSnapshot) in
                
                let messageId = dataSnapshot.key
                
                self.fetchMessage(forMessageId: messageId)
            })
        }
    }
    
    
    func fetchUserFromFirebaseAndSetupNavigationBarTitle() {
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
    Database.database().reference().child("users").child(userId).observeSingleEvent(of: .value) { (dataSnapshot) in
            
            guard let dictionaryOfValues = dataSnapshot.value as? [String: AnyObject] else { return }
            
            let user = User()
            user.id = userId
            user.email = dictionaryOfValues["email"] as? String
            user.name = dictionaryOfValues["name"] as? String
            user.profileImageURL = dictionaryOfValues["profileImageURL"] as? String
                            //user.setValuesForKeys(dictionaryOfValues)
            
            self.setupNavigationBarTitleView(withUser: user)
        }
    }
    
    
    func setupNavigationBarTitleView(withUser user: User) {
        
        messages.removeAll()
        
        messagesDictionary.removeAll()
        
        tableView.reloadData()
        
        observeUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        //Half of the width
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        guard let profileImageURL = user.profileImageURL else { return }
        profileImageView.loadImageUsingCache(withURLString: profileImageURL)
        
        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        self.navigationItem.titleView = titleView
        titleView.addSubview(containerView)
        containerView.addSubview(profileImageView)
        containerView.addSubview(nameLabel)
        
        //Set x, y, width, height constraints for profileImageView:
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        //Set x, y, width, height constraints for nameLabel:
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        //titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(displayChatLogController)))
    }
    
    
    private func attemptReloadOfTableView() {
        
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.handleReloadTableView), userInfo: nil, repeats: false)
    }
    
    
    private func fetchMessage(forMessageId messageId: String) {
        
        let messagesReference = Database.database().reference().child("messages").child(messageId)
        messagesReference.observeSingleEvent(of: .value, with: { (anotherSnapshot) in
            
            guard let dictionaryOfValues = anotherSnapshot.value as? [String: AnyObject] else { return }
            
            let message = Message(withDictionary: dictionaryOfValues)
//            message.fromSenderUserId = dictionaryOfValues["fromSenderUserId"] as? String
//            message.name = dictionaryOfValues["name"] as? String
//            message.text = dictionaryOfValues["text"] as? String
//            message.timestamp = dictionaryOfValues["timestamp"] as? NSNumber
//            message.toReceiverUserId = dictionaryOfValues["toReceiverUserId"] as? String
//
            guard let safelyUnwrappedChatPartnerId = message.chatPartnerId() else { return }
            
            
            self.messagesDictionary[safelyUnwrappedChatPartnerId] = message
            
            //self.messages.append(message)
            
            self.attemptReloadOfTableView()
            
            
            
            //                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            //
            //                    self.tableView.reloadData()
            //                })
        })
    }
    
    
    @objc func displayChatLogController(forUser user: User) {
        
        let layout = UICollectionViewFlowLayout()
        
        let chatLogController = ChatLogController(collectionViewLayout: layout)
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    
    @objc func handleReloadTableView() {
        
        self.messages = Array(self.messagesDictionary.values)
        
        //That's to sort messages by time ascending orded.
        self.messages.sort(by: { (firstMessage, secondmessage) -> Bool in
            
            guard let safelyUnwrappedFirstTimestamp = firstMessage.timestamp, let safelyUnwrappedSecondTimestamp = secondmessage.timestamp else { return false }
            //For ascending order:
            return safelyUnwrappedFirstTimestamp.intValue > safelyUnwrappedSecondTimestamp.intValue
        })
        
        //In order not to crash because of background thread, run this on main thread:
        DispatchQueue.main.async {
            print("test")
            self.tableView.reloadData()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Hack for tableView's cell
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        
        //The proper way to create tableView's cell:
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
        
        cell.message = message
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 72
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else { return }
        
        let reference = Database.database().reference().child("users").child(chatPartnerId)
        reference.observeSingleEvent(of: .value) { (dataSnapshot) in
            
            guard let dictionaryOfValues = dataSnapshot.value as? [String: AnyObject] else { return }
            
            let user = User()
            user.id = chatPartnerId
            user.email = dictionaryOfValues["email"] as? String
            user.name = dictionaryOfValues["name"] as? String
            user.profileImageURL = dictionaryOfValues["profileImageURL"] as? String
            
            self.displayChatLogController(forUser: user)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else { return }
        Database.database().reference().child("user-messages").child(userId).child(chatPartnerId).removeValue { (error, databaseReference) in
            
            if error != nil {
                
                print(error)
                
                return
            }
            
            //The unsafe way to remove a message and update the table, because how we have structured our project will restore the removed message if we gonna send a new message to anotherUser:
//            self.messages.remove(at: indexPath.row)
//            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            
            //The correct way:
            self.messagesDictionary.removeValue(forKey: chatPartnerId)
            self.attemptReloadOfTableView()
        }
    }
}

