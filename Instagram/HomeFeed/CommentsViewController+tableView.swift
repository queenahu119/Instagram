//
//  CommentsTableViewController.swift
//  Instagram
//
//  Created by QueenaHuang on 1/2/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import UIKit

extension CommentsViewController: UITableViewDataSource, UITableViewDelegate {

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return viewModel.numberOfCells
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCell", for: indexPath) as! CommentTableViewCell

        let cellViewModel: CommentCellViewModel = viewModel.getCellViewModel(at: indexPath)

        cell.comment = cellViewModel

        viewModel.updateProfileImageAfterCompletion = { (image, response, error) in
            DispatchQueue.main.async {
                cell.profileImage.image = image?.circleMask
            }
        }

        viewModel.getImageOfCell(at: indexPath) { (image, error) in
            if error == nil {
                DispatchQueue.main.async {
                    cell.profileImage.image = image?.circleMask
                }
            }
        }

        cell.setNeedsUpdateConstraints()
        cell.layoutIfNeeded()
        
        return cell
    }
}
