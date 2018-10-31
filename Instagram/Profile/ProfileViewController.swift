//
//  ProfileViewController.swift
//  Instagram
//
//  Created by QueenaHuang on 22/1/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import UIKit
import SnapKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var usernameLabel: UILabel!

    var activityIndicator:UIActivityIndicatorView!

    lazy var viewModel: ProfileViewModel = {
        return ProfileViewModel()
    }()

    var imageCache = NSCache<NSString, UIImage>()

    var textFullname: UILabel = {
        let txt = UILabel()
        return txt
    }()

    var profileImageView: UIImageView = {
        var imageView = UIImageView()
        return imageView
    }()

    var editProfileButton: UIButton = {
        let button = UIButton()
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(UIColor(red: 29/255, green: 29/255, blue: 29/255, alpha: 1), for: .normal)

        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 211/255, green: 213/255, blue: 215/255, alpha: 1).cgColor
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = false
        button.clipsToBounds = true
        return button
    }()

    let numOfPosts: UILabel = {
        let txt = UILabel()
        txt.text = "22"
        txt.textAlignment = .center
        txt.sizeToFit()
        return txt
    }()
    let numOfFollowers: UILabel = {
        let txt = UILabel()
        txt.text = "169"
        txt.textAlignment = .center
        txt.sizeToFit()
        return txt
    }()
    let numOfFollowings: UILabel = {
        let txt = UILabel()
        txt.text = "34"
        txt.textAlignment = .center
        txt.sizeToFit()
        return txt
    }()
    let textPosts: UILabel = {
        let txt = UILabel()
        txt.text = "posts"
        txt.textAlignment = .center
        txt.sizeToFit()
        txt.textColor = UIColor.gray
        return txt
    }()
    let textFollowers: UILabel = {
        let txt = UILabel()
        txt.text = "followers"
        txt.textAlignment = .center
        txt.sizeToFit()
        txt.textColor = UIColor.gray
        return txt
    }()
    let textFollowings: UILabel = {
        let txt = UILabel()
        txt.text = "followings"
        txt.textAlignment = .center
        txt.sizeToFit()
        txt.textColor = UIColor.gray
        return txt
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavBar()

        setUpUI()

        editProfileButton.addTarget(self, action: #selector(onEditProfile), for: .touchUpInside)
        
        viewModel.reloadUserClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.updateUserData()
            }
        }

        viewModel.reloadPhotoListViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }

        viewModel.updateLoadingStatus = { [weak self] () in
            DispatchQueue.main.async {
                let isLoading = self?.viewModel.isLoading ?? false
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.collectionView.alpha = 0.3
                    })
                }else {
                    self?.activityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.collectionView.alpha = 1.0
                    })
                }
            }

        }

        viewModel.initFetchUserInfo()

    }

    func setUpNavBar() {

        let refreshButton = UIBarButtonItem(title: "refresh", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ProfileViewController.refresh))

        let discoverPeopleButton = UIBarButtonItem(image: UIImage(named:"nav_icon_add_friend"), style: .plain, target: self, action: #selector(ProfileViewController.onDiscoverPeople))


        self.navigationItem.rightBarButtonItems = [discoverPeopleButton, refreshButton]

        let customView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 44.0))
        usernameLabel = UILabel(frame: CGRect(x: 0, y: 0.0, width: 65.0, height: 44.0))
        usernameLabel.text = ""
        usernameLabel.textColor = UIColor.black
        usernameLabel.textAlignment = NSTextAlignment.left
        customView.addSubview(usernameLabel)

        let leftButton = UIBarButtonItem(customView: customView)
        self.navigationItem.leftBarButtonItem = leftButton
    }

    func setUpUI() {

        view.addSubview(editProfileButton)
        view.addSubview(profileImageView)
        view.addSubview(textFullname)
        view.addSubview(numOfPosts)
        view.addSubview(numOfFollowers)
        view.addSubview(numOfFollowings)
        view.addSubview(textPosts)
        view.addSubview(textFollowers)
        view.addSubview(textFollowings)

        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle:
            UIActivityIndicatorViewStyle.gray)
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator);

        let screenWidth: CGFloat = UIScreen.main.bounds.width
        let profileImageWidth: CGFloat = 70 //screenWidth*0.25

        // default image
        profileImageView.image = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1).imageRepresentation
        profileImageView.layer.cornerRadius = profileImageWidth/2
        profileImageView.layer.masksToBounds = false
        profileImageView.clipsToBounds = true

        let padding = UIEdgeInsetsMake(5, 5, -5, -5)


        profileImageView.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).offset(15)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.height.equalTo(profileImageWidth)
            make.width.equalTo(profileImageWidth)
        }

        textFullname.snp.makeConstraints { make in
            make.left.equalTo(profileImageView.snp.left)
            make.top.equalTo(profileImageView.snp.bottom).offset(padding.top)
            make.height.equalTo(22)
            make.width.equalTo(100)
        }

        editProfileButton.snp.makeConstraints { (make) in
            make.left.equalTo(profileImageView.snp.right).offset(10)
            make.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-15)
            make.bottom.equalTo(profileImageView.snp.lastBaseline)
            make.height.equalTo(25)
        }

        numOfPosts.snp.makeConstraints { (make) in
            make.left.equalTo(textPosts.snp.left)
            make.right.equalTo(textPosts.snp.right)
            make.top.equalTo(profileImageView.snp.top).offset(padding.top)
            make.bottom.equalTo(textPosts.snp.top)
        }
        numOfFollowers.snp.makeConstraints { (make) in
            make.left.equalTo(textFollowers.snp.left)
            make.right.equalTo(textFollowers.snp.right)
            make.top.equalTo(numOfPosts.snp.top)
            make.bottom.equalTo(numOfPosts.snp.bottom)
        }
        numOfFollowings.snp.makeConstraints { (make) in
            make.left.equalTo(textFollowings.snp.left)
            make.right.equalTo(textFollowings.snp.right)
            make.top.equalTo(numOfPosts.snp.top)
            make.bottom.equalTo(numOfPosts.snp.bottom)
        }

        textPosts.snp.makeConstraints { (make) in
            make.left.equalTo(editProfileButton.snp.left)
            make.right.equalTo(textFollowers.snp.left).offset(padding.right)
            make.top.equalTo(numOfPosts.snp.bottom)
            make.bottom.equalTo(editProfileButton.snp.top).offset(padding.bottom)
        }
        textFollowers.snp.makeConstraints { (make) in
            make.left.equalTo(textPosts.snp.right).offset(padding.left)
            make.right.equalTo(textFollowings.snp.left).offset(padding.right)
            make.top.equalTo(textPosts.snp.top)
            make.bottom.equalTo(textPosts.snp.bottom)
        }
        textFollowings.snp.makeConstraints { (make) in
            make.left.equalTo(textFollowers.snp.right).offset(padding.left)
            make.right.equalTo(editProfileButton.snp.right)
            make.top.equalTo(textPosts.snp.top)
            make.bottom.equalTo(textPosts.snp.bottom)
        }

    }

    @objc func updateUserData() {

        let user = viewModel.getUserInfoViewModel()

        self.textFullname.text = user.fullname
        self.numOfPosts.text = String(user.post)
        self.numOfFollowers.text = String(user.followers)
        self.numOfFollowings.text = String(user.following)
        self.usernameLabel.text = String(user.username)

        viewModel.getProfileImage(url: nil) { (image, response, error) in
            guard let image = image, error == nil else { return }

            DispatchQueue.main.async {
                self.profileImageView.image = image
            }
        }
    }

    @objc func refresh() {

        viewModel.initFetchUserInfo()
    }

    @objc func onDiscoverPeople() {

        self.performSegue(withIdentifier: "DiscoverPeopleView", sender: self)
    }

    @objc func onEditProfile() {
        self.performSegue(withIdentifier: "EditProfileView", sender: self)
    }

    @IBAction func unwindToProfile(segue: UIStoryboardSegue) {}
}

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{

    // MARK: - collectionView
    //MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1     //return number of sections in collection view
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfPhotoCells
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath as IndexPath) as! ImageCollectionViewCell
        configureCell(cell: cell, itemAtIndexPath: indexPath as NSIndexPath)
        return cell      
    }

    func configureCell(cell: ImageCollectionViewCell, itemAtIndexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.blue

        cell.imageView.contentMode = .scaleAspectFill

        // default image
        cell.imageView.image = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1).imageRepresentation

        viewModel.getImageOfCell(at: itemAtIndexPath as IndexPath) { (image, response, error) in
            DispatchQueue.main.async {
                cell.imageView.image = image
            }
        }

    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "collectionCell", for: indexPath)
        return view
    }

    //MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5,5,5,5)
    }

    fileprivate struct CollectionSize {
        static var numberOfColumns: Int = 3
        static var cellPadding: CGFloat = 6
    }

    func collectionViewContentSize() -> CGSize {
        return collectionView!.bounds.size;
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let contentWidth: CGFloat = collectionView.bounds.width - (CollectionSize.cellPadding * 2) - CollectionSize.cellPadding * CGFloat(CollectionSize.numberOfColumns - 2)
        let width = contentWidth/CGFloat(CollectionSize.numberOfColumns)

        return CGSize(width: width, height: width)
    }


}
