//
//  EditProfileVC.swift
//  social
//
//  Created by Geolance on 7/9/19.
//  Copyright © 2019 Geolance. All rights reserved.
//

import UIKit
import Photos

class EditProfileVC: UITableViewController
    ,UINavigationControllerDelegate, UIImagePickerControllerDelegate
    ,UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var Cover: UIImageView!
    @IBOutlet weak var Avatar: UIImageView!
    @IBOutlet weak var Firstname: UITextField!
    @IBOutlet weak var Lastname: UITextField!
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var Birthday: UITextField!
    @IBOutlet weak var Gender: UITextField!
    @IBOutlet weak var Allow_Friends: UISwitch!
    @IBOutlet weak var Allow_Follow: UISwitch!
    
    let helper = Helper()
    let settings = Settings()
    
    let picker = UIImagePickerController()
    var is_cover = false
    var is_avatar = false
    var image_view_tapped = ""
    //var default_cover = "image_placeholder.png"
    //var default_avatar = "image_placeholder.png"
    var is_password_changed = false
    var is_cover_changed = false
    var is_avatar_changed = false
    var is_cover_deleted = false
    var is_avatar_deleted = false
    var datePicker: UIDatePicker!
    var gender_picker: UIPickerView!
    var gender_values = ["Male", "Female"]
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        picker.delegate = self
        
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -5, to: Date())
        datePicker.addTarget(self, action: #selector(self.on_datePicker_change(_:)), for: .valueChanged)
        Birthday.inputView = datePicker
        
        gender_picker = UIPickerView()
        gender_picker.delegate = self
        gender_picker.dataSource = self
        Gender.inputView = gender_picker
        
        reload_user_data()
    }
    
    // Func after autolayout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
        // All visuals go here
        configure_Avatar_View()
        configure_registerButton()
    }

