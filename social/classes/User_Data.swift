//
//  User_Data.swift
//  social
//
//  Created by Denis Vesnin on 7/26/19.
//  Copyright © 2019 Geolance. All rights reserved.
//

import UIKit

class User_Data{
    
    var id = String()
    var avatar_url = String()
    var avatar = UIImage()
    var avatar_is_cached = false
    var cover_url = String()
    var cover = UIImage()
    var cover_is_cached = false
    var first_name = String()
    var last_name = String()
    var fullname = String()
    var biography = String()
    var allow_friends = String()
    var allow_follow = String()
    var is_followed = false
    var is_friend_requested = false
    var frindship_status = 0    // 0 - default, not interacted
                                // 1 - request SENT BY this user
                                // 2 - request RECIEVED by this user
                                // 3 - this user is a friend
}
