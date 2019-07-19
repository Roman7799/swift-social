//
//  LoginVC.swift
//  social
//
//  Created by Ancient on 6/20/19.
//  Copyright © 2019 Ancient. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var Top_Image_Bg: UIImageView!
    //@IBOutlet weak var Top_Image_Bg_constraint_height: NSLayoutConstraint!
    @IBOutlet weak var Top_Image_Bg_constraint_top: NSLayoutConstraint!
    
    @IBOutlet weak var textFieldsView: UIView!
    @IBOutlet weak var Login_Input: UITextField!
    @IBOutlet weak var Password_Input: UITextField!
    
    
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var registerButton_constraint_bottom: NSLayoutConstraint!
    
    var orig_Top_Image_Bg_constraint_top: CGFloat!
    var orig_registerButton_constraint_bottom: CGFloat!
    
    var keyboard_is_hidden: Bool = true
    
    var helper = Helper()
    
    // on load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orig_Top_Image_Bg_constraint_top = Top_Image_Bg_constraint_top.constant
        orig_registerButton_constraint_bottom = registerButton_constraint_bottom.constant
    }
    
    // on appear (or switched to)
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        
        // 10.1
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        // 9.2
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        // 10.1
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        // 9.2
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super .viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // Touched everywhere excluding objects
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // End editing and hide keyboard
        self.view.endEditing(false)
    }
    
    @objc func keyboardWillShowNotification(notification: Notification){
        print("SHOW")
        print("keyboard_is_hidden = ", keyboard_is_hidden)
        
        if(keyboard_is_hidden == true){
            keyboard_is_hidden = false
            Top_Image_Bg_constraint_top.constant -= 75
            
            // Get keyboard size. if true, change register button bottom
            // 10.1
            //if let keyboard_size = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            // 9.2
            if let keyboard_size = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                print("Keyb height = \(keyboard_size.height)")
                registerButton_constraint_bottom.constant += keyboard_size.height
            }
            
            UIView.animate(withDuration: 0.5, animations: {
                self.Top_Image_Bg.alpha = 0
                
                self.view.layoutIfNeeded() // Relayout constraints if values was changed
            })
        }
        
        
    }
    
    @objc func keyboardWillHideNotification(notification: Notification){
        print("HIDE")
        print("keyboard_is_hidden = ", keyboard_is_hidden)
        
        if(keyboard_is_hidden == false){
            keyboard_is_hidden = true
            
            Top_Image_Bg_constraint_top.constant = orig_Top_Image_Bg_constraint_top
            
            // Get keyboard size. if true, change register button bottom
            // 10.1
            //if let keyboard_size = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            // 9.2
            if let keyboard_size = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                print("Keyb height = \(keyboard_size.height)")
                registerButton_constraint_bottom.constant -= keyboard_size.height
            }
            
            UIView.animate(withDuration: 0.5, animations: {
                self.Top_Image_Bg.alpha = 1
                
                self.view.layoutIfNeeded() // Relayout constraints if values was changed
            })
        }
    }
    
    
    
    // on aligments
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configure_textFieldsView()
        configure_loginButton()
        configure_registerButton()
    }
    
    // Login an Password View appearence config
    func configure_textFieldsView(){
        
        let border_width = CGFloat(2)
        let border_color = UIColor.groupTableViewBackground.cgColor
        
        // Border around Login and Password View
        let border = CALayer()
        border.borderColor = border_color
        border.borderWidth = border_width
        border.frame = CGRect(x: 0, y: 0, width: textFieldsView.frame.width, height: textFieldsView.frame.height)
        
        // Line between Login and Password fields
        let line = CALayer()
        line.borderWidth = border_width
        line.borderColor = border_color
        line.frame = CGRect(x: 0, y: textFieldsView.frame.height / 2 - border_width, width: textFieldsView.frame.width, height: border_width)
        
        // Attach layers to Login and Password View
        textFieldsView.layer.addSublayer(border)
        textFieldsView.layer.addSublayer(line)
        
        // Border radius
        textFieldsView.layer.masksToBounds = true
        textFieldsView.layer.cornerRadius = 5
    }
    
    // Login button appearance config
    func configure_loginButton(){
        loginButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = 5
        //loginButton.isEnabled = false
    }
    
    // Register button appearance config
    func configure_registerButton(){

    }
    
    
    
    /****************** EVENTS BEGIN ******************/
    /*************** Interactions BEGIN ***************/
    
    @IBAction func login_btn_clicked(_ sender: Any) {
        print("login_btn_clicked")
    }
    
    // Login Button clicked
    @IBAction func LoginBtn_clicked(_ sender: UIButton) {
        print("Login btn clicked")
        let login = Login_Input.text!
        let password = Password_Input.text!
        
        if(helper.isValid(email: login) == false){
            print("LOGIN NOT VALID")
        }else if(helper.isValid(password: password) == false){
            print("PASSWORD NOT VALID")
        }else{
            print("ALL VALID")
            helper.api_login_user(email: login, password: password, target_view: self, on_complete: { result in
                print("ON COMPLETE LAST")
                print(result)
                
                // This also works
                //let content: NSDictionary = result.object(forKey: "content") as! NSDictionary
                //let user_id: Int = Int(content.object(forKey: "id") as! String)!
                //print("CONTENT(NSDICT):", content)
                //print("USER_ID(INT)", user_id)
                
                if(result.value(forKeyPath: "content.id") != nil){
                
                                    print("ID FOUND")
                    let user_id = result.value(forKeyPath: "content.id")
                
                    current_user["user_id"] = user_id
                    print("USER OBJ TO STORE", current_user)
                    
                    UserDefaults.standard.set(current_user, forKey: "current_user")
                    //UserDefaults.standard.synchronize()
                    
                    // TEST stored user
                    let user_tmp = UserDefaults.standard.object(forKey: "current_user")
                    print("TEST STORED USER", user_tmp)
                    
                    self.helper.instantinate_view_controller(id: "Tab_bar", animated: true, by: self, on_complete: nil)
                }
                
            })
        }
    }

    @IBAction func forgot_pass_clicked(_ sender: Any) {
        print("forgot_pass_clicked")
        
        // Test UserDefaults
        let tmp = UserDefaults.standard.integer(forKey: "uid")
        print(tmp)
        UserDefaults.standard.set(34, forKey: "uid")
    }
    
    
    /**************** Interactions END ****************/
    /******************* EVENTS END *******************/

}
