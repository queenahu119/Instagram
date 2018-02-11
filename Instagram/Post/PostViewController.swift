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

        setUpLoading()

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

                Helper.displayAlert(vc: self, title: title!, message: message!, completion: {
                    if success {
                        self.comment.text = ""
                        self.imageViewToPost.image = nil

                        self.tabBarController?.selectedIndex = 0
                    }
                })
            }
        }

        self.imageViewToPost.image = UIImage(named: "museum.jpg")
    }

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
        
        let data: [String: AnyObject] = ["comment": self.comment, "image": self.imageViewToPost]

        viewModel.postMedia(info: data)

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

    func textViewDidBeginEditing(_ textView: UITextView) {

        if comment.textColor == UIColor.lightGray {
            comment.text = ""
            comment.textColor = UIColor.black
        }
    }

    func setUpLoading() {

        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
    }

}
