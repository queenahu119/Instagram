//
//  EditProfileTableViewController.swift
//  Instagram
//
//  Created by QueenaHuang on 9/1/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import UIKit
import SVProgressHUD

class EditProfileTableViewController: UITableViewController {

    let HeaderCellId = "HeaderCell"
    let ProfileCellId = "ProfileCell"

    var infoList = [Profile]()
    var profileImage: UIImage!

    var headerView : UserHeaderTableViewCell!

    lazy var viewModel: EditProfileModel = {
        return EditProfileModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavBar()

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
        
        viewModel.reloadTableViewClosure = {
            self.infoList = self.viewModel.getProfile()
            self.tableView.reloadData()
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

        if let info = viewModel.getCellViewModel(at: indexPath) {
            cell.labelField.text = info.field
            cell.inputText.text = info.data
            cell.inputText.delegate = self
            cell.inputText.tag = indexPath.row
            cell.inputText.addTarget(self, action: #selector(textFieldDidChange(_ :)), for: .editingChanged)
        }

        return cell
    }


    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if section == 0 {
            headerView = (tableView.dequeueReusableCell(withIdentifier: HeaderCellId) as? UserHeaderTableViewCell)

            // default image
            headerView.profileImage.image = defaultBackgroundColor.imageRepresentation

            viewModel.getProfileImage(completion: { (image, response, error) in
                DispatchQueue.main.async {
                    self.headerView.profileImage.image  = image?.circleMask
                }
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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    // MARK: - UI
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

    // MARK: - Action
    @objc func onDone() {
        viewModel.submitProfile(info: infoList, profileImage: headerView?.profileImage.image)
    }

    @objc func onCancel() {

        self.performSegue(withIdentifier: "unwindToProfile", sender: self)
    }

    @objc func onChangeProfilePhoto(){
        let optionMenu = UIAlertController(title: nil, message: "Change Profile Photo", preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: "Take Photo", style: .default) { (alert) in
            self.camera()
        }

        let libraryAction = UIAlertAction(title: "Choose From Library", style: .default) { (alert) in
            self.photoLibrary()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        optionMenu.addAction(cameraAction)
        optionMenu.addAction(libraryAction)
        optionMenu.addAction(cancelAction)

        self.present(optionMenu, animated: true, completion: nil)
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
}

extension EditProfileTableViewController: UINavigationControllerDelegate,
                                        UIImagePickerControllerDelegate,
                                        UITextFieldDelegate {
    //MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.tag >= self.infoList.count {
            return
        }

        self.infoList[textField.tag].data = textField.text ?? ""
    }

    //MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            headerView?.profileImage.image = image
        }

        self.dismiss(animated: true, completion: nil)
    }
}
class ProfileCell: UITableViewCell {

    @IBOutlet weak var labelField: UILabel!
    @IBOutlet weak var inputText: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.selectionStyle = .none
        
        setupLayout()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func setupLayout() {
        let padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        labelField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(padding.left)
            make.centerY.equalTo(self.snp.centerY)
            make.width.equalTo(100)
            make.height.equalTo(25)
            make.right.equalTo(inputText.snp.left).offset(-padding.right)
        }

        inputText.snp.makeConstraints { (make) in
            make.left.equalTo(labelField.snp.right).offset(padding.left)
            make.centerY.equalTo(self.snp.centerY)
            make.height.equalTo(inputText.frame.height)
            make.right.equalToSuperview().inset(padding.right)
        }
    }
}


