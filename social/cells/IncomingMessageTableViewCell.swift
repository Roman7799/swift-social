//
//  IncomingMessageTableViewCell.swift
//  CometChat
//
//  Created by Marin Benčević on 08/08/2019.
//  Copyright © 2019 marinbenc. All rights reserved.
//

import UIKit
//import Kingfisher

class IncomingMessageTableViewCell: UITableViewCell, MessageCell {
  
  @IBOutlet weak var userImage: UIImageView!
  @IBOutlet weak var textBubble: UIView!
  @IBOutlet weak var contentLabel: UILabel!
  //@IBOutlet weak var textBubblePointer: UIImageView!
  @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    
    var settings = Settings()
    var helper = Helper()
  
  private enum Constants {
    static let shadowColor = UIColor(red: 189 / 255, green: 204 / 255, blue: 215 / 255, alpha: 0.54)
    static let shadowRadius: CGFloat = 2
    static let shadowOffset = CGSize(width: 0, height: 1)
    static let chainedMessagesBottomMargin: CGFloat = 20
    static let lastMessageBottomMargin: CGFloat = 32
  }
  
  var message: Message? {
    didSet {
      guard var message = message else {
        return
      }
      
      contentLabel.text = message.content
      //userImage.kf.setImage(with: message.user.image)
        // TODO: DL avatar
        
        // Avatar
        if(message.user.avatar_is_cached == true){
            userImage.image = message.user.avatar
        }else{
            let avatar_url = message.user.avatar_url
            if(avatar_url.isEmpty == false){
                let url = URL(string: avatar_url)!
                
                helper.download_image(url: url, on_complete: {(image) in
                    message.user.avatar = image // Cache
                    message.user.avatar_is_cached = true
                    DispatchQueue.main.async {
                        self.userImage.image = image
                    }
                    
                })
            }else{
                let image = UIImage(named: self.settings.default_avatar)
                message.user.avatar = image! // Cache
                message.user.avatar_is_cached = true
                self.userImage.image = image
            }
        }
        // Avatar END
    }
  }
  
  var showsAvatar = true {
    didSet {
      userImage.isHidden = !showsAvatar
      //textBubblePointer.isHidden = !showsAvatar
      bottomMargin.constant = showsAvatar ? Constants.lastMessageBottomMargin : Constants.chainedMessagesBottomMargin
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    helper.configure_avatar_post(element: userImage)
    
    textBubble.layer.cornerRadius = 6
    textBubble.layer.addShadow(
      color: Constants.shadowColor,
      offset: Constants.shadowOffset,
      radius: Constants.shadowRadius)
  }
  
}
