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
    
    
    func loginSegmentTapped() {
        
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
            self.messagesController?.fetchUserFromFirebaseAndSetupNavigationBarTitle()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func registerSegmentTapped() {
        
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
            let firebaseStorageReference = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
            
            //Compress the image, to 0.1 as 10% of the original image:
            guard let safelyUnwrappedProfileImage = self.profileImageView.image, let compressedUploadData = safelyUnwrappedProfileImage.jpegData(compressionQuality: 0.1) else { return }
            
            //Too large data, make the download slow:
            //guard let uploadData = self.profileImageView.image?.pngData() else { return }
            
            firebaseStorageReference.putData(compressedUploadData, metadata: nil, completion: { (metadata, error) in
                
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
            
            //self.messagesController?.fetchUserFromFirebaseAndSetupNavigationBar()
            //self.messagesController?.navigationItem.title = values["name"] as? String
            let user = User()
            user.email = values["email"] as? String
            user.name = values["name"] as? String
            user.profileImageURL = values["profileImageURL"] as? String
            //user.setValuesForKeys(values)
            self.messagesController?.setupNavigationBarTitleView(withUser: user)
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    
    @objc func loginOrRegisterSegmentedControlClicked() {
        
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
    
    
    @objc func profileImageViewTapped() {
        
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
