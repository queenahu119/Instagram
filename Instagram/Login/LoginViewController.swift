//
//  LoginViewController.swift
//  Instagram
//
//  Created by QueenaHuang on 6/1/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signupOrLoninButton: UIButton!
    @IBOutlet weak var switchLoninModeButton: UIButton!

    var signUpModeActive = false

    lazy var viewModel: LoginViewModel = {
        return LoginViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        password.delegate = self

        viewModel.initFetch()
    }

    override func viewDidAppear(_ animated: Bool) {
        
        if viewModel.isLogin() {
            print("Log In Now")
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
        guard let text = textField.text else {
            return (false, nil)
        }

        if textField == password {
            return (text.count >= 4, "Your password is too short.")
        }

        return (text.count > 0, "This field cannot be empty.")
    }


}
