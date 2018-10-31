//
//  HomeFeedTableViewController.swift
//  Instagram
//
//  Created by QueenaHuang on 7/1/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import UIKit
import Parse


protocol HomeFeedCellDelegate : class {
    func HomeFeedCellDelegateDidTapLike(_ sender: FeedTableViewCell)
    func HomeFeedCellDelegateDidTapComment(_ sender: FeedTableViewCell)
}

class HomeFeedTableViewController: UITableViewController, UITabBarDelegate, HomeFeedCellDelegate {

    let feedCell = "feedCell"

    var activityIndicator:UIActivityIndicatorView!
    
    lazy var viewModel: HomeFeedViewModel = {
        return HomeFeedViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavBar()

        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 200;

        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle:
            UIActivityIndicatorViewStyle.gray)
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator);

        viewModel.updateLoadingStatus = { [weak self] () in
            DispatchQueue.main.async {
                let isLoading = self?.viewModel.isLoading ?? false
                if isLoading {
                    self?.activityIndicator.startAnimating()

                }else {
                    self?.activityIndicator.stopAnimating()

                }
            }
        }

        viewModel.reloadTableViewClosure = { [weak self] () in

            self?.tableView.reloadData()
        }

    }

    override func viewWillAppear(_ animated: Bool) {

        viewModel.initFetch()

        viewModel.fetchMedias()
    }

    func setUpNavBar() {
        for tabBarItem in (self.tabBarController?.tabBar.items)!
        {
            tabBarItem.title = ""
            tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
        }
    }

    @IBAction func logOutUser(_ sender: Any) {
        PFUser.logOut()

        Helper.displayAlert(vc: self, title: "Log Out Successfully", message: "") {
            self.navigationController?.navigationBar.isHidden = true
            self.tabBarController?.tabBar.isHidden = true

            self.performSegue(withIdentifier: "logoutSegue", sender: self)
        }

    }

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print(#function)
        viewModel.fetchMedias()
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

        let comment = cellViewModel.comments?.replacingOccurrences(of: "\n", with: "")

        cell.username.text = cellViewModel.username
        cell.textComments.text = comment

//        print("text: [\(cell.textComments.text)]")
        viewModel.getProfileImageOfCell(at: indexPath as IndexPath) { (image, response, error) in
            DispatchQueue.main.async {
                cell.profile.image = image
            }
        }

        viewModel.getImageOfCell(at: indexPath as IndexPath) { (image, response, error) in
            DispatchQueue.main.async {
                cell.imageFile.image  = image
            }
        }

        cell.textNumOfLike.text = "3 likes"

        let creationDate = cellViewModel.dateText
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm dd/MM yyyy"
        cell.textPostTime.text = dateFormatter.string(from: creationDate!)

        cell.tag = indexPath.row
        cell.delegate = self

//        print("start:")
        cell.setNeedsUpdateConstraints()
        cell.setNeedsLayout()
//        print("end.")

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
