//
//  FeedTableViewCell.swift
//  MyInstagram
//
//  Created by QueenaHuang on 2017/12/10.
//  Copyright © 2017年 queenahuang. All rights reserved.
//

import UIKit
import SnapKit

class FeedTableViewCell: UITableViewCell {

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var imageFile: UIImageView!

    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!

    @IBOutlet weak var textNumOfLike: UILabel!
    @IBOutlet weak var textComments: UITextView!
    @IBOutlet weak var viewCommentsButton: UIButton!
    @IBOutlet weak var textPostTime: UILabel!

    weak var delegate: HomeFeedCellDelegate?

//    var heightConstraint: Constraint? = nil

    override func awakeFromNib() {
        super.awakeFromNib()

        profile.layer.masksToBounds = false
        profile.layer.cornerRadius = 25
        profile.clipsToBounds = true

        textComments.isEditable = false
        textComments.isSelectable = false
        textComments.isScrollEnabled = false
        textComments.textContainer.maximumNumberOfLines = 0
        textComments.textContainer.lineBreakMode = .byTruncatingTail
        textComments.translatesAutoresizingMaskIntoConstraints = true
        textComments.contentInset = UIEdgeInsets(top: -5, left: -5, bottom: -5, right: -5)

        imageFile.contentMode = .scaleToFill

        textNumOfLike.sizeToFit()
        textPostTime.sizeToFit()

        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func likeTapped(_ sender: Any) {
        delegate?.HomeFeedCellDelegateDidTapLike(self)
    }
    
    @IBAction func commentTapped(_ sender: Any) {
        delegate?.HomeFeedCellDelegateDidTapComment(self)
    }

    override func updateConstraints()
    {
        setupUI()

        super.updateConstraints()
    }

    func setupUI() {

        let padding = UIEdgeInsets(top: 8, left: 8, bottom: -8, right: -8)


        profile.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView.snp.top).offset(padding.top)
            make.left.equalTo(self.contentView.snp.left).offset(padding.left)
            make.size.equalTo(50)
        }
        username.snp.makeConstraints { (make) in
            make.centerY.equalTo(profile.snp.centerY)
            make.left.equalTo(profile.snp.right).offset(padding.left)
            make.right.equalTo(moreButton.snp.left).offset(padding.right).priority(.medium)
        }
        moreButton.snp.makeConstraints { (make) in
            make.left.equalTo(username.snp.right).offset(padding.left).priority(.medium)
            make.right.equalTo(self.contentView.snp.right).offset(padding.right)
            make.centerY.equalTo(profile.snp.centerY)
            make.size.equalTo(30)
        }

        imageFile.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView.snp.left)
            make.top.equalTo(profile.snp.bottom).offset(8)
            make.right.equalTo(self.contentView.snp.right)
            make.height.equalTo(200)
        }

        favoriteButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView.snp.left).offset(padding.left)
            make.right.equalTo(commentButton.snp.left)
            make.top.equalTo(imageFile.snp.bottom).offset(padding.top)
            make.size.equalTo(30)
        }
        commentButton.snp.makeConstraints { (make) in
            make.left.equalTo(favoriteButton.snp.right)
            make.right.equalTo(shareButton.snp.left)
            make.top.equalTo(favoriteButton.snp.top)
            make.size.equalTo(30)
        }
        shareButton.snp.makeConstraints { (make) in
            make.left.equalTo(commentButton.snp.right)
            make.top.equalTo(favoriteButton.snp.top)
            make.size.equalTo(30)
        }

        bookmarkButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.contentView.snp.right).offset(padding.right)
            make.top.equalTo(favoriteButton.snp.top)
            make.size.equalTo(30)
        }

        textNumOfLike.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView.snp.left).offset(padding.left)
            make.right.equalTo(self.contentView.snp.right).offset(padding.right)
            make.top.equalTo(favoriteButton.snp.bottom).offset(padding.top)
            make.bottom.equalTo(textComments.snp.top)
        }

//        let fixedWidth = textComments.frame.size.width
//        textComments.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
//        let newSize = textComments.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
//        var newFrame = textComments.frame
//        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
//        textComments.frame = newFrame

        let width = textComments.frame.width

        let sizeThatFits = textComments.sizeThatFits(CGSize(width: width+10, height: CGFloat(MAXFLOAT)))


//        print("sizeThatFits: ", sizeThatFits.height)
        textComments.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView.snp.left).offset(padding.left)
            make.right.equalTo(self.contentView.snp.right).offset(padding.right)
            make.top.equalTo(textNumOfLike.snp.bottom)
            make.bottom.equalTo(viewCommentsButton.snp.top)
            make.height.equalTo(sizeThatFits.height)
        }
        viewCommentsButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView.snp.left).offset(padding.left)
            make.right.equalTo(self.contentView.snp.right).offset(padding.right)
            make.top.equalTo(textComments.snp.bottom)
            make.bottom.equalTo(textPostTime.snp.top)
        }
        textPostTime.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView.snp.left).offset(padding.left)
            make.right.equalTo(self.contentView.snp.right).offset(padding.right)
            make.top.equalTo(viewCommentsButton.snp.bottom)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(padding.bottom)
        }

    }
}
