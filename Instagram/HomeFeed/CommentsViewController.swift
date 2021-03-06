//
//  CommentsViewController.swift
//  Instagram
//
//  Created by QueenaHuang on 1/2/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import UIKit
import SVProgressHUD

class CommentsViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var myProfileImageView: UIImageView!
    @IBOutlet weak var myCommentView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var postCommentView: UIView!

    var postId: String = ""

    lazy var viewModel: CommentsViewModel = {
        return CommentsViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 150;
        tableView.delegate = self
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        // Move view up when keyboard appears
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)

        myProfileImageView.layer.masksToBounds = false
        myProfileImageView.layer.cornerRadius = myProfileImageView.frame.height/2
        myProfileImageView.clipsToBounds = true

        viewModel.updateLoadingStatus = { [weak self] () in
            DispatchQueue.main.async {
                let isLoading = self?.viewModel.isLoading ?? false
                if isLoading {
                    SVProgressHUD.show()
                } else {
                    SVProgressHUD.dismiss()
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
            DispatchQueue.main.async {
                self?.myProfileImageView.image = image?.circleMask
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        initCommentView()
    }

    // MARK: - Action
    @IBAction func onPostComment(_ sender: UIButton) {
        
        myCommentView.resignFirstResponder()

        if !myCommentView.text.isEmpty {
            viewModel.writeComment(replayToUserId: nil, text: myCommentView.text)
        }
    }

    // MARK: - setup UI
    func initCommentView() {
        myCommentView.delegate = self
        myCommentView.text = "Write down your caption..."
        myCommentView.textColor = UIColor.lightGray

        postButton.sizeToFit()

        viewModel.initFetch(postId: postId)

        setupLayout()
    }

    func setupLayout() {
        let padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(postCommentView.snp.top)
        }

        postCommentView.snp.makeConstraints { (make) in
            make.top.equalTo(tableView.snp.bottom)
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(80)
        }

        myProfileImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(padding.left)
            make.centerY.equalTo(postCommentView.snp.centerY)
            make.size.equalTo(myProfileImageView.frame.height)
        }

        myCommentView.snp.makeConstraints { (make) in
            make.left.equalTo(myProfileImageView.snp.right).offset(padding.left)
            make.top.bottom.equalToSuperview().inset(padding.top)
            make.right.equalTo(postButton.snp.left).offset(-padding.right)
        }

        postButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(padding.right)
            make.centerY.equalTo(postCommentView.snp.centerY)
            make.height.equalTo(postButton.frame.height)
        }
    }

    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {

        if myCommentView.textColor == UIColor.lightGray {
            myCommentView.text = ""
            myCommentView.textColor = UIColor.black
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    // MARK: - Notification for keyboard
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
