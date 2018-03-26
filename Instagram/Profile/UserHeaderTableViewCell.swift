//
//  UserHeaderTableViewCell.swift
//  Instagram
//
//  Created by QueenaHuang on 9/1/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import UIKit
import SnapKit

class UserHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var changePhotoButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        setupViews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    let separatorLineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        lineView.isHidden = true
        return lineView
    }()

    func setupViews() {

        profileImage.layer.masksToBounds = false
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true

        separatorLineView.isHidden = false;
        separatorLineView.backgroundColor = UIColor(red: 230, green: 230, blue: 230, alpha: 1)

        clipsToBounds = true
        addSubview(separatorLineView)

        profileImage.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(self.snp.top).offset(20)
            make.bottom.equalTo(changePhotoButton.snp.top).offset(-5)
            make.size.equalTo(100)
        })

        changePhotoButton.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.bottom.equalTo(self.snp.bottom).offset(-20)
        })
    }


    

}

