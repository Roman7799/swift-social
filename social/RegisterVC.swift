//
//  RegisterVC.swift
//  social
//
//  Created by Geolance on 6/24/19.
//  Copyright © 2019 Geolance. All rights reserved.
//

import UIKit

// To dismiss keyboard on tap. Include this code only once per project
extension UIViewController{
    
    func Hide_Keyboard_on_Tap(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss_keyboard) )
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismiss_keyboard(){
        print("DISMISS KEYBOARD")
        view.endEditing(true)
    }
    
}

class RegisterVC: UIViewController {
    
    let helper = Helper()
    let settings = Settings()
    
    // Constraints
    @IBOutlet weak var ContentView_width: NSLayoutConstraint!
    @IBOutlet weak var EmailView_width: NSLayoutConstraint!
    @IBOutlet weak var NameView_width: NSLayoutConstraint!
    @IBOutlet weak var PasswordView_width: NSLayoutConstraint!
    @IBOutlet weak var BirthdayView_width: NSLayoutConstraint!
    @IBOutlet weak var GenderView_width: NSLayoutConstraint!
    
    // UI Objects
    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var Email_EmailInput: UITextField!
    @IBOutlet weak var Name_FirstNameInput: UITextField!
    @IBOutlet weak var Name_LastNameInput: UITextField!
    @IBOutlet weak var Password_PasswordInput: UITextField!
    @IBOutlet weak var Birthday_BirthdayInput: UITextField!
    
    @IBOutlet weak var Email_ContinueBtn: UIButton!
    @IBOutlet weak var Name_ContinueBtn: UIButton!
    @IBOutlet weak var Password_ContionueBtn: UIButton!
    @IBOutlet weak var Birthday_ContinueBtn: UIButton!
    @IBOutlet weak var GenderView_MaleBtn: UIButton!
    @IBOutlet weak var GenderView_FemaleBtn: UIButton!
    
    @IBOutlet weak var FooterView: UIView!
    
    // Code Objects
    var datePicker: UIDatePicker!
    
    // vars
    var current_slide = 1
    
    // -
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.Hide_Keyboard_on_Tap()
        
        ContentView_width.constant = self.view.frame.width * 5
        EmailView_width.constant = self.view.frame.width
        NameView_width.constant = self.view.frame.width
        PasswordView_width.constant = self.view.frame.width
        BirthdayView_width.constant = self.view.frame.width
        GenderView_width.constant = self.view.frame.width
        
        
        //roundCorners(for: Email_EmailInput)
        //roundCorners(for: Email_ContinueBtn)
        
        padding_textfield(for: Email_EmailInput)
        
