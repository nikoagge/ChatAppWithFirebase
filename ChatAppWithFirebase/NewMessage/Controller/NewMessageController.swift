//
//  NewMessageController.swift
//  ChatAppWithFirebase
//
//  Created by Nikolas on 19/05/2019.
//  Copyright © 2019 Nikolas Aggelidis. All rights reserved.
//


import UIKit
import Firebase


class NewMessageController: UITableViewController {

    
    var cellIdentifier = "cellId"
    
    var users = [User]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigationBarButtons()
        setupTableView()
        
        fetchUsersFromFirebase()
    }
    
    
    func setupNavigationBarButtons() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    }
    
    
    func setupTableView() {
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.tableFooterView = UIView()
    }
    
    
    func fetchUsersFromFirebase() {
        
        Database.database().reference().child("users").queryOrdered(byChild: "name").observe(.value) { (databaseSnapshot) in
            
            for child in databaseSnapshot.children.allObjects as! [DataSnapshot] {
                
                if let childDictionary = child.value as? NSDictionary {
                    
                    let user = User()
                    user.name = childDictionary["name"] as? String
                    user.email = childDictionary["email"] as? String
                    self.users.append(user)
                    
                    //In order not to crash because of background thread, use DispatchQueue.main.async to fix.
                    DispatchQueue.main.async {
                        
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    
    @objc func handleCancel() {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return users.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //A little hack, the right solution is to dequeue cells for memory efficiency.
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        return cell 
    }
}
