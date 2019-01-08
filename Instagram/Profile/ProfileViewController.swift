//
//  ProfileViewController.swift
//  Instagram
//
//  Created by QueenaHuang on 22/1/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import UIKit
import SnapKit
import SVProgressHUD

fileprivate struct CollectionSize {
    static var numberOfRow: Int = 3
    static var cellPadding: CGFloat = 3
}

class ProfileViewController: UIViewController, ProfileStateViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!

    let headerId = "headerId"

    var usernameLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.text = ""
        textLabel.textColor = UIColor.black
        textLabel.textAlignment = NSTextAlignment.left

        return textLabel
    }()

    lazy var viewModel: ProfileViewModel = {
        return ProfileViewModel()
    }()

    var imageCache = NSCache<NSString, UIImage>()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavBar()
        setupView()

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
                    SVProgressHUD.show()
                } else {
                    SVProgressHUD.dismiss()
                }
            }
        }

        viewModel.initFetchUserInfo()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        SVProgressHUD.dismiss()
    }
    
    func setUpNavBar() {

        let refreshButton = UIBarButtonItem(title: "refresh", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ProfileViewController.refresh))

        let discoverPeopleButton = UIBarButtonItem(image: UIImage(named:"nav_icon_add_friend"), style: .plain, target: self, action: #selector(ProfileViewController.onDiscoverPeople))


        self.navigationItem.rightBarButtonItems = [discoverPeopleButton, refreshButton]

        let customView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 44.0))
        usernameLabel = UILabel(frame: CGRect(x: 0, y: 0.0, width: 65.0, height: 44.0))

        customView.addSubview(usernameLabel)

        let leftButton = UIBarButtonItem(customView: customView)
        self.navigationItem.leftBarButtonItem = leftButton
    }

    func setupView() {
        collectionView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        collectionView?.register(ProfileStateView.self, forSupplementaryViewOfKind:
            UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
    }

    @objc func updateUserData() {
        if let user = viewModel.getUserInfoViewModel() {
            usernameLabel.text = user.username

            self.collectionView.reloadData()
        }
    }

    @objc func refresh() {

        viewModel.initFetchUserInfo()
    }

    @objc func onDiscoverPeople() {

        self.performSegue(withIdentifier: "DiscoverPeopleView", sender: self)
    }


    @IBAction func unwindToProfile(segue: UIStoryboardSegue) {
        viewModel.fetchProfileData()
    }

    func profileStateViewDelegateDidTapEdit(_ sender: ProfileStateView) {
        self.performSegue(withIdentifier: "EditProfileView", sender: self)
    }
}

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - collectionView
    //MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
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
        cell.imageView.image = defaultBackgroundColor.imageRepresentation

        viewModel.getImageOfCell(at: itemAtIndexPath as IndexPath) { (image, response, error) in
            DispatchQueue.main.async {
                cell.imageView.image = image
            }
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        let height = UIScreen.main.bounds.width*0.4 + 100
        return CGSize(width: UIScreen.main.bounds.width, height: height)

    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier:
            headerId, for: indexPath) as! ProfileStateView
        header.profile = viewModel.getUserInfoViewModel()
        header.delegate = self

        viewModel.getProfileImage(url: nil) { (image, response, error) in
            guard let image = image, error == nil else { return }

            DispatchQueue.main.async {
                header.profileImageView.image = image.circleMask
            }
        }

        header.layoutIfNeeded()

        return header
    }

    //MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(3,0,0,0)
    }

    func collectionViewContentSize() -> CGSize {
        return collectionView!.bounds.size;
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let contentWidth: CGFloat = collectionView.bounds.width - CollectionSize.cellPadding * CGFloat(CollectionSize.numberOfRow - 1)
        let width = contentWidth/CGFloat(CollectionSize.numberOfRow)

        return CGSize(width: width, height: width)
    }

}