/*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
*/
/*
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
*/
    
    
    
    
    
    /****************** EVENTS *******************/
    /* INTERACTIONS */
    
    // Return to previous view (HomeVC)
    @IBAction func Cancel_clicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // Save changes
    @IBAction func Save_clicked(_ sender: Any) {
        
        guard let user_id = current_user["user_id"] as? String else{
            return
        }
        
        let email = Email.text ?? ""
        var password = ""
        if(is_password_changed == true){
            password = Password.text ?? ""
        }else{
            password = ""
        }
        let first_name = Firstname.text ?? ""
        let last_name = Lastname.text ?? ""
        
        let date_formatter = DateFormatter()
        date_formatter.dateFormat = settings.date_format_server
        let birthday = date_formatter.string(from: datePicker.date)
        
        var gender = String()
        if(Gender.text == "Male"){
            gender = "1"
        }else if(Gender.text == "Female"){
            gender = "2"
        }
        
        var allow_friends = String();
        if(Allow_Friends.isOn == true){
            allow_friends = "1"
        }else{
            allow_friends = "0"
        }
        
        var allow_follow = String();
        if(Allow_Follow.isOn == true){
            allow_follow = "1"
        }else{
            allow_follow = "0"
        }
        
        
        // Validate
        if(helper.isValid(email: email) == false){
            helper.show_alert_ok(title: "ERROR", message: "Invalid Email", target_view: self)
            return
        }else if(helper.isValid(name: first_name) == false){
            helper.show_alert_ok(title: "ERROR", message: "Invalid Firstname", target_view: self)
            return
        }else if(helper.isValid(name: last_name) == false){
            helper.show_alert_ok(title: "ERROR", message: "Invalid Lastname", target_view: self)
            return
        }else if(is_password_changed){
            if(helper.isValid(password: password) == false){
                helper.show_alert_ok(title: "ERROR", message: "Invalid Password", target_view: self)
                return
            }
        }else if(Gender.text != "Male" && Gender.text != "Female"){
            helper.show_alert_ok(title: "ERROR", message: "Invalid gender", target_view: self)
            return
        }
        // Validation OK, Continue
        
        var cover: UIImage?
        var avatar: UIImage?
        if(is_cover_changed == true){
            if(is_cover_deleted){
                cover = nil
            }else{
                cover = Cover.image
            }
        }else{
            cover = nil
        }
        if(is_avatar_changed == true){
            if(is_cover_deleted){
                avatar = nil
            }else{
                avatar = Avatar.image
            }
        }else{
            avatar = nil
        }
        
        helper.api_update_user_info(user_id: user_id, email: email, password: password, first_name: first_name, last_name: last_name, birthday: birthday, gender: gender, allow_friends: allow_friends, allow_follow: allow_follow, cover: cover, is_cover_deleted: is_cover_deleted, avatar: avatar, is_avatar_deleted: is_avatar_deleted, target_view: self, on_complete: {result in
            
            if(result["status"] as! Int == 1){
                print("USER INFO UPDATED:", result)
                
                let content = result["content"] as! NSDictionary
                
                current_user["email"] = self.helper.cast(value: content["email"])
                current_user["first_name"] = self.helper.cast(value: content["first_name"])
                current_user["last_name"] = self.helper.cast(value: content["last_name"])
                current_user["birthday"] = self.helper.cast(value: content["birthday"])
                current_user["gender"] = self.helper.cast(value: content["gender"])
                current_user["allow_friends"] = self.helper.cast(value: content["allow_friends"])
                current_user["allow_follow"] = self.helper.cast(value: content["allow_follow"])
                if(self.is_cover_changed){
                    if(self.is_cover_deleted){
                        current_user["cover"] = ""
                    }else{
                        current_user["cover"] = content["cover"]
                    }
                }
                if(self.is_avatar_changed){
                    current_user_avatar = nil
                    if(self.is_avatar_deleted){
                        current_user["avatar"] = ""
                    }else{
                        current_user["avatar"] = content["avatar"]
                    }
                }
                
                print(current_user)
                UserDefaults.standard.set(current_user, forKey: "current_user")
                
                self.helper.show_alert_ok(title: "Success", message: "Info updated", target_view: self)
                //self.dismiss(animated: true, completion: nil)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update_user_info"), object: nil)
            }else{
                self.helper.show_alert_ok(title: "Error", message: result["error"] as! String, target_view: self)
            }

        })
        
    }
    
    
    @IBAction func Cover_tapped(_ sender: Any) {
        print("COVER TAPPED")
        image_view_tapped = "cover"
        show_action_sheet()
        //show_image_picker(source: UIImagePickerController.SourceType.photoLibrary)
    }
    @IBAction func Avatar_tapped(_ sender: Any) {
        print("AVATAR TAPPED")
        image_view_tapped = "avatar"
        show_action_sheet()
    }
    

    
    /* INTERACTIONS END */
    /* HOOKS */
    
    // Triggers after image was picked from library
    // 10.1
    //func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    // 9.2
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //let user_id = Int(current_user["user_id"] as! String)!
        
        //let image = info[.editedImage] as? UIImage
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        print("PICKED IMAGE", image)
        if(image == nil){
            print("image IS nil")
            return
        }
        
        if(self.image_view_tapped == "cover"){
            print("COVER SET")
            Cover.image = image
            is_cover_changed = true
            is_cover_deleted = false
            is_cover = true
            // Image will upload only after Save clicked
    
        }else if(self.image_view_tapped == "avatar"){
            print("AVATAR SET")
            Avatar.image = image
            is_avatar_changed = true
            is_avatar_deleted = false
            is_avatar = true
            
            // Image will upload only after Save clicked
        }
        
        dismiss(animated: true, completion: {
            print("IMAGE PICKER DISMISSED")
            /*
            if(self.image_view_tapped == "cover"){
                self.is_cover = true
            }else if(self.image_view_tapped == "avatar"){
                self.is_avatar = true
            }
            */
        })
    }
    
    // When Datepicker changes
    @objc func on_datePicker_change(_ datePicker: UIDatePicker){
        let date_formatter = DateFormatter()
        date_formatter.dateStyle = DateFormatter.Style.medium
        Birthday.text = date_formatter.string(from: datePicker.date)
    }
    
    // Picker changed
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        Gender.text = gender_values[row]
        Gender.resignFirstResponder()
    }
    
    @IBAction func on_Password_changed(_ sender: UITextField) {
        if(sender == Password){
            print("PASSWORD SET CHANGED")
            is_password_changed = true
        }
        
    }
    
    
    /* HOOKS END */
    /**************** EVENTS END *****************/
    /****************** VISUALS ******************/
    
    func configure_Avatar_View(){
        helper.add_border(target_view: Avatar, width: 5, color: UIColor.white.cgColor)
        Avatar.layer.cornerRadius = 10
        Avatar.layer.masksToBounds = true
        Avatar.clipsToBounds = true
        
    }
    
    func configure_registerButton(){
        
    }
    
    /**************** VISUALS END ****************/
    /******************* FUNCS *******************/
    /* OTHER */
    
    // Repopulate all fields in current view from global user
    func reload_user_data(){
        
        // First name
        if let first_name = current_user["first_name"] as? String{
            Firstname.text = "\(first_name.capitalized)"
        }
        
        if let last_name = current_user["last_name"] as? String{
            Lastname.text = "\(last_name.capitalized)"
        }
        
        if let email = current_user["email"] as? String{
            Email.text = email
        }
        
        if let birthday = current_user["birthday"] as? String{
            let date_set = helper.date_string_convert(date_string: birthday, from_format: settings.date_format_server, to_format: settings.date_format_front)
            Birthday.text = date_set
        }
        
        if let gender = current_user["gender"] as? String{
            if(gender == "1"){
                Gender.text = "Male"
            }else if(gender == "2"){
                Gender.text = "Female"
            }
        }
        
        // Allow Friends
        if let allow_friends = current_user["allow_friends"] as? String{
            
            if(allow_friends == "1"){
                Allow_Friends.isOn = true
            }else{
                Allow_Friends.isOn = false
            }
        }else{
            Allow_Friends.isOn = false
        }
        
        // Allow Follow
        print(current_user["allow_friends"] as? String)
        if let allow_follow = current_user["allow_follow"] as? String{
            
            if(allow_follow == "1"){
                print("follow_true")
                Allow_Follow.isOn = true
            }else{
                print("follow_false")
                Allow_Follow.isOn = false
            }
        }else{
            Allow_Follow.isOn = false
        }
        
        
        // Avatar
        if let avatar_url = current_user["avatar"] as? String{
            if(avatar_url.isEmpty == false){
                let url = URL(string: avatar_url)!
                
                if(current_user_avatar == nil){
                    // No stored Avatar
                    helper.download_image(url: url, on_complete: {(image) in
                        self.Avatar.image = image
                        self.is_avatar = true
                    })
                }else{
                    // Stored Avatar exists
                    self.Avatar.image = current_user_avatar
                    self.is_avatar = true
                }
                
            }
        }
        
        // Cover
        if let cover_url = current_user["cover"] as? String{
            if(cover_url.isEmpty == false){
                let url = URL(string: cover_url)!
                
                helper.download_image(url: url, on_complete: {(image) in
                    self.Cover.image = image
                    self.is_cover = true
                })
            }
        }
        
    }
    
    // Show image action sheet
    func show_action_sheet(){
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Camera button
        let action_camera = UIAlertAction(title: "Camera", style: .default, handler: {(action) in
            print("ACTION CAMERA")
            
            if(UIImagePickerController.isSourceTypeAvailable( .camera )){
                self.show_image_picker(source: .camera)
            }else{
                print("CAMERA NOT AVAILIABLE")
            }
        })
        
        // Library button
        let action_library = UIAlertAction(title: "Photo library", style: .default, handler: {(action) in
            print("ACTION LIBRARY")
            
            if(UIImagePickerController.isSourceTypeAvailable( .photoLibrary )){
                self.show_image_picker(source: .photoLibrary)
            }else{
                print("LIBRARY NOT AVAILIABLE")
            }
        })
        
        // Cancel button
        let action_cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Delete button
        let action_delete = UIAlertAction(title: "Delete", style: .destructive, handler: {(action) in
            print("ACTION DELETE")
            
            if(self.image_view_tapped == "cover"){
                self.Cover.image = UIImage(named: self.settings.default_cover)
                self.is_cover = false
                self.is_cover_deleted = true
                self.is_cover_changed = true

            }else if(self.image_view_tapped == "avatar"){
                self.Avatar.image = UIImage(named: self.settings.default_avatar)
                self.is_avatar = false
                self.is_avatar_deleted = true
                self.is_avatar_changed = true
            }
            
        })
        if(image_view_tapped == "cover" && is_cover == false){
            action_delete.isEnabled = false
        }else if(image_view_tapped == "avatar" && is_avatar == false){
            action_delete.isEnabled = false
        }
        
        sheet.addAction(action_camera)
        sheet.addAction(action_library)
        sheet.addAction(action_cancel)
        sheet.addAction(action_delete)
        self.present(sheet, animated: true, completion: nil)
    }
    
    // 10.1
    //func show_image_picker(source: UIImagePickerController.SourceType){
    // 9.2
    func show_image_picker(source: UIImagePickerControllerSourceType){
        
        if(source == .photoLibrary){
            helper.access_photo(on_success: {
                self.picker.allowsEditing = true
                self.picker.sourceType = source
                self.present(self.picker, animated: true, completion: nil)
            }, on_denied: {
                self.helper.show_alert_ok(title: "Error", message: "Access to library is restricted", target_view: self)
            })
        }else{
            print("not photo library")
            picker.allowsEditing = true
            picker.sourceType = source
            present(picker, animated: true, completion: nil)
        }
    }
    
    // Number of cols in Picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // Number  of rows in Picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return gender_values.count
    }
    
    // Title for row in Picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // row here is an index of row in picker
        return gender_values[row]
    }
    
    
    /* OTHER END */
    /***************** FUNCS END *****************/
    
}
