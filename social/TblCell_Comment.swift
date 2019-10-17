//
//  Tbl_Cell_Comment.swift
//  social
//
//  Created by Geolance on 7/12/19.
//  Copyright © 2019 Geolance. All rights reserved.
//

import UIKit

class TblCell_Comment: UITableViewCell {
    
    var helper = Helper()
    
    var id = String()
    var user_id = String()
    @IBOutlet weak var Comment_Avatar: UIImageView!
    @IBOutlet weak var Comment_Text: UILabel!
    @IBOutlet weak var Comment_Fullname: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        helper.configure_avatar_post(element: Comment_Avatar)
    }


}
