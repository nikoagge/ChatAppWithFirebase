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
    
    var cellIdentifier = "cellId"
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupTableView()
        setupNavigationBarButtons()
        checkIfUserIsLoggedIn()
        observeMessages()
    }
    
    
    func setupTableView() {
        
        tableView.tableFooterView = UIView()
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
            
            let message = Message()
            message.fromSenderUserId = dictionaryOfValues["fromSenderUserId"] as? String
            message.name = dictionaryOfValues["name"] as? String
            message.text = dictionaryOfValues["text"] as? String
            message.timestamp = dictionaryOfValues["timestamp"] as? Int
            message.toReceiverUserId = dictionaryOfValues["toReceiverUserId"] as? String
            
            self.messages.append(message)
            
            //In order not to crash because of background thread, run this on main thread:
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
            }
        }
    }
    
    
    func fetchUserFromFirebaseAndSetupNavigationBarTitle() {
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("users").child(userId).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            
            if let dictionaryOfValues = dataSnapshot.value as? [String: AnyObject] {
                
                //self.navigationItem.title = dictionaryOfValues["name"] as? String
                
                let user = User()
                user.email = dictionaryOfValues["email"] as? String
                user.name = dictionaryOfValues["name"] as? String
                user.profileImageURL = dictionaryOfValues["profileImageURL"] as? String
                //user.setValuesForKeys(dictionaryOfValues)
                
                self.setupNavigationBarTitleView(withUser: user)
            }
        }, withCancel: nil)
    }
    
    
    func setupNavigationBarTitleView(withUser user: User) {
        
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
    
    
    @objc func displayChatLogController(forUser user: User) {
        
        let layout = UICollectionViewFlowLayout()
        
        let chatLogController = ChatLogController(collectionViewLayout: layout)
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        cell.textLabel?.text = messages[indexPath.row].name
        cell.detailTextLabel?.text = messages[indexPath.row].text
        
        return cell
    }
}

