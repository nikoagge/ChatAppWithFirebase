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
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupNavigationBarButtons()
        checkIfUserIsLoggedIn()
    }
    
    
    func setupNavigationBarButtons() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let newMessageImage = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: newMessageImage, style: .plain, target: self, action: #selector(handleNewMessage))
    }
    
    
    @objc func handleLogout() {
        
        do {
            
            try Auth.auth().signOut()
        } catch let logoutError {
            
            print(logoutError)
        }
        
        let loginOrRegisterController = LoginOrRegisterController()
        loginOrRegisterController.messagesController = self
        
        present(loginOrRegisterController, animated: true, completion: nil)
    }
    
    
    @objc func handleNewMessage() {
        
        let newMessageController = NewMessageController()
        let navigationController = UINavigationController(rootViewController: newMessageController)
        
        present(navigationController, animated: true, completion: nil)
    }
    
    
    func checkIfUserIsLoggedIn() {
        
        //User is not logged in.
        if Auth.auth().currentUser?.uid == nil {
            
            //In order not to get any warning message about presenting too many viewControllers, do this:
            perform(#selector(handleLogout), with: nil, afterDelay: 0) //Actually despite 0 that gives it a little necessary delay.
        } else {
            
            
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
    }
}

