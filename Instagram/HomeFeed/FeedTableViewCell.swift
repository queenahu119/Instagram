//
//  FeedTableViewCell.swift
//  MyInstagram
//
//  Created by QueenaHuang on 2017/12/10.
//  Copyright © 2017年 queenahuang. All rights reserved.
//

import UIKit
import SnapKit

protocol HomeFeedCellDelegate : class {
    func HomeFeedCellDelegateDidTapLike(_ sender: FeedTableViewCell)
    func HomeFeedCellDelegateDidTapComment(_ sender: FeedTableViewCell)
}

class FeedTableViewCell: UITableViewCell {

    @IBOutlet weak var postHeaderView: UIView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var imageFile: UIImageView!
    @IBOutlet weak var moreButton: UIButton!

    @IBOutlet weak var postActionsView: UIView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!

    @IBOutlet weak var postStackView: UIStackView!
    @IBOutlet weak var textNumOfLike: UILabel!
    @IBOutlet weak var textComments: UITextView!
    @IBOutlet weak var viewCommentsButton: UIButton!
    @IBOutlet weak var textPostTime: UILabel!

    weak var delegate: HomeFeedCellDelegate?

    let padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

    var post: FeedCellViewModel? {
        didSet {
            guard let post = post else {
                return
            }

            username.text = post.username

            if let numOfLike = post.numOfLike {
                textNumOfLike.text = (numOfLike > 1) ? "\(numOfLike) likes" : "\(numOfLike) like"
            }

            if let comment = post.comments {
                let text = comment.replacingOccurrences(of: "\n", with: "")

                let userName = post.username + " "
                let attrsForName = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17)]
                let attrsForComment = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)]

                let mutableString = NSMutableAttributedString(string:userName , attributes:attrsForName)
                let mutableStringForComment = NSMutableAttributedString(string: text, attributes: attrsForComment)

                mutableString.append(mutableStringForComment)
                textComments.attributedText = mutableString
            } else {
                textComments.text = ""
            }

            if let creationDate = post.dateText {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy, HH:mm"
                textPostTime.text = dateFormatter.string(from: creationDate)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.translatesAutoresizingMaskIntoConstraints = false

        username.font = UIFont.boldSystemFont(ofSize: 13.5)
        textComments.font = UIFont.systemFont(ofSize: 13.5)
        textNumOfLike.font = UIFont.boldSystemFont(ofSize: 13.5)
        textPostTime.font = UIFont.systemFont(ofSize: 13.5)

        let textColorLight: UIColor = UIColor.gray
        textPostTime.textColor = textColorLight
        viewCommentsButton.setTitleColor(textColorLight, for: .normal)
        viewCommentsButton.titleLabel?.font = UIFont.systemFont(ofSize: 13.5)

        profile.image = defaultBackgroundColor.imageRepresentation
        profile.layer.cornerRadius = profile.frame.size.width / 2
        profile.clipsToBounds = true

        postStackView.axis  = .vertical
        postStackView.distribution  = UIStackViewDistribution.equalSpacing
        postStackView.alignment = UIStackViewAlignment.top
        postStackView.spacing   = 0.0
        postStackView.translatesAutoresizingMaskIntoConstraints = false

        textComments.isEditable = false
        textComments.isSelectable = false
        textComments.isScrollEnabled = false
        textComments.textContainer.maximumNumberOfLines = 0
        textComments.textContainer.lineBreakMode = .byTruncatingTail
        textComments.translatesAutoresizingMaskIntoConstraints = false
        textComments.contentInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: -5)
        textComments.textContainer.maximumNumberOfLines = 4;
        textComments.textContainer.lineBreakMode = .byWordWrapping

        imageFile.image = defaultBackgroundColor.imageRepresentation
        imageFile.contentMode = .scaleToFill

        textNumOfLike.sizeToFit()
        textPostTime.sizeToFit()
        textComments.sizeToFit()
        viewCommentsButton.sizeToFit()

        setupLayout()
        updatePostStackView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func likeTapped(_ sender: Any) {
        delegate?.HomeFeedCellDelegateDidTapLike(self)
    }
    
    @IBAction func commentTapped(_ sender: Any) {
        delegate?.HomeFeedCellDelegateDidTapComment(self)
    }

    @IBAction func viewCommentButtonTapped(_ sender: Any) {
        delegate?.HomeFeedCellDelegateDidTapComment(self)
    }

    override func updateConstraints()
    {
        updatePostStackView()
        super.updateConstraints()
    }

    func setupLayout() {
        postHeaderView.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView)
            make.left.right.equalToSuperview().inset(padding.left)
            make.bottom.equalTo(imageFile.snp.top).priority(.medium)
            make.height.equalTo(50)
        }

        let height = UIScreen.main.bounds.width
        imageFile.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(postHeaderView.snp.bottom).priority(.medium)
            make.bottom.equalTo(postActionsView.snp.top)
            make.height.equalTo(height)
        }

        postActionsView.snp.makeConstraints { (make) in
            make.top.equalTo(imageFile.snp.bottom)
            make.left.right.equalToSuperview().inset(padding.left)
            make.bottom.equalTo(postStackView.snp.top).priority(.medium)
            make.height.equalTo(40)
        }

        postStackView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(padding.left)
            make.top.equalTo(postActionsView.snp.bottom).priority(.medium)
            make.bottom.equalTo(self.contentView).offset(-padding.bottom)
        }

        // postHeaderView
        profile.snp.makeConstraints { (make) in
            make.centerY.equalTo(postHeaderView.snp.centerY)
            make.left.equalTo(postHeaderView.snp.left)
            make.size.equalTo(32)
        }
        username.snp.makeConstraints { (make) in
            make.centerY.equalTo(postHeaderView.snp.centerY)
            make.left.equalTo(profile.snp.right).offset(5)
            make.right.equalTo(moreButton.snp.left).offset(-5)
        }
        moreButton.snp.makeConstraints { (make) in
            make.left.equalTo(username.snp.right).offset(5)
            make.right.equalTo(postHeaderView.snp.right)
            make.centerY.equalTo(profile.snp.centerY)
            make.size.equalTo(30).priority(.high)
        }

        // postActionsView
        favoriteButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        commentButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        shareButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        bookmarkButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10)

        favoriteButton.snp.makeConstraints { (make) in
            make.left.equalTo(postActionsView.snp.left)
            make.right.equalTo(commentButton.snp.left).offset(-padding.right)
            make.centerY.equalTo(postActionsView.snp.centerY)
            make.size.equalTo(32)
        }
        commentButton.snp.makeConstraints { (make) in
            make.left.equalTo(favoriteButton.snp.right).offset(padding.left)
            make.right.equalTo(shareButton.snp.left).offset(-padding.right)
            make.centerY.equalTo(postActionsView.snp.centerY)
            make.size.equalTo(32)
        }
        shareButton.snp.makeConstraints { (make) in
            make.left.equalTo(commentButton.snp.right).offset(padding.left)
            make.centerY.equalTo(postActionsView.snp.centerY)
            make.size.equalTo(32)
        }
        bookmarkButton.snp.makeConstraints { (make) in
            make.right.equalTo(postActionsView.snp.right)
            make.centerY.equalTo(postActionsView.snp.centerY)
            make.size.equalTo(32)
        }
    }

    func updatePostStackView() {
        if textComments.text != "" {
            textComments.isHidden = false
            viewCommentsButton.isHidden = false
        } else {
            textComments.isHidden = true
            viewCommentsButton.isHidden = true
        }
    }
}
