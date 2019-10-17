//
//  User.swift
//  CometChat
//
//  Created by Marin Benčević on 08/08/2019.
//  Copyright © 2019 marinbenc. All rights reserved.
//

import UIKit

struct Chat_Contact {
    var chat_id: String = String()
    var user_id: String = String()
    var first_name: String = String()
    var last_name: String = String()
    var full_name: String = String()
    var avatar_url: String = String()
    var avatar: UIImage = UIImage()
    var avatar_is_cached = false
    var new_messages = 0
    //let is_online: Bool
}


