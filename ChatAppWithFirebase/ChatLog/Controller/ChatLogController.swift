//
//  ChatLogController.swift
//  ChatAppWithFirebase
//
//  Created by Nikolas on 22/05/2019.
//  Copyright © 2019 Nikolas Aggelidis. All rights reserved.
//


import UIKit
import Firebase
import MobileCoreServices
import AVFoundation


//Declare UICollectionViewDelegateFlowLayout in order to set the size of each collectionView's cell.
class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
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
    
    lazy var uploadImageView: UIImageView = {
        
        let uiv = UIImageView()
        uiv.image = UIImage(named: "upload_image_icon")
        uiv.translatesAutoresizingMaskIntoConstraints = false
        uiv.isUserInteractionEnabled = true
        uiv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(uploadImageViewTapped)))
        
        return uiv
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
    
    var messageImageViewImageURL: String?
    
    var startingFrame: CGRect?
    
    var blackBackgroundView: UIView?
    
    var startingImageView: UIImageView?

    
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
        containerView.addSubview(uploadImageView)

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
        inputMessageTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant:  8).isActive = true
        inputMessageTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputMessageTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputMessageTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true

        //Set x, y, width, height constraints for separatorLineView:
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //Set x, y, width, height constraints for uploadImageView:
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        //44 pixels is Apple's recommended size:
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
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
        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillDisplay), name: UIResponder.keyboardWillShowNotification, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
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
    
    
    @objc func uploadImageViewTapped() {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    @objc func handleKeyboardWillShow() {
        
        if messages.count > 0 {
            
            let lastIndexPath = NSIndexPath(item: messages.count - 1, section: 0)
            
            collectionView.scrollToItem(at: lastIndexPath as IndexPath, at: .top, animated: true)
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let videoURL = info[.mediaURL] as? URL {
    
            handleVideoSelected(forURL: videoURL)
        } else {
            
            handleImageSelected(forInfo: info)
        }
    
        dismiss(animated: true, completion: nil)
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
                
                let message = Message(withDictionary: dictionaryOfValues)
//                message.fromSenderUserId = dictionaryOfValues["fromSenderUserId"] as? String
//                message.name = dictionaryOfValues["name"] as? String
//                message.text = dictionaryOfValues["text"] as? String
//                message.timestamp = dictionaryOfValues["timestamp"] as? NSNumber
//                message.toReceiverUserId = dictionaryOfValues["toReceiverUserId"] as? String
//                
                //In order not to display irrelevant-messages of other users, but now we don't need to do this because we have structured our database and specifically user-messages very deeply.
                //if message.chatPartnerId() == self.user?.id {
                    
                self.messages.append(message)
                    
                //Because I 'm in background thread, I call DispatchQueue.main.async
                DispatchQueue.main.async {
                        
                    self.collectionView.reloadData()
                    
                    //Scroll to last indexPath
                    let lastIndexPath = NSIndexPath(item: self.messages.count - 1, section: 0)
                    
                    self.collectionView.scrollToItem(at: lastIndexPath as IndexPath, at: .bottom, animated: true)
                }
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
        
        if let messageImageViewImageURL = message.imageURL {

            chatLogCell.messageImageView.loadImageUsingCache(withURLString: messageImageViewImageURL)
            chatLogCell.messageImageView.isHidden = false
            chatLogCell.bubbleView.backgroundColor = .clear
        } else {

            chatLogCell.messageImageView.isHidden = true
        }
    }
    
    
    private func uploadImageToFirebaseStorage(forImage image: UIImage, completion: @escaping (_ imageURL: String) -> ()) {
        
        let imageName = NSUUID().uuidString
        
        let firebaseStorageReference = Storage.storage().reference().child("message_images").child(imageName)
        
        guard let uploadData = image.jpegData(compressionQuality: 0.2) else { return }
        firebaseStorageReference.putData(uploadData, metadata: nil) { (storageMetadata, error) in
            
            if error != nil {
                
                print("Failed to upload image to Firebase storage:", error)
                
                return
            }

            firebaseStorageReference.downloadURL(completion: { (url, error) in
                
                if error != nil {
                    
                    print(error)
                    
                    return
                }
                
                guard let imageURL = url?.absoluteString else { return }
                
                completion(imageURL)
                //self.sendMessage(withImageURL: imageURL, withImage: image)
            })
        }
    }
    
    
    private func sendMessage(withImageURL imageURL: String, withImage image: UIImage) {
        
        let properties = ["imageURL": imageURL as AnyObject, "imageWidth": image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject]
        
        sendMessage(withProperties: properties)
    }
    
    
    private func sendMessage(withProperties properties: [String: AnyObject]) {
        
        let firebaseDatRef = Database.database().reference().child("messages")
        let childRef = firebaseDatRef.childByAutoId()
        
        guard let safelyUnwrappedInputMessageText = inputMessageTextField.text, let safelyUnwrappedUserName = user?.name, let safelyUnwrappedToReceiverUserId = user!.id, let safelyUnwrappedFromSenderUserId = Auth.auth().currentUser?.uid else { return }
        
        let timestamp = Int(NSDate().timeIntervalSince1970)
        
        var dictionaryOfValues = ["name": safelyUnwrappedUserName, "fromSenderUserId": safelyUnwrappedFromSenderUserId, "toReceiverUserId": safelyUnwrappedToReceiverUserId, "timestamp": timestamp, ] as [String : Any]
        //print(dictionaryOfValues["imageURL"])
        //messageImageViewImageURL = dictionaryOfValues["imageURL"] as? String
        //childRef.updateChildValues(dictionaryOfValues)
        
        //append properties onto dictionaryOfValues. key is $0, value is $0
        properties.forEach ({dictionaryOfValues[$0] = $1 as? NSObject})
        
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
    
    
    private func handleImageSelected(forInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        var selectedImageFromImagePicker: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            
            selectedImageFromImagePicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            
            selectedImageFromImagePicker = originalImage
        }
        
        guard let selectedImage = selectedImageFromImagePicker else { return }
        
        uploadImageToFirebaseStorage(forImage: selectedImage) { (imageURL) in
            
            self.sendMessage(withImageURL: imageURL, withImage: selectedImage)
        }
    }
    
    
    private func handleVideoSelected(forURL url: URL) {
        
        let fileName = NSUUID().uuidString + ".mov"
        
        let uploadReference = Storage.storage().reference().child("message-movies").child(fileName)
            
        let uploadTask = uploadReference.putFile(from: url, metadata: nil) { (metadata, error) in
            
            if error != nil {
                
                print(error)
                return
            }
            
            uploadReference.downloadURL(completion: { (completionURL, error) in
                
                if error != nil {
                    
                    print(error)
                    
                    return
                }
                
//                let properties = ["imageURL": imageURL as AnyObject, "imageWidth": image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject]

                let videoURL = url.absoluteString
                guard let thumbnailImage = self.setThumbnailImage(forVideoURL: url) else { return }
                
                self.uploadImageToFirebaseStorage(forImage: thumbnailImage, completion: { (imageURL) in
                    
                    let properties: [String: AnyObject] = ["imageURL": imageURL as AnyObject, "imageWidth": thumbnailImage.size.width as AnyObject, "imageHeight": thumbnailImage.size.height as AnyObject, "videoURL": videoURL as AnyObject]
                    
                    self.sendMessage(withProperties: properties)
                })
            })
        }
        
        uploadTask.observe(.progress) { (uploadTaskSnapshot) in
            
            if let completedUnitCount = uploadTaskSnapshot.progress?.completedUnitCount {
                
                self.navigationItem.title = String(completedUnitCount)
            }
        }
        
        uploadTask.observe(.success) { (uploadTaskSnapshot) in
            
            self.navigationItem.title = self.user?.name
        }
    }
    
    
    private func setThumbnailImage(forVideoURL videoURL: URL) -> UIImage? {
        
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            
             let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTime(value: 1, timescale: 60), actualTime: nil)
            
            return UIImage(cgImage: thumbnailCGImage)
        } catch {
            
            print(error)
        }
        
        return nil
    }
    
    
    //Custom logic for zooming
    func performZoomIn(forStartingImageView startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = .red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        
        //For the black background behind zoomingImageView.
        blackBackgroundView = UIView(frame: keyWindow.frame)
        blackBackgroundView!.backgroundColor = .black
        //To have a little fade in when blackBackgroundView comes on the background do this:
        blackBackgroundView!.alpha = 0
        
        //Add it before zoomingImageView so to have it on the background.
        keyWindow.addSubview(blackBackgroundView!)
        keyWindow.addSubview(zoomingImageView)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            //Then set it again equal to 1:
            self.blackBackgroundView!.alpha = 1
            
            //Also want to hide containerView
            self.containerView.alpha = 0
            
            //Use the type for rectangles: height1 / width1 = height2 / width2 => height1 = height2 / width2 * width1. Here the zoomingImageView's frame height will be the height1, keyWindow.frame.width will be the width1, startingFrame.height will be the height2, startingFrame.width will be the width2.
            let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
            
            zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
            zoomingImageView.center = keyWindow.center
        }, completion: nil)
    }
    
    
    @objc func handleZoomOut(forTapGesture tapGesture: UITapGestureRecognizer) {
        
        guard let zoomOutImageView = tapGesture.view else { return }
        
        zoomOutImageView.layer.cornerRadius = 16
        zoomOutImageView.clipsToBounds = true
        
        //Need to animate back to controller
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            zoomOutImageView.frame = self.startingFrame!
            
            //In order to blackBackgroundView fade out when imageView zooms out:
            self.blackBackgroundView?.alpha = 0
            
            //Also want to show again containerView:
            self.containerView.alpha = 1
        }) { (completed) in
            
            zoomOutImageView.removeFromSuperview()
            
            self.startingImageView?.isHidden = false
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ChatLogCell
        cell.textView.text = messages[indexPath.item].text
        
        cell.message = messages[indexPath.item]
        
        cell.chatLogController = self
//        if messageImageViewImageURL != nil {
//
//            cell.messageImageView.image = UIImage(named: messageImageViewImageURL!)
//        }
        
        setupChatLogCell(forChatLogCell: cell, forMessage: messages[indexPath.item])
        
        if let messageText = messages[indexPath.item].text {
            
            cell.bubbleViewWidthAnchor?.constant = estimateFrame(forText: messageText).width + 32 //Arbitrary add 32 pixels to add some more space so to display the whole textView.
            cell.textView.isHidden = false
        } else if messages[indexPath.item].imageURL != nil {
            
            cell.bubbleViewWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        
//        if messages[indexPath.item].videoURL != nil {
//            
//            cell.playButton.isHidden = false
//        } else {
//            
//            cell.playButton.isHidden = true
//        }
        
        cell.playButton.isHidden = messages[indexPath.item].videoURL == nil
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        if let text = messages[indexPath.item].text {
            
            height = estimateFrame(forText: text).height + 20 //Add some extra more space
        } else if let imageWidth = messages[indexPath.item].imageWidth?.floatValue, let imageHeight = messages[indexPath.item].imageHeight?.floatValue {
            
            //Height will be calculated from this type for rectangles: height1 / width1 = height2 / width2 => height1 = height2 /(width1 * width2). Here height1 is height, width1 is the constant width equal to 200 as we defined above, and width2 is equal to let imageWidth. So:
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        let width = UIScreen.main.bounds.width
        
        return CGSize(width: width, height: height)
    }
    
    
    //In order cells be displayed properly everytime the device rotates:
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
}
