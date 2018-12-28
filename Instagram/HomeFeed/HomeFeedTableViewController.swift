//
//  HomeFeedTableViewController.swift
//  Instagram
//
//  Created by QueenaHuang on 7/1/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import UIKit
import SVProgressHUD

class HomeFeedTableViewController: UITableViewController, UITabBarDelegate, HomeFeedCellDelegate {

    let feedCell = "feedCell"

    lazy var viewModel: HomeFeedViewModel = {
        return HomeFeedViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavBar()

        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 200;

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

        viewModel.reloadTableViewClosure = { [weak self] () in

            self?.tableView.reloadData()
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        viewModel.initFetch()
        viewModel.fetchAllMedias()
    }

    func setUpNavBar() {
        for tabBarItem in (self.tabBarController?.tabBar.items)!
        {
            tabBarItem.title = ""
            tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
        }
    }

    @IBAction func logOutUser(_ sender: Any) {

        if SVProgressHUD.isVisible() {
            SVProgressHUD.dismiss()
        }
        
        viewModel.logOut()

        Helper.displayAlert(vc: self, title: "Log Out Successfully", message: "") {
            self.navigationController?.navigationBar.isHidden = true
            self.tabBarController?.tabBar.isHidden = true

            self.performSegue(withIdentifier: "logoutSegue", sender: self)
        }

    }

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print(#function)
        viewModel.fetchAllMedias()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfTableCells
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: feedCell, for: indexPath) as! FeedTableViewCell

        let cellViewModel: FeedCellViewModel = viewModel.getCellViewModel(at: indexPath)
        cell.post = cellViewModel

        viewModel.getProfileImageOfCell(at: indexPath as IndexPath) { (image, error) in
            DispatchQueue.main.async {
                cell.profile.image = image?.circleMask
            }
        }

        viewModel.getImageOfCell(at: indexPath as IndexPath) { (image, error) in
            DispatchQueue.main.async {
                cell.imageFile.image  = image
            }
        }

        cell.tag = indexPath.row
        cell.delegate = self

        cell.setNeedsUpdateConstraints()
        cell.layoutIfNeeded()

        return cell
    }

    func HomeFeedCellDelegateDidTapLike(_ sender: FeedTableViewCell) {

    }
    
    func HomeFeedCellDelegateDidTapComment(_ sender: FeedTableViewCell) {

        let index = sender.tag
        let cellViewModel: FeedCellViewModel = viewModel.getCellViewModel(at: IndexPath(row: index, section: 0))

        let destinationVC = storyboard?.instantiateViewController(withIdentifier: "CommentsView") as! CommentsViewController
        destinationVC.postId = cellViewModel.id
        destinationVC.hidesBottomBarWhenPushed = true

        self.navigationController?.pushViewController(destinationVC, animated: true)

    }

}
