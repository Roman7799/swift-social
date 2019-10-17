//
//  TblCell_Notification.swift
//  social
//
//  Created by Denis Vesnin on 9/30/19.
//  Copyright © 2019 Geolance. All rights reserved.
//

import UIKit

class TblCell_Notification: UITableViewCell {
    
    let settings = Settings()
    let helper = Helper()
    
    var id = String()
    
    @IBOutlet weak var Avatar: UIImageView!
    @IBOutlet weak var Message: UILabel!
    @IBOutlet weak var Icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        helper.style_image_round(element: Avatar)
        helper.style_image_round(element: Icon)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
