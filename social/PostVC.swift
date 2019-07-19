//
//  PostVC.swift
//  social
//
//  Created by Ancient on 7/8/19.
//  Copyright © 2019 Ancient. All rights reserved.
//

import UIKit



class PostVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    
    @IBOutlet weak var Avatar: UIImageView!
    @IBOutlet weak var Fullname: UILabel!
    @IBOutlet weak var Textfield: UITextView!
    @IBOutlet weak var Textfield_Placeholder: UILabel!
    @IBOutlet weak var Post_Image: UIImageView!
    
    
    
    let helper = Helper()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.Hide_Keyboard_on_Tap()
        
        reload_user_data()
        configure_avatar()

    }
    


    
    /****************** EVENTS *******************/
    /* INTERACTIONS */
    
    // On text input
     func textViewDidChange(_ textView: UITextView) {
        if(textView.text.isEmpty == true){
            Textfield_Placeholder.isHidden = false
        }else{
            Textfield_Placeholder.isHidden = true
        }
    }
    
    // On add image button clicked
    @IBAction func add_image_button_clicked(_ sender: Any) {
        show_image_action_sheet()
    }
    
    @IBAction func Image_tapped(_ sender: Any) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Library button
        let action_delete = UIAlertAction(title: "Delete Image", style: .destructive, handler: {(action) in
            print("ACTION DELETE")
            self.Post_Image.image = UIImage()
        })
        
        // Cancel button
        let action_cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        sheet.addAction(action_delete)
        sheet.addAction(action_cancel)
        self.present(sheet, animated: true, completion: nil)
    }
    
    
    // On cancel click
    @IBAction func Cancel_clicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // On share click
    @IBAction func Share_clicked(_ sender: Any) {
        print("SHARE CLICKED")
        let user_id = current_user["user_id"] as! String
        let text = Textfield.text ?? ""
        let image = Post_Image.image
        
        
        helper.api_create_post(user_id: user_id, text: text, image: image, target_view: self, on_complete: {result in
            print("SHARE RESULT:", result)

            // Send event to other controllers
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "post_created"), object: nil)
            
            self.dismiss(animated: true, completion: nil)
            
        })
    }

    
    /* INTERACTIONS END */
    /* HOOKS */
    
    // Triggers after image was picked from library
    // 10.1
    //func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    // 9.2
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //let user_id = current_user["user_id"] as! String
        
        // 10.1
        //let image = info[.editedImage] as? UIImage
        // 9.2
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        if(image == nil){
            print("image IS nil")
            return
        }
        
        Post_Image.image = image
        
        dismiss(animated: true, completion: {
            print("IMAGE PICKER DISMISSED")
        })
    }
    
    /* HOOKS END */
    /**************** EVENTS END *****************/
    /****************** VISUALS ******************/
    func configure_avatar(){
        Avatar.layer.cornerRadius = Avatar.frame.width / 2
        Avatar.clipsToBounds = true
    }
    /**************** VISUALS END ****************/
    /******************* FUNCS *******************/
    /* OTHER */
    
    // Repopulate all fields in current view from global user
    func reload_user_data(){
        
        // Full name
        if let first_name = current_user["first_name"] as? String{
            if let last_name = current_user["last_name"] as? String{
                Fullname.text = "\(first_name.capitalized) \(last_name.capitalized)"
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
        
    }
    
    // Show image action sheet
    func show_image_action_sheet(){
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

        
        sheet.addAction(action_camera)
        sheet.addAction(action_library)
        sheet.addAction(action_cancel)
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
    
    /* OTHER END */
    /***************** FUNCS END *****************/

}
