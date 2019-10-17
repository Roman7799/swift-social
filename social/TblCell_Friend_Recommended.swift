//
//  TblCell_Friend_Recommended.swift
//  social
//
//  Created by Denis Vesnin on 9/26/19.
//  Copyright © 2019 Geolance. All rights reserved.
//

import UIKit

protocol Friend_Recommended_Delegate: class {
    func Exec_Friend_Request(with action: String, status: Int, from cell: UITableViewCell)
}

class TblCell_Friend_Recommended: UITableViewCell {
    
    @IBOutlet weak var Avatar: UIImageView!
    @IBOutlet weak var Fullname: UILabel!
    @IBOutlet weak var Confirm_Request: UIButton!
    @IBOutlet weak var Delete_Request: UIButton!
    @IBOutlet weak var Action_Message: UILabel!
    
    var delegate: Friend_Recommended_Delegate?
    
    
    var id = String()
    
    let settings = Settings()
    let helper = Helper()
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Styles
        helper.add_border(target_view: Delete_Request, width: 1.5, color: UIColor.lightGray.cgColor)
        helper.style_border_radius(element: Confirm_Request, value: 3, clip_to_bounds: true, mask_to_bounds: true)
        //
    }
    
    // Confirm button clicked
    @IBAction func confirmButton_clicked(_ sender: Any) {
        
        Confirm_Request.isHidden = true
        Delete_Request.isHidden = true
        Action_Message.isHidden = false
        
        Action_Message.text = "Request Sent"
        
        delegate?.Exec_Friend_Request(with: "confirm", status: 3, from: self)
    }
    
    
    // Delete button clicked
    @IBAction func deleteButton_clicked(_ sender: Any) {
        
        Confirm_Request.isHidden = true
        Delete_Request.isHidden = true
        Action_Message.isHidden = false
        
        Action_Message.text = "Request removed"
        
        delegate?.Exec_Friend_Request(with: "decline", status: 0, from: self)
    }

}
