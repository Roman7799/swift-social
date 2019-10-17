//
//  User_Data.swift
//  social
//
//  Created by Denis Vesnin on 7/26/19.
//  Copyright © 2019 Geolance. All rights reserved.
//

import UIKit

class Notification_Data{
    
    var id = String()
    var type = String()
    var message = String()
    var viewed = String()
    
    var action_by_user_id = String()
    var avatar_url = String()
    var avatar = UIImage()
    var avatar_is_cached = false
    var first_name = String()
    var last_name = String()
    var fullname = String()
    
    /*
     types
     //"friend":
     "friend_request"
     "friend_accept"
     "follow":
     "like":
     "comment":
     //"ava":
     //"cover":
     //"bio":
     */
    
    
    /*
    var biography = String()
    var allow_friends = String()
    var allow_follow = String()
    var is_followed = false
    var is_friend_requested = false
    var frindship_status = 0    // 0 - default, not interacted
    // 1 - request SENT BY this user
    // 2 - request RECIEVED by this user
    // 3 - this user is a friend
 */
}

