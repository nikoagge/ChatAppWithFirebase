//
//  LoginOrRegisterController.swift
//  GOC
//
//  Created by Nikolas on 17/05/2019.
//  Copyright © 2019 Nikolas Aggelidis. All rights reserved.
//


import UIKit
import Firebase


class LoginOrRegisterController: UIViewController {

    
    let inputsContainerView: UIView = {
       
        let icv = UIView()
        icv.backgroundColor = .white
        icv.translatesAutoresizingMaskIntoConstraints = false
        //To make the corners of inputsContainerView rounded, make this:
        icv.layer.cornerRadius = 5
        icv.layer.masksToBounds = true
        
        return icv
    }()
    
    lazy var loginRegisterButton: UIButton = {
        
        let lrb = UIButton(type: .system)
        lrb.backgroundColor = UIColor.rgb(ofRed: 80, ofGreen: 101, ofBlue: 161)
        lrb.setTitle("Register", for: .normal)
        lrb.translatesAutoresizingMaskIntoConstraints = false
        lrb.setTitleColor(.white, for: .normal)
        lrb.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        lrb.addTarget(self, action: #selector(decideSelectedSegmentIndex), for: .touchUpInside)
        
        return lrb
    }()
    
    let nameTextField: UITextField = {
        
        let ntf = UITextField()
        ntf.placeholder = "Name"
        ntf.translatesAutoresizingMaskIntoConstraints = false
        
        return ntf
    }()
    
    let nameSeparatorView: UIView = {
        
        let nsv = UIView()
        //Give to nsv a whitish color:
        nsv.backgroundColor = UIColor.rgb(ofRed: 220, ofGreen: 220, ofBlue: 220)
        nsv.translatesAutoresizingMaskIntoConstraints = false
        
        return nsv
    }()
    
    let emailTextField: UITextField = {
        
        let etf = UITextField()
        etf.placeholder = "Email"
        etf.translatesAutoresizingMaskIntoConstraints = false
        
        return etf
    }()
    
    let emailSeparatorView: UIView = {
        
        let esv = UIView()
        //Give to nsv a whitish color:
        esv.backgroundColor = UIColor.rgb(ofRed: 220, ofGreen: 220, ofBlue: 220)
        esv.translatesAutoresizingMaskIntoConstraints = false
        
        return esv
    }()
    
    let passwordTextField: UITextField = {
        
        let ptf = UITextField()
        ptf.placeholder = "Password"
        ptf.translatesAutoresizingMaskIntoConstraints = false
        ptf.isSecureTextEntry = true
        
        return ptf
    }()
    
    lazy var profileImageView: UIImageView = {
        
        let piv = UIImageView()
        piv.image = UIImage(named: "gameofthrones_splash")
        piv.translatesAutoresizingMaskIntoConstraints = false
        //Fix aspect ratio of image:
        piv.contentMode = .scaleAspectFill
        piv.isUserInteractionEnabled = true
        
        piv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImageView)))
        
        return piv
    }()
    
    lazy var loginOrRegisterSegmentedControl: UISegmentedControl = {
        
        let lorsc = UISegmentedControl(items: ["Login", "Register"])
        lorsc.translatesAutoresizingMaskIntoConstraints = false
        lorsc.tintColor = .white
        //SelectedSegmentIndex starts from 0.
        lorsc.selectedSegmentIndex = 1
        
        lorsc.addTarget(self, action: #selector(handleLoginOrRegisterSegmentedControlClicked), for: .valueChanged)
        
        return lorsc
    }()
    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .lightContent
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .rgb(ofRed: 61, ofGreen: 91, ofBlue: 151)
        
        addSubViewsToMainView()
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupProfileImageView()
        setupLoginOrRegisterSegmentedControl()
    }
    
    
    func addSubViewsToMainView() {
        
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)
        view.addSubview(loginOrRegisterSegmentedControl)
    }
    
    
    func setupInputsContainerView() {
        
        //Need x,y,width,height constraints.
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
       inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeparatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(passwordTextField)
        
        //Need x, y, width, height constraints.
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        //Set nameTextField's height equal to 1/3 of inputsContainerView's:
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        //Need x, y, width, height constraints:
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //Need x, y, width, height constraints.
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        //Set emailTextField's height equal to 1/3 of inputsContainerView's:
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        //Need x, y, width, height constraints:
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //Need x, y, width, height constraints.
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        //Set passwordTextField's height equal to 1/3 of inputsContainerView's:
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    
    func setupLoginRegisterButton() {
        
        //Need x, y, width, height constraints.
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    
    func setupProfileImageView() {
        
        //Need x, y, width, height constraints.
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: loginOrRegisterSegmentedControl.topAnchor, constant: -12).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    
    func setupLoginOrRegisterSegmentedControl() {
        
        //Need x, y, width, height constraints.
        loginOrRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginOrRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginOrRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginOrRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 34).isActive = true
    }
    
    
    @objc func decideSelectedSegmentIndex() {
        
        if loginOrRegisterSegmentedControl.selectedSegmentIndex == 1 {
            
            handleRegister()
        } else {
            
            handleLogin()
        }
    }
}
