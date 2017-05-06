//
//  ViewController.swift
//  Master Bot
//
//  Created by Sang Chul Lee on 2017. 4. 28..
//  Copyright © 2017년 SC_production. All rights reserved.
//

import UIKit


/**
 
 Root View Controller - include InputView, SuggestionBarView, ContentsController
 
 - Author: Sangchul Lee
 
*/


class ViewController: UIViewController, SuggestionBarDelegate {
    
    // ContentsController
    var contentsController: ContentsController! = nil
    
    // SuggestionBar
    var suggestionBarView: SuggestionBarView! = nil
    
    
    
////////////////////////////////////////////////////////////////////////////////
//
//  Outlet of Interface Builder
//
////////////////////////////////////////////////////////////////////////////////
    
    // Root view
    @IBOutlet var ApplicationView: UIView!
    
    // wrapper view for ContentsContainView and InputView
    @IBOutlet weak var ContentsInputView: UIView!
    @IBOutlet weak var ContentsInputViewBottomConstraint: NSLayoutConstraint!
    
    // contents table view (chat)
    @IBOutlet weak var ContentsTableContainer: UIView!
    
    // bottom input view
    @IBOutlet weak var InputView: UIView!
    @IBOutlet weak var InputTextField: UITextField!
    @IBOutlet weak var SendButton: UIButton!
    
    
    
////////////////////////////////////////////////////////////////////////////////
//
//  Override functions
//      viewDidLoad() - initialization function of UIViewController
//      didReceiveMemoryWarning()
//      prepare() - for segue
//
////////////////////////////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // display recommendation depends on words user write
        suggestionBarView = SuggestionBarView(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        suggestionBarView.viewController = self
        suggestionBarView.backgroundColor = UIColor.white
        InputTextField.inputAccessoryView = suggestionBarView
        
        // observer for keyboard layout
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // hide keyboard if user tab other area
        let tab = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tab)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // segue to ContentsController
        if segue.identifier == "send" {
            NSLog("set destination")
            contentsController = segue.destination as! ContentsController
        }
        
    }
    
    
    
////////////////////////////////////////////////////////////////////////////////
//
//  Get user's input
//
////////////////////////////////////////////////////////////////////////////////
    
    // suggestion bar delegate variable
    var inputTextFieldValue: String {
        get {
            if let text = InputTextField.text {
                return text
            } else {
                return ""
            }
        }
        set(text) {
            InputTextField.text = text
            searchByInputText()
        }
    }
    
    // action when Input text field is changed
    @IBAction func EditingInputTextValue(_ sender: Any) {
        searchByInputText()
    }
    
    // search suggestion words in suggestion bar
    func searchByInputText() {
        suggestionBarView.search(input: inputTextFieldValue)
    }
    
    @IBAction func ClickSendButton(_ sender: Any) {
        NSLog("Click Send Button")
        contentsController.inputText = inputTextFieldValue
        inputTextFieldValue = ""
        dismissKeyboard()
    }
    
    
    
////////////////////////////////////////////////////////////////////////////////
//
//  Keyboard action
//
////////////////////////////////////////////////////////////////////////////////
    
    // move view when keyboard show/hide
    func keyboardNotification(notification: Notification) {
        let userInfo = notification.userInfo!
        let keyboardHight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! UInt
        let moveUp = notification.name == NSNotification.Name.UIKeyboardWillShow
        
        ContentsInputViewBottomConstraint.constant = moveUp ? -keyboardHight : 0
        let option = UIViewAnimationOptions(rawValue: curve << 16)
        
        UIView.animate(withDuration: duration, delay: 0, options: option, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // hide keyboard
    func dismissKeyboard() {
        InputTextField.endEditing(true)
    }

}

