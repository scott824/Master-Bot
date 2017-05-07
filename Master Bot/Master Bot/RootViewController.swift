//
//  ViewController.swift
//  Master Bot
//
//  Created by Sang Chul Lee on 2017. 4. 28..
//  Copyright © 2017년 SC_production. All rights reserved.
//

import UIKit

protocol InputTextDelegate {
    var inputText: String? {get set}
}


/// **Root View Controller**
///
/// Include `InputView`, `SuggestionBarView` and `ContentsController`
///
/// There are logics for:
/// 1. Setting keyboard animation with `InputView` and `SuggestionBarView`
/// 2. Intermediate `InputView` with `SuggestionBarView` by `SuggestionBarDelegate`
/// 3. Send input value from `InputView` to `ContentsController`

class RootViewController: UIViewController, SuggestionBarDelegate {
    
//* Included instances *//
    
    /// ContentsController instance
    var contentsController: InputTextDelegate! = nil
    
    /// SuggestionBar instance
    var suggestionBarView: SuggestionBarView! = nil
    
    
    
//* Outlets of Interface Builder *//

    /// Root view outlet
    @IBOutlet var RootView: UIView!
    
    /// wrapper view for ContentsContainerView and InputView
    @IBOutlet weak var ContainerView: UIView!
    @IBOutlet weak var ContainerViewBottomConstraint: NSLayoutConstraint!
    
    /// contents container view
    @IBOutlet weak var ContentsContainerView: UIView!
    
    /// input view which include `InputTextField` and `SendButton`
    @IBOutlet weak var InputView: UIView!
    @IBOutlet weak var InputTextField: UITextField!
    @IBOutlet weak var SendButton: UIButton!
    
    
    
//* Override functions *//
    
    /// initialization function of Root View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // display `SuggestionBarView` on top of the keyboard
        suggestionBarView = SuggestionBarView(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        suggestionBarView.rootViewController = self
        suggestionBarView.backgroundColor = UIColor.white
        InputTextField.inputAccessoryView = suggestionBarView
        
        // observer for keyboard layout
        NotificationCenter.default.addObserver(self, selector: #selector(RootViewController.keyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RootViewController.keyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // hide keyboard if user tab other area
        let tab = UITapGestureRecognizer(target: self, action: #selector(RootViewController.dismissKeyboard))
        view.addGestureRecognizer(tab)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // segue to ContentsController
        if segue.identifier == "send" {
            contentsController = segue.destination as! ContentsController
        }
    }
    
    

//* Get user's input *//

    /// Input value of `InputTextField` - SuggestionBar delegate variable
    var inputTextFieldValue: String {
        get {
            if let text = InputTextField.text {
                return text
            } else {
                return ""
            }
        }
        // if there is new input, modify `SuggestionBarView`
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
        suggestionBarView.search(for: inputTextFieldValue)
    }
    
    @IBAction func ClickSendButton(_ sender: Any) {
        NSLog("Click Send Button")
        contentsController.inputText = inputTextFieldValue
        inputTextFieldValue = ""
        dismissKeyboard()
    }
    
    
    
//* Keyboard action *//
    
    /// move view when keyboard show/hide
    func keyboardNotification(notification: Notification) {
        let userInfo = notification.userInfo!
        let keyboardHight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! UInt
        let moveUp = notification.name == NSNotification.Name.UIKeyboardWillShow
        
        ContainerViewBottomConstraint.constant = moveUp ? -keyboardHight : 0
        let option = UIViewAnimationOptions(rawValue: curve << 16)
        
        UIView.animate(withDuration: duration, delay: 0, options: option, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    /// hide keyboard
    func dismissKeyboard() {
        InputTextField.endEditing(true)
    }

}

