//
//  Post.swift
//  social
//
//  Created by Denis Vesnin on 7/26/19.
//  Copyright © 2019 Geolance. All rights reserved.
//

import UIKit

class Post{
    
    var id = String()
    var post_type = String()
    var user_id = String()
    var is_liked_by_current_user = false
    
    var avatar_url = String()
    var cached_avatar = UIImage()
    var is_avatar_cached = false
    
    var post_image_url = String()
    var cached_post_image = UIImage()
    var cached_post_image_size = [String:Any]()
    var is_post_image_cached = false
    
    var first_name = String()
    var last_name = String()
    var full_name = String()
    var text = String()
    var date = String()
    
    
}
