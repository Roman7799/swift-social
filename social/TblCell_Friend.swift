//
//  TblCell_Friend.swift
//  social
//
//  Created by Denis Vesnin on 10/1/19.
//  Copyright © 2019 Geolance. All rights reserved.
//

import UIKit

class TblCell_Friend: UITableViewCell {
    
    let helper = Helper()
    let settings = Settings()
    
    @IBOutlet weak var Avatar: UIImageView!
    @IBOutlet weak var Fullname: UILabel!
    @IBOutlet weak var Remove_Button: UIButton!
    @IBOutlet weak var Message: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        helper.add_border(target_view: Remove_Button, width: 1.5, color: UIColor.lightGray.cgColor)
        helper.style_border_radius(element: Remove_Button, value: 3, clip_to_bounds: true)
    }

    /*
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
     */

}
