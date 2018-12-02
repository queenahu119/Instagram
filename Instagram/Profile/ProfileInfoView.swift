//
//  ProfileInfoView.swift
//  Instagram
//
//  Created by Queena Huang on 30/11/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import UIKit
import SnapKit

class ProfileInfoView: CustomView {

    var height: CGFloat = 100

    var profile: ProfilData? {
        didSet {
            guard let profile = profile else {
                return
            }

            textFullname.text = profile.fullname
            textViewBio.text = profile.bio

            adjustTextViewHeight()
        }
    }

    var textFullname: UILabel = {
        let txt = UILabel()
        txt.font = UIFont.boldSystemFont(ofSize: 14)
        txt.sizeToFit()
        return txt
    }()

    var textViewBio: UITextView = {
        let txt = UITextView()
        txt.font = UIFont.systemFont(ofSize: 14)
        txt.isEditable = false
        txt.isSelectable = false
        txt.isScrollEnabled = false
        txt.contentInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: -5)
        return txt
    }()

    var textHeightConstraint: Constraint?

    // MARK: - layout
    override func setupViews() {
        addSubview(textFullname)
        addSubview(textViewBio)

        let padding = UIEdgeInsetsMake(12, 12, -12, -12)

        textFullname.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(padding.left)
            make.top.equalToSuperview()
            make.height.equalTo(20)
        }

        textViewBio.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(padding.left)
            make.top.equalTo(textFullname.snp.bottom)
            textHeightConstraint = make.height.equalTo(50).constraint
        }
    }

    func adjustTextViewHeight() {
        let fixedWidth = textViewBio.frame.size.width
        let newSize = textViewBio.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        self.textHeightConstraint?.update(offset: newSize.height)
        self.layoutIfNeeded()
        height = textFullname.frame.size.height + newSize.height
    }
}

class CustomView: UIView {
    var shouldSetupConstraints = true

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func updateConstraints() {
        if(shouldSetupConstraints) {
            // AutoLayout constraints
            setupViews()
            shouldSetupConstraints = false
        }
        super.updateConstraints()
    }

    // MARK: - layout
    func setupViews() {
    }
}
