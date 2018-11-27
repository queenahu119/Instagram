//
//  LoginViewController.swift
//  Instagram
//
//  Created by QueenaHuang on 6/1/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import UIKit
import SnapKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var appName: UILabel!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signupOrLoninButton: UIButton!
    @IBOutlet weak var switchLoninModeButton: UIButton!
    @IBOutlet weak var noteLabel: UILabel!

    var signUpModeActive = false

    lazy var viewModel: LoginViewModel = {
        return LoginViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        
        password.delegate = self

        viewModel.initFetch()
    }

    func setUpUI() {

        view.backgroundColor = UIColor.white

        signupOrLoninButton.backgroundColor = UIColor(red: 58/255, green: 135/255, blue: 232/255, alpha: 1)
        signupOrLoninButton.layer.cornerRadius = 5
        signupOrLoninButton.layer.masksToBounds = true
        signupOrLoninButton.tintColor = UIColor.white

        appName.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(view)
            make.height.equalTo(45)
            make.bottom.equalTo(username.snp.top).offset(-20)
        }

        username.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.height.equalTo(45)
            make.bottom.equalTo(password.snp.top).offset(-10)
        }

        password.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(username)
            make.right.equalTo(username)
            make.height.equalTo(50)
            make.bottom.equalTo(view.snp.centerY).offset(-20)
        }

        signupOrLoninButton.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(username)
            make.right.equalTo(username)
            make.height.equalTo(45)
            make.top.equalTo(password.snp.bottom).offset(20)
        }

        noteLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(view).offset(20)
            make.height.equalTo(40)
            make.right.equalTo(switchLoninModeButton.snp.left)
            make.bottom.equalTo(view).offset(-8)
        }

        switchLoninModeButton.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(noteLabel.snp.right).offset(20)
            make.height.equalTo(40)
            make.width.equalTo(switchLoninModeButton.frame.size.width)
            make.bottom.equalTo(noteLabel.snp.bottom)
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        
        if viewModel.isLogin() {
            self.performSegue(withIdentifier: "showMainView", sender: self)
        }
    }

    @IBAction func signupOrLogin(_ sender: Any) {

        // Validate Text Field
        let (validUsername, messageUsername) = validate(username)
        let (validPassword, messagePassword) = validate(password)

        var errorMessage: String? = nil

        if !validUsername {
            errorMessage = messageUsername!
        } else if !validPassword {
            errorMessage = messagePassword!
        }

        if let errorMessage = errorMessage {
            Helper.displayAlert(vc: self, title: "Error in form", message: errorMessage, completion: nil)
        } else {

            let user: [String: String] = ["username": username.text!, "password": password.text!]

            if (signUpModeActive) {
                // sign up
                viewModel.signUp(data: user, performSegue: {

                    self.performSegue(withIdentifier: "showMainView", sender: self)
                    
                }, showAlert: { (title, errMessage) in

                    Helper.displayAlert(vc: self, title: title, message: errMessage, completion: nil)
                })

            } else {
                // log in

                viewModel.logIn(data: user, performSegue: {
                    self.performSegue(withIdentifier: "showMainView", sender: self)
                }, showAlert: { (title, errMessage) in
                    Helper.displayAlert(vc: self, title: title, message: errMessage, completion: nil)
                })
            }
        }
    }

    @IBAction func switchLoninMode(_ sender: Any) {

        if signUpModeActive {

            signUpModeActive = false

            signupOrLoninButton.setTitle("Log In", for: .normal)
            switchLoninModeButton.setTitle("Sign Up", for: .normal)
        } else {
            signUpModeActive = true

            signupOrLoninButton.setTitle("Sign Up", for: [])
            switchLoninModeButton.setTitle("Log In", for: [])
        }
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if textField == password {
            textField.resignFirstResponder()
        }
        return true
    }

    // MARK: - Helper Methods

    fileprivate func validate(_ textField: UITextField) -> (Bool, String?) {

        // For test
        if InstagramStub.detect() {
            return (true, nil)
        }

        guard let text = textField.text else {
            return (false, nil)
        }

        if textField == password {
            return (text.count >= 4, "Your password is too short.")
        }

        return (text.count > 0, "This field cannot be empty.")
    }


}
