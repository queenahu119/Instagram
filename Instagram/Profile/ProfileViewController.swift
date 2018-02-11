//
//  ProfileViewController.swift
//  Instagram
//
//  Created by QueenaHuang on 22/1/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!

    @IBOutlet weak var fullname: UILabel!
    @IBOutlet weak var numOfPosts: UILabel!
    @IBOutlet weak var numOfFollowers: UILabel!
    @IBOutlet weak var numOfFollowing: UILabel!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!

    var usernameLabel: UILabel!

    var activityIndicator:UIActivityIndicatorView!

    lazy var viewModel: ProfileViewModel = {
        return ProfileViewModel()
    }()

    var imageCache = NSCache<NSString, UIImage>()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavBar()

        setUpUI()

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

        editProfileButton.tintColor = UIColor(red: 29/255, green: 29/255, blue: 29/255, alpha: 1)
        editProfileButton.layer.borderWidth = 1
        editProfileButton.layer.borderColor = UIColor(red: 211/255, green: 213/255, blue: 215/255, alpha: 1).cgColor
        editProfileButton.layer.cornerRadius = 5
        editProfileButton.layer.masksToBounds = false
        editProfileButton.clipsToBounds = true


        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle:
            UIActivityIndicatorViewStyle.gray)
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator);


        // default image
        profileImageView.image = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1).imageRepresentation

        profileImageView.layer.masksToBounds = false
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
    }

    @objc func updateUserData() {

        let user = viewModel.getUserInfoViewModel()

        self.fullname.text = user.fullname
        self.numOfPosts.text = String(user.post)
        self.numOfFollowers.text = String(user.followers)
        self.numOfFollowing.text = String(user.following)
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

    @IBAction func onEditProfile(_ sender: Any) {
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
