//
//  NotificationsVC.swift
//  social
//
//  Created by Denis Vesnin on 9/30/19.
//  Copyright © 2019 Geolance. All rights reserved.
//

import UIKit

class NotificationsVC: UITableViewController {
    
    let settings = Settings()
    let helper = Helper()
    
    var notifications = [Notification_Data]()
    var notifications_offset = 0
    var notifications_limit = 10
    var is_loading = false

    @IBOutlet var Notifications_Table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        load_notifications()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notifications.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = Notifications_Table.dequeueReusableCell(withIdentifier: "TblCell_Notification", for: indexPath) as! TblCell_Notification
        
        // Message + Icon
        var message = ""
        switch notifications[indexPath.row].type {
        case "friend_accept":
            message = " now is your friend."
            cell.Icon.image = UIImage(named: "notifications_friend")
        case "friend_request":
            message = " sent you friendship request."
            cell.Icon.image = UIImage(named: "notifications_friend")
        case "follow":
            message = " has started following you."
            cell.Icon.image = UIImage(named: "notifications_follow")
        case "like":
            cell.Icon.image = UIImage(named: "notifications_like")
            message = " liked your post."
        case "comment":
            cell.Icon.image = UIImage(named: "notifications_comment")
            message = " has commented your post."
        case "ava":
            cell.Icon.image = UIImage(named: "notifications_update")
            message = " has changed his (her) profile picture."
        case "cover":
            cell.Icon.image = UIImage(named: "notifications_update")
            message = " has changed his (her) cover."
        case "bio":
            cell.Icon.image = UIImage(named: "notifications_update")
            message = " has updated his (her bio)"
        default:
            message = ""
        }
        
        // Format Message string
        let bold_string = NSMutableAttributedString(string: notifications[indexPath.row].fullname, attributes: [kCTFontAttributeName as NSAttributedStringKey: UIFont.boldSystemFont(ofSize: 17)])
        let regular_string = NSMutableAttributedString(string: message)
        bold_string.append(regular_string)
        cell.Message.attributedText = bold_string
        
        // Cell appearence
        if (notifications[indexPath.row].viewed == "yes") {
            cell.backgroundColor = .white
        } else {
            cell.backgroundColor = settings.color_1.withAlphaComponent(0.15)
        }
        
        
        // Avatar
        if(notifications[indexPath.row].avatar_url.isEmpty == false){
            
            if(notifications[indexPath.row].avatar_is_cached == true){
                // Use cached
                cell.Avatar.image = notifications[indexPath.row].avatar
                
            }else{
                // DL
                let url = URL(string: notifications[indexPath.row].avatar_url)!
                
                helper.download_image(url: url, on_complete: {image in
                    self.notifications[indexPath.row].avatar = image // Cache
                    self.notifications[indexPath.row].avatar_is_cached = true
                    cell.Avatar.image = image
                    
                }, on_fail: {
                    // Use default
                    let image = UIImage(named: self.settings.default_avatar) ?? UIImage()
                    self.notifications[indexPath.row].avatar = image // Cache
                    self.notifications[indexPath.row].avatar_is_cached = true
                    cell.Avatar.image = image
                })
            }
            
        }else{
            let image = UIImage(named: self.settings.default_avatar) ?? UIImage()
            self.notifications[indexPath.row].avatar = image // Cache
            self.notifications[indexPath.row].avatar_is_cached = true
            cell.Avatar.image = image
        }
        // Avatar END
        
