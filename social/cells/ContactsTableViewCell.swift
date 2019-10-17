//
//  ContactsTableViewCell.swift
//  CometChat
//
//  Created by Marin Benčević on 08/09/2019.
//  Copyright © 2019 marinbenc. All rights reserved.
//

import UIKit
//import Kingfisher

class ContactsTableViewCell: UITableViewCell {
    
    let helper = Helper()
    let settings = Settings()

  @IBOutlet weak var Avatar: UIImageView!
  @IBOutlet weak var Fullname: UILabel!
    @IBOutlet weak var New_Messages: UILabel!
    
  override func awakeFromNib() {
    super.awakeFromNib()
    //statusIndicatorView.layer.cornerRadius = statusIndicatorView.bounds.width / 2
    
    helper.style_border_radius(element: New_Messages, value: 10, clip_to_bounds: true, mask_to_bounds: true)
    
    helper.configure_avatar_post(element: Avatar)
  }
  
  var contact: Chat_Contact = Chat_Contact() {
    didSet {
        print("contact set", contact)
        // Fullname
        
        DispatchQueue.main.async {
            self.Fullname.text = self.contact.full_name
        }
        
        
        // New messages count
        DispatchQueue.main.async {
            self.New_Messages.text = "\(self.contact.new_messages)"
        }
        
        
        
      //avatarImageView.kf.setImage(with: contact.image)
        // dl avatar here
        
        // AVATAR
        if(contact.avatar_is_cached == true){
            DispatchQueue.main.async {
                self.Avatar.image = self.contact.avatar
            }
        }else{
            let avatar_url = contact.avatar_url
            if(avatar_url.isEmpty == false){
                let url = URL(string: avatar_url)!
                
                helper.download_image(url: url, on_complete: {(image) in
                    self.contact.avatar = image // Cache
                    self.contact.avatar_is_cached = true
                    DispatchQueue.main.async {
                        self.Avatar.image = image
                    }
                })
            }else{
                let image = UIImage(named: self.settings.default_avatar)
                contact.avatar = image! // Cache
                contact.avatar_is_cached = true
                Avatar.image = image
            }
        }
        // AVATAR END
        
      //statusIndicatorView.backgroundColor = contact.isOnline ? .online : .placeholderBody
    }
  }
  
}
