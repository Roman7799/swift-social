//
//  TblCell_Search_User.swift
//  social
//
//  Created by Denis Vesnin on 7/26/19.
//  Copyright © 2019 Geolance. All rights reserved.
//

import UIKit

class TblCell_Search_User: UITableViewCell {
    
    @IBOutlet weak var Avatar: UIImageView!
    @IBOutlet weak var Fullname: UILabel!
    @IBOutlet weak var Friend: UIButton!
    
    
    var id = String()
    
    let settings = Settings()
    let helper = Helper()

    override func awakeFromNib() {
        super.awakeFromNib()

        helper.configure_avatar_post(element: Avatar)
        
    }

}
