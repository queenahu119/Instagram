//
//  EditProfileTableViewController.swift
//  Instagram
//
//  Created by QueenaHuang on 9/1/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import UIKit

class EditProfileTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    let HeaderCellId = "HeaderCell"
    let ProfileCellId = "ProfileCell"

    var dicOfInfo = [String: String]()

    var profileImage: UIImage!

    let activityIndicator = UIActivityIndicatorView()
    
    var headerView : UserHeaderTableViewCell!

    lazy var viewModel: EditProfileModel = {
        return EditProfileModel()
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavBar()
        setUpLoading()
        
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

        viewModel.reloadAccountInfoClosure = {
            self.dicOfInfo = self.viewModel.getAccountInfo()
        }

        viewModel.updateInfoAfterCompletion = { (success, title, message) in
            DispatchQueue.main.async {

                if success {
                    self.performSegue(withIdentifier: "unwindToProfile", sender: self)
                } else {
                    Helper.displayAlert(vc: self, title: title!, message: message!, completion: nil)
                }
            }
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


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileCellId, for: indexPath) as! ProfileCell

        let info = viewModel.getCellViewModel(at: indexPath)
        cell.labelField.text = info["fieldName"] ?? ""
        cell.inputText.text = info["data"] ?? ""
        cell.inputText.delegate = self
        cell.inputText.tag = indexPath.row

        cell.inputText.addTarget(self, action: #selector(textFieldDidChange(_ :)), for: .editingChanged)

        return cell
    }


    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if section == 0 {
            headerView = (tableView.dequeueReusableCell(withIdentifier: HeaderCellId) as? UserHeaderTableViewCell)

            // default image
            headerView.profileImage.image = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1).imageRepresentation

            viewModel.getProfileImage(completion: { (image, response, error) in
                self.headerView.profileImage.image  = image
            })

            headerView.changePhotoButton.addTarget(self, action: #selector(onChangeProfilePhoto), for: .touchUpInside)

            return headerView

        } else {

            return nil
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 160
    }

    func setUpNavBar() {
        let doneButton = UIBarButtonItem(title: "Done",
                                          style: .plain,
                                          target: self,
                                          action: #selector(onDone))
        self.navigationItem.rightBarButtonItem = doneButton

        let cancelButton = UIBarButtonItem(title: "Cancel",
                                         style: .plain,
                                         target: self,
                                         action: #selector(onCancel))
        self.navigationItem.leftBarButtonItem = cancelButton
    }

    @objc func onDone() {

        print("dicOfInfo: ", dicOfInfo)

        viewModel.submitProfile(info: dicOfInfo, profileImage: headerView?.profileImage.image)
    }

    @objc func onCancel() {
        
        self.performSegue(withIdentifier: "unwindToProfile", sender: self)
    }

    @objc func onChangeProfilePhoto(){
        let optionMenu = UIAlertController(title: nil, message: "Change Profile Photo", preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: "Take Photo", style: .default) { (alert) in
            print("take photo")
            self.camera()
        }

        let libraryAction = UIAlertAction(title: "Choose From Library", style: .default) { (alert) in
            print("from library")
            self.photoLibrary()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        optionMenu.addAction(cameraAction)
        optionMenu.addAction(libraryAction)
        optionMenu.addAction(cancelAction)

        self.present(optionMenu, animated: true, completion: nil)
    }


    //MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        switch textField.tag {
        case 0:
            dicOfInfo["Name"] = textField.text
            break
        case 1:
            dicOfInfo["Username"] = textField.text
            break
        case 2:
            dicOfInfo["Email"] = textField.text
            break
        case 3:
            dicOfInfo["Bio"] = textField.text
            break
        default:
            break
        }

    }

    //MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            headerView?.profileImage.image = image
        }

        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - private function
    func camera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera

            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    func photoLibrary()
    {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self;
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    func setUpLoading() {

        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
    }

}

class ProfileCell: UITableViewCell {

    @IBOutlet weak var labelField: UILabel!
    
    @IBOutlet weak var inputText: UITextField!
    
}


