//
//  DiscoverPeopleTableViewController.swift
//  Instagram
//
//  Created by QueenaHuang on 23/1/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import UIKit

protocol PeopleCellDelegate : class {
    func PeopleCellDelegateDidTapFollow(_ sender: PeopleCell)
}

class DiscoverPeopleTableViewController: UITableViewController, PeopleCellDelegate {

    let peopleCellIdentifier = "PeopleCell"

    var activityIndicator:UIActivityIndicatorView!

    lazy var viewModel: DiscoverPeopleViewModel = {
        return DiscoverPeopleViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        viewModel.reloadTableViewClosure = {
            self.tableView.reloadData()
        }

        viewModel.initFetch()
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return viewModel.numberOfCells
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: peopleCellIdentifier, for: indexPath) as! PeopleCell

        let cellViewModel: PeopleCellViewModel = viewModel.getCellViewModel(at: indexPath)

        cell.usernameLabel.text = cellViewModel.usernameText
        cell.fullnameLabel.text = cellViewModel.fullnameText


        cell.profileImageView.image = defaultBackgroundColor.imageRepresentation

        viewModel.getImageOfCell(at: indexPath as IndexPath) { (image, response, error) in
            DispatchQueue.main.async {
                cell.profileImageView.image = image
            }
        }

        cell.delegate = self


        if cellViewModel.isFollowing {
            cell.followButton.setTitle("Unfollow", for: .normal)
        } else {
            cell.followButton.setTitle("Follow", for: .normal)
        }

        cell.followIndicator.isHidden = true

        return cell
    }

    func PeopleCellDelegateDidTapFollow(_ sender: PeopleCell) {

        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }

        viewModel.updateFollowButtonLoadingStatus = { [weak self] () in
            DispatchQueue.main.async {

                let cell: PeopleCell = self?.tableView.cellForRow(at: tappedIndexPath) as! PeopleCell

                let activityIndicator: UIActivityIndicatorView = cell.followIndicator

                let isFollowButtonLoading = self?.viewModel.isFollowButtonLoading ?? false
                if isFollowButtonLoading {
                    cell.followButton.setTitle("", for: .normal)
                    cell.followIndicator.isHidden = false
                    activityIndicator.startAnimating()
                }else {
                    activityIndicator.stopAnimating()

                    self?.tableView.reloadRows(at: [tappedIndexPath], with: UITableViewRowAnimation.none)
                }

            }
        }

        viewModel.setFollowing(index: tappedIndexPath.row)
    }
}

class PeopleCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var followIndicator: UIActivityIndicatorView!
    
    weak var delegate: PeopleCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.selectionStyle = .none
        
        usernameLabel.textColor = UIColor(red: 29/255, green: 29/255, blue: 29/255, alpha: 1)
        fullnameLabel.textColor = UIColor(red: 135/255, green: 135/255, blue: 135/255, alpha: 1)

        profileImageView.layer.masksToBounds = false
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true

        followButton.layer.backgroundColor = UIColor(red: 54/255, green: 125/255, blue: 214/255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.layer.masksToBounds = true
        followButton.tintColor = UIColor.white
        followButton.sizeToFit()

        setupLayout()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }


    @IBAction func followTapped(_ sender: UIButton) {

        delegate?.PeopleCellDelegateDidTapFollow(self)
    }


    func setupLayout() {
        let padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        profileImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(padding.left)
            make.centerY.equalTo(self.snp.centerY)
            make.size.equalTo(profileImageView.frame.height)
        }

        usernameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(profileImageView.snp.right).offset(padding.left)
            make.top.equalTo(self.snp.top).offset(padding.top)
            make.bottom.equalTo(fullnameLabel.snp.top).offset(-5)
            make.right.equalTo(followButton.snp.left).offset(-padding.right)
        }

        fullnameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(usernameLabel.snp.left)
            make.right.equalTo(usernameLabel.snp.right)
            make.top.equalTo(usernameLabel.snp.bottom).offset(5)
            make.bottom.equalTo(self.snp.bottom).offset(-padding.bottom)
        }

        followButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().inset(padding.right)
            make.centerY.equalTo(self.snp.centerY)
            make.height.equalTo(30)
            make.width.equalTo(70)
        }

        followIndicator.snp.makeConstraints { (make) in
            make.edges.equalTo(followButton)
        }
    }
}