        helper.style_border_radius(element: Email_EmailInput, value: 10, clip_to_bounds: false, mask_to_bounds: true)
        helper.style_border_radius(element: Email_ContinueBtn, value: 10, clip_to_bounds: false, mask_to_bounds: true)
        helper.style_border_radius(element: Name_FirstNameInput, value: 10, clip_to_bounds: false, mask_to_bounds: true)
        helper.style_border_radius(element: Name_LastNameInput, value: 10, clip_to_bounds: false, mask_to_bounds: true)
        helper.style_border_radius(element: Name_ContinueBtn, value: 10, clip_to_bounds: false, mask_to_bounds: true)
        helper.style_border_radius(element: Password_PasswordInput, value: 10, clip_to_bounds: false, mask_to_bounds: true)
        helper.style_border_radius(element: Password_ContionueBtn, value: 10, clip_to_bounds: false, mask_to_bounds: true)
        helper.style_border_radius(element: Birthday_BirthdayInput, value: 10, clip_to_bounds: false, mask_to_bounds: true)
        helper.style_border_radius(element: Birthday_ContinueBtn, value: 10, clip_to_bounds: false, mask_to_bounds: true)
        
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -5, to: Date())
        datePicker.addTarget(self, action: #selector(self.on_datePicker_change(_:)), for: .valueChanged)
        Birthday_BirthdayInput.inputView = datePicker
        
        // Set swipe func
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(gesture_handler))
        swipe.direction = .right
        self.view.addGestureRecognizer(swipe)
    }
    
    override func viewDidLayoutSubviews() {
        
        // Executes, when all tasks complete (end of queue). Always use this
        // All visual configs go here
        DispatchQueue.main.async {
            self.configure_FooterView()
            self.configure_GenderButtons(for: self.GenderView_MaleBtn)
            self.configure_GenderButtons(for: self.GenderView_FemaleBtn)
        }
        
    }
    
    // Touched everywhere excluding objects
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        // End editing and hide keyboard
//        print("TOUCH BEGAN")
//        self.view.endEditing(false)
//    }
    
    // Round elements. Pass any UI object
    func roundCorners(for view: UIView){
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
    }
    
    // Make padding for text field
    func padding_textfield(for textField: UITextField){
        let blank_view = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.leftView = blank_view
        textField.leftViewMode = .always
    }
    
    @objc func gesture_handler(gesture: UISwipeGestureRecognizer){
        print("SWIPE RIGHT")
        print("CURRENT_SLIDE = " + String(current_slide))
        let helper = Helper()
        if(current_slide > 1){
            print("SLIDE TRIGGERED")
            current_slide -= 1
            helper.set_scroll_horizontal_position(scrollView: ScrollView, slide_num: current_slide)
        }
    }
    
    func configure_FooterView(){
        let line = CALayer()
        line.borderWidth = 1
        line.borderColor = UIColor.lightGray.cgColor
        line.frame = CGRect(x: 0, y: 0, width: FooterView.frame.width, height: 1.5)
        
        // Attach layers to Login and Password View
        //textFieldsView.layer.addSublayer(border)
        FooterView.layer.addSublayer(line)
    }
    
    func configure_GenderButtons(for genderBtn: UIButton){
        
        // Border
//        let border = CALayer()
//        border.borderColor = UIColor.lightGray.cgColor
//        border.borderWidth = 1
//        border.frame = CGRect(x: 0, y: 0, width: genderBtn.frame.width, height: genderBtn.frame.height)
//        genderBtn.layer.addSublayer(border)
        // Border End
        
        
    }
    
    // EVENTS BEGIN
    // Interactions BEGIN
    
    // TextField change
    @IBAction func on_TextField_change(_ textField: UITextField) {
        let helper = Helper()
        
        if(textField === Email_EmailInput){
            if(helper.isValid(email: textField.text!)){
                 print("VALID")
                Email_ContinueBtn.isHidden = false
            }else{
                print("NOT VALID")
                Email_ContinueBtn.isHidden = true
            }
        }
        
        if(textField === Name_FirstNameInput || textField === Name_LastNameInput){
            if(helper.isValid(name: Name_FirstNameInput.text!) && helper.isValid(name: Name_LastNameInput.text!)){
                print("VALID")
                Name_ContinueBtn.isHidden = false
            }else{
                Name_ContinueBtn.isHidden = true
            }
        }
        
        if(textField === Password_PasswordInput){
            if(helper.isValid(password: textField.text!) && textField.text!.count >= 6){
                print("VALID")
                Password_ContionueBtn.isHidden = false
            }else{
                Password_ContionueBtn.isHidden = true
            }
        }
    }
    
    @objc func on_datePicker_change(_ datePicker: UIDatePicker){
        
        let date_formatter = DateFormatter()
        date_formatter.dateStyle = DateFormatter.Style.medium
        Birthday_BirthdayInput.text = date_formatter.string(from: datePicker.date)
        print("DATE:", datePicker.date)
        
        let max_date = Calendar.current.date(byAdding: .year, value: -5, to: Date())!
        let compare_date_formatter = DateFormatter()
        compare_date_formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        if(datePicker.date >= max_date){
            print("DATE MORE THEN MAX")
            Birthday_ContinueBtn.isHidden = true
        }else{
            print ("DATE OK")
            Birthday_ContinueBtn.isHidden = false
        }
        
    }
    
    // Have account Button clicked
    @IBAction func cancelBtn_clicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Email Continue Button clicked
    @IBAction func EmailView_continueBtn_clicked(_ sender: Any) {
        let helper = Helper()
        if(helper.isValid(email: Email_EmailInput.text!)){
            current_slide = 2
            helper.set_scroll_horizontal_position(scrollView: ScrollView, slide_num: current_slide)
            if(Name_FirstNameInput.text!.isEmpty){
                Name_FirstNameInput.becomeFirstResponder()
            }else if(Name_LastNameInput.text!.isEmpty){
                Name_LastNameInput.becomeFirstResponder()
            }else if((Name_FirstNameInput.text!.isEmpty == false) && (Name_LastNameInput.text!.isEmpty == false)){
                Name_FirstNameInput.resignFirstResponder()
                Name_LastNameInput.resignFirstResponder()
            }
        }
    }
    
    // Name Continue Button clicked
    @IBAction func NameView_continueBtn_clicked(_ sender: Any) {
        let helper = Helper()
        if(helper.isValid(name: Name_FirstNameInput.text!) && helper.isValid(name: Name_LastNameInput.text!)){
            current_slide = 3
            helper.set_scroll_horizontal_position(scrollView: ScrollView, slide_num: current_slide)
            if(Password_PasswordInput.text!.isEmpty){
                Password_PasswordInput.becomeFirstResponder()
            }else{
                Password_PasswordInput.resignFirstResponder()
            }
        }
    }
    
    // Password Continue Button clicked
    @IBAction func PasswordView_continueBtn_clicked(_ sender: Any) {
        let helper = Helper()
        current_slide = 4
        if(helper.isValid(password: Password_PasswordInput.text!) && Password_PasswordInput.text!.count >= 6){
            helper.set_scroll_horizontal_position(scrollView: ScrollView, slide_num: current_slide)
            if(Birthday_BirthdayInput.text!.isEmpty){
                Birthday_BirthdayInput.becomeFirstResponder()
            }else{
                Birthday_BirthdayInput.resignFirstResponder()
            }
        }
    }
    
    // Birthday Continue Button clicked
    @IBAction func BirthdayView_continueBtn_clicked(_ sender: Any) {
        let helper = Helper()
        let max_date = Calendar.current.date(byAdding: .year, value: -5, to: Date())!
        let compare_date_formatter = DateFormatter()
        compare_date_formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        if(datePicker.date >= max_date){
            print("CONT DATE MORE THEN MAX")
        }else{
            print ("CONT DATE OK")
            current_slide = 5
            helper.set_scroll_horizontal_position(scrollView: ScrollView, slide_num: current_slide)
            Birthday_BirthdayInput.resignFirstResponder()
        }
    }
    
    
    // Gender clicked
    @IBAction func Gender_anyGenderBtn_clicked(_ sender: UIButton) {
        let helper = Helper()
        
        let gender = String(sender.tag)
        let date_formatter = DateFormatter()
        date_formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let date = date_formatter.string(from: datePicker.date)
        
        helper.api_register_user(email: Email_EmailInput.text!, password: Password_PasswordInput.text!, first_name: Name_FirstNameInput.text!, last_name: Name_LastNameInput.text!, birthday: date, gender: gender, target_view: self, on_complete: { result in
            // Go to Tabs like after login?
            print("REGISTER END POINT", result)
            if(result["status"] as! Int == 1){
                
                let content = result["content"] as! NSDictionary
                
                /*
                let ready_data: NSMutableDictionary = [
                    "user_id": result.value(forKey: "content.id"),
                    "first_name": result.value(forKey: "content.first_name")!,
                    "last_name": result.value(forKey: "content.last_name")!,
                    "birthday": result.value(forKey: "content.birthday")!,
                    "gender": result.value(forKey: "content.gender")!
                ]
                 */
                var ready_data: NSMutableDictionary = [:
                    //"user_id": helper.cast(value: content["id"]),
//                    "first_name": helper.cast(value: content["first_name"]),
//                    "last_name": helper.cast(value: content["last_name"]),
//                    "birthday": helper.cast(value: content["birthday"]),
//                    "gender": helper.cast(value: content["gender"]),
                    //"cover": helper.cast(value: content["cover"]),
                    //"avatar": helper.cast(value: content["avatar"])
                ]
                ready_data["user_id"] = helper.cast(value: content["id"])
                ready_data["email"] = helper.cast(value: content["email"])
                ready_data["first_name"] = helper.cast(value: content["first_name"])
                ready_data["last_name"] = helper.cast(value: content["last_name"])
                ready_data["birthday"] = helper.cast(value: content["birthday"])
                ready_data["gender"] = helper.cast(value: content["gender"])
                ready_data["allow_friends"] = helper.cast(value: content["allow_friends"])
                ready_data["allow_follow"] = helper.cast(value: content["allow_follow"])
                ready_data["cover"] = helper.cast(value: content["cover"])
                ready_data["avatar"] = helper.cast(value: content["avatar"])
                /*
                if(content["cover"] is NSNull){
                    print("empty trigger")
                    ready_data["cover"] = nil
                }else{
                    ready_data["cover"] = content["cover"]
                }
                if(content["avatar"] is NSNull){
                    ready_data["avatar"] = nil
                }else{
                    ready_data["avatar"] = content["avatar"]
                }
                */
                current_user = ready_data.mutableCopy() as! NSMutableDictionary
                
                print(current_user)
                UserDefaults.standard.set(current_user, forKey: "current_user")
                UserDefaults.standard.synchronize()
                helper.instantinate_view_controller(id: "Tab_bar", animated: true, by: self, on_complete: nil)
            }else{
                // show error
                helper.show_alert_ok(title: "Error", message: result["error"] as! String, target_view: self)
            }
        })
        
    }
    
    // Interactions END
    // EVENTS END
    

}
