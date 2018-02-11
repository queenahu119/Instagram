//
//  FeedTableViewCell.swift
//  MyInstagram
//
//  Created by QueenaHuang on 2017/12/10.
//  Copyright © 2017年 queenahuang. All rights reserved.
//

import UIKit

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
    
    override func awakeFromNib() {
        super.awakeFromNib()

        profile.layer.masksToBounds = false
        profile.layer.cornerRadius = profile.frame.height/2
        profile.clipsToBounds = true

        textComments.isEditable = false
        textComments.isSelectable = false
        textComments.isScrollEnabled = false
        textComments.textContainer.maximumNumberOfLines = 2
        textComments.textContainer.lineBreakMode = .byTruncatingTail

        textComments.translatesAutoresizingMaskIntoConstraints = true
        textComments.sizeToFit()
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
    
}
