//
//  ViewController.swift
//  DynamicTableView
//
//  Created by Jitesh Sharma on 21/02/19.
//  Copyright © 2019 Jitesh Sharma. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SwiftKeychainWrapper

class ViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - UI Component
    var refreshControl: UIRefreshControl!
    var activityIndicator: NVActivityIndicatorView!
    
    lazy var emailTextField: UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "Enter email here"
        textField.backgroundColor = .lightGray
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        textField.delegate = self
        return textField
    }()
    
    lazy var doneButton: UIButton = {
        
        let button = UIButton()
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(ViewController.action1(_:)), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "Welcome"
        // Setting UI Components to display it on screen
        emailTextField.frame = CGRect(x: view.bounds.width/2-150, y: view.bounds.height/2-25, width: 300, height: 50)
        let doneButtonItem = UIBarButtonItem(customView: doneButton)
        self.navigationItem.rightBarButtonItems = [doneButtonItem]
        view.backgroundColor = .white
        view.addSubview(emailTextField)
    }
    
    @IBAction func action1 (_ sender: UIButton) {
        
        guard let providedEmailAddress = emailTextField.text  else {
            displayAlertMessage(messageToDisplay: "⚠️ Kindly enter your email address to go further!")
            return
        }
        let isEmailAddressValid = isValidEmailAddress(emailAddressString: providedEmailAddress)
        
        if isEmailAddressValid {
            
            print("Email address is valid")
            let saveSuccessful: Bool = KeychainWrapper.standard.set(providedEmailAddress, forKey: KeyChainEmailKey)
            if saveSuccessful == false {
                displayAlertMessage(messageToDisplay: "⚠️ Something went wrong, Please try again!")
            } else {
                let homeVC = HomeViewController()
                navigationController?.pushViewController(homeVC, animated: true)
            }
        } else {
            print("Email address is not valid")
            displayAlertMessage(messageToDisplay: "⚠️ Email address is not valid")
        }
        
    }
    
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0 {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
    
    func displayAlertMessage(messageToDisplay: String)
    {
        let alertController = UIAlertController(title: "Alert", message: messageToDisplay, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            
            // Code in this block will trigger when OK button tapped.
            print("Ok button tapped");
            
        }
        
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true, completion:nil)
    }
}

// MARK:- ---> UITextFieldDelegate

extension ViewController {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // return NO to disallow editing.
//        print("TextField should begin editing method called")
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // became first responder
//        print("TextField did begin editing method called")
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
//        print("TextField should end editing method called")
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
//        print("TextField did end editing method called")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        // if implemented, called in place of textFieldDidEndEditing:
//        print("TextField did end editing with reason method called")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // return NO to not change text
//        print("While entering the characters this method gets called")
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        // called when clear button pressed. return NO to ignore (no notifications)
//        print("TextField should clear method called")
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // called when 'return' key pressed. return NO to ignore.
//        print("TextField should return method called")
        // may be useful: textField.resignFirstResponder()
        return true
    }
    
}

// MARK: UITextFieldDelegate <---

