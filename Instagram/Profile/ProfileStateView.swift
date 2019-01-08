//
//  ProfileState.swift
//  Instagram
//
//  Created by Queena Huang on 30/11/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import UIKit
import SnapKit

protocol ProfileStateViewDelegate : class {
    func profileStateViewDelegateDidTapEdit(_ sender: ProfileStateView)
}

class ProfileStateView: UICollectionReusableView {
    weak var delegate: ProfileStateViewDelegate?

    var profile: ProfilData? {
        didSet {
            guard let profile = profile else {
                return
            }

            postView.numLabel.text = String(profile.post)
            followersView.numLabel.text = String(profile.followers)
            followingsView.numLabel.text = String(profile.following)

            textFullname.text = profile.fullname
            textBio.text = profile.bio

            adjustBioTextHeight()
        }
    }

    var postView = StateView()
    var followersView = StateView()
    var followingsView = StateView()

    let profileImageSize: CGFloat = UIScreen.main.bounds.width*0.25
    var bioViewHeight: CGFloat = 100
    var bioViewHeightConstraint: Constraint?
    
    var profileImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.layer.masksToBounds = false
        imageView.clipsToBounds = true
        return imageView
    }()

    var editProfileButton: UIButton = {
        let button = UIButton()
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)

        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = false
        button.clipsToBounds = true
        return button
    }()

    var textFullname: UILabel = {
        let txt = UILabel()
        txt.font = UIFont.boldSystemFont(ofSize: 14)
        txt.sizeToFit()
        return txt
    }()

    var textBio: UILabel = {
        let txt = UILabel()
        txt.font = UIFont.systemFont(ofSize: 14)
        txt.numberOfLines = 0
        txt.sizeToFit()
        return txt
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - layout
    func setupViews() {

        let padding = UIEdgeInsetsMake(5, 12, -5, -12)
        let stateWidth = (UIScreen.main.bounds.width - profileImageSize - padding.left*3)/3

        for view in [postView, followersView, followingsView] {
            view.frame = CGRect(x: 0, y: 0, width: stateWidth, height: stateWidth)
            self.addSubview(view)
        }

        self.addSubview(profileImageView)
        self.addSubview(editProfileButton)

        profileImageView.image = defaultBackgroundColor.imageRepresentation
        profileImageView.layer.cornerRadius = profileImageSize/2

        postView.textLabel.text = "posts"
        followersView.textLabel.text = "followers"
        followingsView.textLabel.text = "followings"

        editProfileButton.addTarget(self, action: #selector(onEditProfile), for: .touchUpInside)

        profileImageView.snp.makeConstraints { make in
            make.left.equalTo(self.snp.left).offset(padding.left)
            make.top.equalTo(self.snp.top).offset(20)
            make.height.equalTo(profileImageSize)
            make.width.equalTo(profileImageSize)
        }

        postView.snp.makeConstraints { (make) in
            make.left.equalTo(profileImageView.snp.right).offset(padding.left)
            make.top.equalTo(profileImageView.snp.top)
            make.width.equalTo(stateWidth)
            make.bottom.equalTo(editProfileButton.snp.top).offset(padding.bottom)
        }

        followersView.snp.makeConstraints { (make) in
            make.left.equalTo(postView.snp.right)
            make.top.equalTo(postView.snp.top)
            make.width.equalTo(stateWidth)
            make.bottom.equalTo(postView.snp.bottom)
        }

        followingsView.snp.makeConstraints { (make) in
            make.left.equalTo(followersView.snp.right)
            make.right.equalTo(self.snp.right).offset(padding.right)
            make.top.equalTo(postView.snp.top)
            make.width.equalTo(stateWidth)
            make.bottom.equalTo(postView.snp.bottom)
        }

        editProfileButton.snp.makeConstraints { (make) in
            make.left.equalTo(profileImageView.snp.right).offset(padding.left)
            make.top.equalTo(postView.snp.bottom).offset(padding.top)
            make.height.equalTo(25)
            make.right.equalTo(self.snp.right).offset(padding.right)
            make.bottom.equalTo(profileImageView.snp.bottom).offset(padding.bottom)
        }

        addSubview(textFullname)
        addSubview(textBio)

        textFullname.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(padding.left)
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
            make.height.equalTo(20)
        }

        textBio.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(padding.left)
            make.top.equalTo(textFullname.snp.bottom).offset(10)
            bioViewHeightConstraint = make.height.equalTo(bioViewHeight).constraint
        }
    }

    func adjustBioTextHeight() {
        let fixedWidth = textBio.frame.size.width
        let newSize = textBio.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        self.bioViewHeightConstraint?.update(offset: newSize.height)
        self.layoutIfNeeded()
        bioViewHeight = newSize.height + 20
    }

    // MARK: - Actions
    @objc func onEditProfile() {
        delegate?.profileStateViewDelegateDidTapEdit(self)
    }
}

class StateView: CustomView {
    var numLabel: UILabel = {
        let txt = UILabel()
        txt.textAlignment = .center
        txt.font = UIFont.boldSystemFont(ofSize: 16)
        txt.sizeToFit()
        return txt
    }()

    var textLabel: UILabel = {
        let txt = UILabel()
        txt.textAlignment = .center
        txt.font = UIFont.systemFont(ofSize: 14)
        txt.sizeToFit()
        txt.textColor = UIColor.gray
        return txt
    }()

    override func setupViews() {
        addSubview(numLabel)
        addSubview(textLabel)

        numLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(textLabel.snp.top)
            make.height.equalTo(20)
            make.left.right.equalToSuperview()
        }

        textLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.height.equalTo(20)
            make.left.right.equalToSuperview()
        }
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
