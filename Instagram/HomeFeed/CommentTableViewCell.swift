//
//  CommentTableViewCell.swift
//  Instagram
//
//  Created by QueenaHuang on 1/2/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    let profileImageSize = 40
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentLabel: UILabel!

    var didSetupConstraints = false

    var comment: CommentCellViewModel? {
        didSet {
            guard let comment = comment else {
                return
            }

            let userName = comment.userName + " "
            let attrsForName = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17)]
            let attrsForComment = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)]

            let mutableString = NSMutableAttributedString(string:userName , attributes:attrsForName)
            let mutableStringForComment = NSMutableAttributedString(string: comment.text ?? "", attributes: attrsForComment)

            mutableString.append(mutableStringForComment)
            commentLabel.attributedText = mutableString
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.selectionStyle = .none

        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.layer.masksToBounds = false
        profileImage.layer.cornerRadius = CGFloat(profileImageSize) / 2
        profileImage.clipsToBounds = true

        commentLabel.numberOfLines = 0

        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.setImage(UIImage(named: "tableView_btn_heart_n"), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func updateConstraints() {

        if !didSetupConstraints {
            setupLayout()

            didSetupConstraints = true
        }
        super.updateConstraints()
    }

    func setupLayout() {
        let padding = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)

        profileImage.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(padding.left)
            make.right.equalTo(commentLabel.snp.left).offset(-padding.right)
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.size.equalTo(profileImageSize)
        }

        commentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(profileImage.snp.right).offset(padding.left)
            make.top.bottom.equalToSuperview().inset(padding.top)
            make.right.equalTo(likeButton.snp.left).offset(-padding.right)
            make.height.greaterThanOrEqualTo(30)
        }

        likeButton.snp.makeConstraints { (make) in
            make.left.equalTo(commentLabel.snp.right).offset(padding.left)
            make.right.equalToSuperview().inset(padding.right)
            make.top.equalToSuperview().inset(padding.top)
            make.size.equalTo(20)
        }
    }

}
