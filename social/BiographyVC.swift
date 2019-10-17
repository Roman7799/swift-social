//
//  BiographyVC.swift
//  social
//
//  Created by Geolance on 7/5/19.
//  Copyright © 2019 Geolance. All rights reserved.
//

import UIKit

class BiographyVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var Avatar_Image: UIImageView!
    @IBOutlet weak var Fullname_Label: UILabel!
    @IBOutlet weak var Placeholder_Label: UILabel!
    @IBOutlet weak var Text_Input: UITextView!
    @IBOutlet weak var CharCount_Label: UILabel!
    
    let helper = Helper()
    let settings = Settings()
    let allowed = 100
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        configure_avatar()
        
        // Apply user data from current_user
        // Full name
        if let first_name = current_user["first_name"] as? String{
            if let last_name = current_user["last_name"] as? String{
                Fullname_Label.text = "\(first_name.capitalized) \(last_name.capitalized)"
            }
        }
        // Bio
        if let biography = current_user["biography"] as? String{
            Text_Input.text = biography
            if biography.isEmpty == false{
                Placeholder_Label.isHidden = true
            }
            
            CharCount_Label.text = "\(biography.count)/\(allowed)"
        }
        // Avatar
        if let avatar_url = current_user["avatar"] as? String{
            if(avatar_url.isEmpty == false){
                print("AVATAR URL NOT EMPTY", avatar_url)
                let url = URL(string: avatar_url)!
                
                if(current_user_avatar == nil){
                    // No stored Avatar
                    print("NO STORED AVATAR")
                    helper.download_image(url: url, on_complete: {(image) in
                        self.Avatar_Image.image = image
                        current_user_avatar = image
                        print("AVATAR RETRIEVED")
                    })
                    
                }else{
                    // Stored Avatar exists
                    self.Avatar_Image.image = current_user_avatar!
                    print("STORED AVATAR:", current_user_avatar!)
                }
                
                
            }else{
                self.Avatar_Image.image = UIImage(named: settings.default_avatar)
            }
        }else{
            self.Avatar_Image.image = UIImage(named: settings.default_avatar)
        }
        // current_user END
        
    }
    
    
    /****************** EVENTS *******************/
    /* INTERACTIONS */
    
    // Cancel button returns to previous VC
    @IBAction func Cancel_clicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // Save button clicked
    @IBAction func Save_clicked(_ sender: Any) {
        
        let user_id = current_user["user_id"] as! String
        var text = Text_Input.text ?? ""
        text = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        helper.api_update_biography(user_id: user_id, text: text, target_view: self, on_complete: {result in
            
            print("Biography updated. Result:", result)
            current_user["biography"] = text
            UserDefaults.standard.set(current_user, forKey: "current_user")
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update_biography"), object: nil)
            self.dismiss(animated: true, completion: nil)
            
        })
        
    }
    
    
    // On after typing
    func textViewDidChange(_ textView: UITextView) {
        if(textView.text.isEmpty == true){
            Placeholder_Label.isHidden = false
        }else{
            Placeholder_Label.isHidden = true
        }
    }
    
    // On before typing
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("BEFORE TYPING")
        
        //let typed = textView.text.count
        //let remain = allowed - typed
        
        //let new_text = (textView.text as NSString).replacingCharacters(in: range, with: text)
        //let typed = new_text.count
        //return typed <= allowed
        
        /* if(remain < 1){
            return false
        }else{
            Placeholder_Label.text = "\(remain)/\(allowed)"
            return true
        } */
        
        guard text.rangeOfCharacter(from: CharacterSet.newlines) == nil else{
            return false
        }
        
        if(textView.text.count + (text.count - range.length) <= allowed){
            CharCount_Label.text = "\(textView.text.count + (text.count - range.length))/\(allowed)"
            return true
        }else{
            return false
        }
    }
    
    /* INTERACTIONS END */
    /* HOOKS */
    
    /* HOOKS END */
    /**************** EVENTS END *****************/
    /****************** VISUALS ******************/
    func configure_avatar(){
        Avatar_Image.layer.cornerRadius = Avatar_Image.frame.width / 2
        Avatar_Image.clipsToBounds = true
    }
    /**************** VISUALS END ****************/
    /******************* FUNCS *******************/
    /* OTHER */
    
    /* OTHER END */
    /***************** FUNCS END *****************/
    
    
    
    

}
