//
//  TblCell_Post_Plain.swift
//  social
//
//  Created by Geolance on 7/10/19.
//  Copyright © 2019 Geolance. All rights reserved.
//

import UIKit

class TblCell_Post_Plain: UITableViewCell {

    @IBOutlet weak var Avatar: UIImageView!
    @IBOutlet weak var Fullname: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var Post_Text: UILabel!
    @IBOutlet weak var Like: UIButton!
    @IBOutlet weak var Comments: UIButton!
    @IBOutlet weak var Post_Options: UIButton!
    
    let helper = Helper()
    let settings = Settings()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        helper.configure_avatar_post(element: Avatar)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
