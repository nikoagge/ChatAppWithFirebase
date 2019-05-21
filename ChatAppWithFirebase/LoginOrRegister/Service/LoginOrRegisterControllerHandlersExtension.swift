//
//  LoginOrRegisterControllerHandlersExtension.swift
//  ChatAppWithFirebase
//
//  Created by Nikolas on 21/05/2019.
//  Copyright © 2019 Nikolas Aggelidis. All rights reserved.
//


import Foundation
import UIKit
import Firebase


extension LoginOrRegisterController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func handleLogin() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            
            print("Form is not valid.")
            
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, loginError) in
            
            if loginError != nil {
                
                print(loginError)
                
                return
            }
            
            //Successfully signed in.
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func handleRegister() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            
            print("Form is not valid.")
            
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, registerError: Error?) in
            
            if registerError != nil {
                
                print(registerError)
                
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            //Successfully authenticated user.
            //To create unique image name, for every photo uploaded do this:
            let imageName = NSUUID().uuidString
            
            //Use .child("profile_images") to create a subfolder to have all my images organized.
            let firebaseStorageReference = Storage.storage().reference().child("profile_images").child("\(imageName).png")
            
            guard let uploadData = self.profileImageView.image?.pngData() else { return }
            
            firebaseStorageReference.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    
                    print(error)
                    
                    return
                }
                
                firebaseStorageReference.downloadURL(completion: { (url, error) in
                    
                    if error != nil {
                        
                        print(error)
                        
                        return
                    }
                    
                    guard let profileImageURL = url else { return }
                    
                    let profileImageURLString = profileImageURL.absoluteString
                    
                    let values = ["name": name, "email": email, "profileImageURL": profileImageURLString]
                    self.registerUserIntoDatabase(withUID: uid, withValues: values as [String : AnyObject])
                })
            })
        }
    }
    
    
    private func registerUserIntoDatabase(withUID uid: String, withValues values: [String: AnyObject]) {
        
        let firDatRef = Database.database().reference(fromURL: "https://chatappwithfirebase-2c6f9.firebaseio.com/")
       
        let usersReference = firDatRef.child("users").child(uid)
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                
                print(err)
            }
            
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    
    @objc func handleLoginOrRegisterSegmentedControlClicked() {
        
        loginRegisterButton.setTitle(loginOrRegisterSegmentedControl.titleForSegment(at: loginOrRegisterSegmentedControl.selectedSegmentIndex), for: .normal)
        
        //Change height of inputsContainerView. If Register segment is selected set it to 150, or if Login segment is selected set it to 100.
        inputsContainerViewHeightAnchor?.constant = loginOrRegisterSegmentedControl.selectedSegmentIndex == 1 ? 150 : 100
        
        //Change height of nameTextField. If the Register segment(index is 1) is selected show nameTextField thus its height is 1/3 of inputsContainerView's height, else I disappear it by setting its height equal to 0.
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginOrRegisterSegmentedControl.selectedSegmentIndex == 1 ? 1/3 : 0)
        nameTextField.isHidden = loginOrRegisterSegmentedControl.selectedSegmentIndex == 0
        nameTextFieldHeightAnchor?.isActive = true
        
        //Change height of emailTextField. If the Register segment(index is 1) is selected emailTextField's height is 1/3 of inputsContainerView's height, else set its height equal to 1/2.
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginOrRegisterSegmentedControl.selectedSegmentIndex == 1 ? 1/3 : 1/2)
        emailTextFieldHeightAnchor?.isActive = true
        
        
        //Change height of passwordTextField. If the Register segment(index is 1) is selected passwordTextField's height is 1/3 of inputsContainerView's height, else set its height equal to 1/2.
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginOrRegisterSegmentedControl.selectedSegmentIndex == 1 ? 1/3 : 1/2)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    
    @objc func handleProfileImageView() {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        //In order to implement zoom&crop functionality, write following line:
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromImagePicker: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            
            selectedImageFromImagePicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            
            selectedImageFromImagePicker = originalImage
        }
        
        guard let selectedImage = selectedImageFromImagePicker else { return }
        
        profileImageView.image = selectedImage
        
        dismiss(animated: true, completion: nil)
    }
}
