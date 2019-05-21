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
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        checkIfUserIsLoggedIn()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        
        deleteTitleOfNavigationBar()
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
            
            let userId = Auth.auth().currentUser?.uid
            
            Database.database().reference().child("users").child(userId!).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                
                if let dictionaryOfValues = dataSnapshot.value as? [String: AnyObject] {
                    
                    self.navigationItem.title = dictionaryOfValues["name"] as? String
                }
            }, withCancel: nil)
        }
    }
    
    
    func deleteTitleOfNavigationBar() {
        
        self.navigationItem.title = ""
    }
}

