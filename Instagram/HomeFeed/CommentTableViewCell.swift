//
//  CommentTableViewCell.swift
//  Instagram
//
//  Created by QueenaHuang on 1/2/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var likeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.selectionStyle = .none
        profileImage.layer.masksToBounds = false
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true

        textView.isEditable = false
        textView.isSelectable = false

        setupLayout()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupLayout() {
        let padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        profileImage.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(padding.left)
            make.centerY.equalTo(self.snp.centerY)
            make.size.equalTo(profileImage.frame.height)
        }

        textView.snp.makeConstraints { (make) in
            make.left.equalTo(profileImage.snp.right).offset(padding.left)
            make.top.bottom.equalToSuperview().inset(padding.top)
            make.right.equalTo(likeButton.snp.left).offset(-padding.right)
        }

        likeButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(padding.right)
            make.centerY.equalTo(self.snp.centerY)
            make.size.equalTo(30)
        }
    }

}
