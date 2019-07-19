//
//  EditProfileVC.swift
//  social
//
//  Created by Ancient on 7/9/19.
//  Copyright © 2019 Ancient. All rights reserved.
//

import UIKit

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
    
    
    
    let helper = Helper()
    var is_cover = false
    var is_avatar = false
    var image_view_tapped = ""
    var default_cover = "image_placeholder.png"
    var default_avatar = "image_placeholder.png"
    var is_password_changed = false
    var is_cover_changed = false
    var is_avatar_changed = false
    var datePicker: UIDatePicker!
    var gender_picker: UIPickerView!
    var gender_values = ["Male", "Female"]
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -5, to: Date())
        datePicker.addTarget(self, action: #selector(self.on_datePicker_change(_:)), for: .valueChanged)
        Birthday.inputView = datePicker
        
        gender_picker = UIPickerView()
        
        
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
        if(is_password_changed){
            let password = Password.text ?? ""
        }else{
            let password = ""
        }
        let first_name = Firstname.text ?? ""
        let last_name = Lastname.text ?? ""
        
        let date_formatter = DateFormatter()
        date_formatter.dateFormat = "Y-m-d"
        let birthday = date_formatter.string(from: datePicker.date)
        
        var gender = String()
        if(Gender.text == "Male"){
            gender = "1"
        }else if(Gender.text == "Female"){
            gender = "2"
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
        }
        // Validation OK, Continue
        
        var is_cover_deleted = false
        var is_avatar_deleted = false
        var cover: UIImage?
        var avatar: UIImage?
        if(is_cover_changed == true){
            if(cover !== UIImage(named: default_cover)){
                cover = Cover.image
            }else{
                //current_user["cover"] = "";
                is_cover_deleted = true
                cover = nil
            }
        }else{
            cover = nil
        }
        if(is_avatar_changed == true){
            if(cover !== UIImage(named: default_avatar)){
                avatar = Avatar.image
            }else{
                //current_user["avatar"] = "";
                is_avatar_deleted = true
                avatar = nil
            }
        }else{
            avatar = nil
        }
        
        helper.api_update_user_info(user_id: user_id, first_name: first_name, last_name: last_name, birthday: birthday, gender: gender, cover: cover, is_cover_deleted: is_cover_deleted, avatar: avatar, is_avatar_deleted: is_avatar_deleted, target_view: self, on_complete: {result in
            print("USER INFO UPDATED:", result)
            
            current_user["email"] = result.value(forKey: "content.email")
            current_user["first_name"] = result.value(forKey: "content.first_name")
            current_user["last_name"] = result.value(forKey: "content.last_name")
            current_user["birthday"] = result.value(forKey: "content.birthday")
            current_user["gender"] = result.value(forKey: "content.gender")
            current_user["cover"] = result.value(forKey: "content.cover")
            current_user["avatar"] = result.value(forKey: "content.avatar")
            UserDefaults.standard.set(current_user, forKey: "current_user")
            
            self.helper.show_alert_ok(title: "Success", message: "Info updated", target_view: self)
            //self.dismiss(animated: true, completion: nil)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update_user_info"), object: nil)
            
            
            
            
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //let user_id = Int(current_user["user_id"] as! String)!
        
        //let image = info[.editedImage] as? UIImage
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        if(image == nil){
            print("image IS nil")
            return
        }
        
        if(self.image_view_tapped == "cover"){
            Cover.image = image
             is_cover_changed = true
            // Image will upload only after Save clicked
    
        }else if(self.image_view_tapped == "avatar"){
            Avatar.image = image
            is_avatar_changed = true
            // Image will upload only after Save clicked
        }
        
        dismiss(animated: true, completion: {
            print("IMAGE PICKER DISMISSED")
            if(self.image_view_tapped == "cover"){
                self.is_cover = true
            }else if(self.image_view_tapped == "avatar"){
                self.is_avatar = true
            }
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
            let date_formatter_get = DateFormatter()
            date_formatter_get.dateFormat = "Y-m-d"
            let date_get = date_formatter_get.date(from: birthday)!
            
            let date_formatter_set = DateFormatter()
            date_formatter_set.dateFormat = "MMM dd, yyyy"
            let date_set = date_formatter_set.string(from: date_get)
            
            Birthday.text = date_set
        }
        
        if let gender = current_user["gender"] as? String{
            if(gender == "1"){
                Gender.text = "Male"
            }else if(gender == "2"){
                Gender.text = "Female"
            }
            
        }
        
        // Avatar
        if let avatar_url = current_user["avatar"] as? String{
            if(avatar_url.isEmpty == false){
                let url = URL(fileURLWithPath: avatar_url)
                
                DispatchQueue.main.async {
                    do{
                        let data = try Data(contentsOf: url)
                        if let image = UIImage(data: data){
                            self.Avatar.image = image
                        }
                    }catch{
                        print("CANT GET AVATAR IMAGE. URL:", url)
                    }
                }
            }
        }
        
        // Cover
        if let cover_url = current_user["cover"] as? String{
            if(cover_url.isEmpty == false){
                let url = URL(fileURLWithPath: cover_url)
                
                DispatchQueue.main.async {
                    do{
                        let data = try Data(contentsOf: url)
                        if let image = UIImage(data: data){
                            self.Cover.image = image
                        }
                    }catch{
                        print("CANT GET COVER IMAGE. URL:", url)
                    }
                }
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
                self.Cover.image = UIImage(named: self.default_cover)
                self.is_cover = false

            }else if(self.image_view_tapped == "avatar"){
                self.Avatar.image = UIImage(named: self.default_avatar)
                self.is_avatar = false
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
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = source
        present(picker, animated: true, completion: nil)
    }
    
    // Number of cols in Picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // Number  of rows in Picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1
    }
    
    // Title for row in Picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // row here is an index of row in picker
        return gender_values[row]
    }
    
    
    /* OTHER END */
    /***************** FUNCS END *****************/
    
}
