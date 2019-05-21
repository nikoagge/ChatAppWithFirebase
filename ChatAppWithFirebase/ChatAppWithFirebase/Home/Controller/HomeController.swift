//
//  HomeController.swift
//  GOC
//
//  Created by Nikolas on 17/05/2019.
//  Copyright © 2019 Nikolas Aggelidis. All rights reserved.
//


import UIKit


class HomeController: UITableViewController {

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createBarButtonItems()
    }
    
    
    func createBarButtonItems() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    }
    
    
    @objc func handleLogout() {
        
        let loginController = LoginController()
        
        present(loginController, animated: true, completion: nil)
    }
}

