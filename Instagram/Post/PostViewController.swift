//
//  PostViewController.swift
//  MyInstagram
//
//  Created by QueenaHuang on 31/12/17.
//  Copyright © 2017 queenahuang. All rights reserved.
//

import UIKit

class PostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var imageViewToPost: UIImageView!
    @IBOutlet weak var comment: UITextView!
    @IBOutlet weak var chooseFromLibraryButton: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!

    private let defaultImage = UIImage(named: "museum.jpg")

    lazy fileprivate var viewModel: PostViewModel = {
        return PostViewModel()
    }()

    let activityIndicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()

        let shareButton = UIBarButtonItem(title: "Share",
                                            style: .plain,
                                            target: self,
                                            action: #selector(share))
        self.navigationItem.rightBarButtonItem = shareButton

        comment.delegate = self
        comment.text = "Write down your caption..."
        comment.textColor = UIColor.lightGray

        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        // Move view up when keyboard appears
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        setUpLoading()
        setupLayout()

        viewModel.updateLoadingStatus = { [weak self] () in
            DispatchQueue.main.async {
                let isLoading = self?.viewModel.isLoading ?? false
                if isLoading {
                    self?.activityIndicator.startAnimating()

                }else {
                    self?.activityIndicator.stopAnimating()
                }
            }
        }

        viewModel.postAfterCompletion = { (success, title, message) in
            DispatchQueue.main.async {

                Helper.displayAlert(vc: self, title: title!, message: message!, completion: { [weak self] in
                    if success {
                        self?.comment.text = ""
                        self?.imageViewToPost.image = self?.defaultImage

                        self?.tabBarController?.selectedIndex = 0
                    }
                })
            }
        }

        self.imageViewToPost.image = defaultImage
        self.imageViewToPost.contentMode = .scaleAspectFit
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    // MARK: - Action
    @IBAction func useLibraryPhotoButton(_ sender: Any) {
        photoLibrary()
    }

    @IBAction func takePictureButton(_ sender: Any) {
        camera()
    }

    @objc func share() {

        if (self.imageViewToPost == nil) {

            Helper.displayAlert(vc: self, title: "Image may have some problems.", message: "Please try again later.", completion: nil)
        }

        if let image = self.imageViewToPost.image {
            let data: [String: AnyObject] = ["comment": self.comment?.text as AnyObject, "image": image]

            viewModel.postMedia(info: data)
        }
    }

    func camera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera

            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    func photoLibrary()
    {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self;
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageViewToPost.image = image
        }

        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - textView delegate
    func textViewDidBeginEditing(_ textView: UITextView) {

        if comment.textColor == UIColor.lightGray {
            comment.text = ""
            comment.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if comment.text.isEmpty {
            comment.text = "Write down your caption..."
            comment.textColor = UIColor.lightGray
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    // MARK: - Set up UI
    func setUpLoading() {

        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
    }

    func setupLayout() {
        let padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        chooseFromLibraryButton.sizeToFit()
        takePhotoButton.sizeToFit()

        let height = UIScreen.main.bounds.width
        imageViewToPost.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(height)
        }

        comment.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(padding.left)
            make.top.equalTo(imageViewToPost.snp.bottom).offset(padding.top)
            make.height.equalTo(100).priority(.low)
            make.bottom.equalTo(chooseFromLibraryButton.snp.top).offset(-padding.bottom)
        }

        chooseFromLibraryButton.snp.makeConstraints { (make) in
            make.left.bottom.equalTo(view.safeAreaLayoutGuide).inset(padding.left)
            make.height.equalTo(chooseFromLibraryButton.frame.size.height)
        }

        takePhotoButton.snp.makeConstraints { (make) in
            make.right.bottom.equalTo(view.safeAreaLayoutGuide).inset(padding.right)
            make.height.equalTo(takePhotoButton.frame.size.height)
        }
    }

    // MARK: - Notification
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}
