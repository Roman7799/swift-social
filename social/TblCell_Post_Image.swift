//
//  TblCell_Post_Image.swift
//  social
//
//  Created by Ancient on 7/10/19.
//  Copyright © 2019 Ancient. All rights reserved.
//

import UIKit

class TblCell_Post_Image: UITableViewCell {

    @IBOutlet weak var Avatar: UIImageView!
    @IBOutlet weak var Fullname: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var Post_Text: UILabel!
    @IBOutlet weak var Post_Image: UIImageView!
    @IBOutlet weak var Like: UIButton!
    @IBOutlet weak var Comments: UIButton!
    
    let helper = Helper()
    let settings = Settings()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