        return cell

    }
    
    func load_notifications(){
        if(is_loading){
            return
        }
        is_loading = true
        
        guard let current_user_id = current_user["user_id"] as? String else{
                return
        }
        
        var is_more = true
        if(notifications_offset == 0){
            is_more = false
            notifications.removeAll(keepingCapacity: false)
        }
        
        helper.api_get_notifications(current_user_id: current_user_id, type: "", offset: notifications_offset, limit: notifications_limit, target_view: self, on_complete: {result in
            
            print(result)
            if(result["status"] as! Int == 1){
                
                //let content = result["content"] as! [String: Any]
                let res_notifications = result["content"] as! [NSDictionary]
                
                if(res_notifications.count == 0){
                    self.is_loading = false
                    return
                }
                
                if(is_more){
                    self.Notifications_Table.beginUpdates()
                }
                
                var i = 0
                for res_notification in res_notifications{
                    
                    if let id = res_notification["id"] as? String,
                        let first_name = res_notification["first_name"] as? String,
                        let last_name = res_notification["last_name"] as? String,
                        let action_by_user_id = res_notification["action_by_user_id"] as? String
                    {
                        let avatar_url = self.helper.cast(value: res_notification["avatar"])
                        let type = self.helper.cast(value: res_notification["type"])
                        let viewed = self.helper.cast(value: res_notification["viewed"])
                        //let cover_url = self.helper.cast(value: res_notification["cover"])
                        
                        let fullname = "\(first_name) \(last_name)"
                        //let biography = self.helper.cast(value: res_notification["biography"])
                        
                        let data_obj = Notification_Data()
                        data_obj.id = id
                        data_obj.action_by_user_id = action_by_user_id
                        data_obj.first_name = first_name
                        data_obj.last_name = last_name
                        data_obj.fullname = fullname
                        data_obj.avatar_url = avatar_url
                        data_obj.type = type
                        data_obj.viewed = viewed
                        //data_obj.cover_url = cover_url
                        //data_obj.biography = biography
                        //data_obj.allow_friends = allow_friends
                        //data_obj.allow_follow = allow_follow
                        
                        
                        self.notifications.append(data_obj)
                        
                        if(is_more){
                            let section_index = self.Notifications_Table.numberOfSections - 1 // Column index?
                            let row_index = self.Notifications_Table.numberOfRows(inSection: section_index)
                            let path_to_last_row = IndexPath(row: row_index + i, section: section_index)
                            self.Notifications_Table.insertRows(at: [path_to_last_row], with: .fade)
                        }
                        
                        i += 1

                    }else{
                        print("User from array failed to get all data")
                    }
                    
                }
                
            }else{
                self.helper.show_alert_ok(title: "Error", message: result["error"] as! String, target_view: self)
            }
            
            self.notifications_offset = self.notifications.count
            if(is_more){
                self.tableView.endUpdates()
            }else{
                self.Notifications_Table.reloadData()
            }
            
            // Update loaded notifications status
            let res_notifications = result["content"] as! [NSDictionary]
            for res_notification in res_notifications{
                self.helper.api_update_notification(current_user_id: current_user_id, notification_id: res_notification["id"] as! String, viewed: "yes", target_view: self, on_complete: {_ in })
            }
            
            self.is_loading = false
            
        })
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // if tableView is scrolled down by 1 page + 60pxls and currently it's not loading anything ... exec pagination
        print("offset y", Notifications_Table.contentOffset.y)
        print("table content height", Notifications_Table.contentSize.height)
        print("table frame height", Notifications_Table.frame.height)
        if Notifications_Table.contentOffset.y - Notifications_Table.contentSize.height + 120 > -Notifications_Table.frame.height && is_loading == false {
            load_notifications()
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        guard let current_user_id = current_user["user_id"] as? String else{
            return
        }
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let hide = UIAlertAction(title: "Hide", style: .default) { (action) in
            
            self.helper.api_update_notification(current_user_id: current_user_id, notification_id: self.notifications[indexPath.row].id, viewed: "ignore", target_view: self, on_complete: {result in
                
                if(result["status"] as! Int == 1){
                    self.notifications.remove(at: indexPath.row)
                    
                    self.Notifications_Table.beginUpdates()
                    self.Notifications_Table.deleteRows(at: [indexPath], with: .automatic)
                    self.Notifications_Table.endUpdates()
                    
                }else{
                    print("HIDE NOTIFICATION ERROR")
                }
            })
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
        sheet.addAction(hide)
        sheet.addAction(cancel)
        
        present(sheet, animated: true, completion: nil)
        
    }
 

    

}
