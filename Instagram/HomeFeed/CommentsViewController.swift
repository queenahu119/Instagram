//
//  CommentsViewController.swift
//  Instagram
//
//  Created by QueenaHuang on 1/2/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController, UITextViewDelegate {


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var myProfileImageView: UIImageView!
    @IBOutlet weak var myCommentView: UITextView!
    @IBOutlet weak var postButton: UIButton!

    var postId: String = ""

    var activityIndicator:UIActivityIndicatorView!

    lazy var viewModel: CommentsViewModel = {
        return CommentsViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        myProfileImageView.layer.masksToBounds = false
        myProfileImageView.layer.cornerRadius = myProfileImageView.frame.height/2
        myProfileImageView.clipsToBounds = true

        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle:
            UIActivityIndicatorViewStyle.gray)
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator);

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

        viewModel.reloadTableViewClosure = {
            self.tableView.reloadData()
        }

        viewModel.postAfterCompletion = { [weak self] (success, title, message) in
            DispatchQueue.main.async {

                if success {

                    self?.initCommentView()

                } else {
                    Helper.displayAlert(vc: self!, title: title ?? "", message: message ?? "", completion:nil)
                }
            }
        }

        viewModel.updateProfileImageAfterCompletion = { [weak self] (image, response, error) in
            self?.myProfileImageView.image = image
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        initCommentView()
    }

    @IBAction func onPostComment(_ sender: UIButton) {
        
        myCommentView.resignFirstResponder()

        viewModel.writeComment(replayToUserId: nil, text: myCommentView.text)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {

        if myCommentView.textColor == UIColor.lightGray {
            myCommentView.text = ""
            myCommentView.textColor = UIColor.black
        }
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }

    func initCommentView() {

        myCommentView.delegate = self
        myCommentView.text = "Write down your caption..."
        myCommentView.textColor = UIColor.lightGray

        viewModel.initFetch(postId: postId)
    }

}
