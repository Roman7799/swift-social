//
//  FriendsVC.swift
//  social
//
//  Created by Denis Vesnin on 10/2/19.
//  Copyright © 2019 Geolance. All rights reserved.
//

import UIKit

class FriendsVC: UITableViewController {
    
    let helper = Helper()
    let settings = Settings()
    
    var friends = [User_Data]()
    var friends_offset = 0
    var friends_limit = 10
    var friends_loading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        load_friends()
        
        NotificationCenter.default.addObserver(self, selector: #selector(event_friend), name: Notification.Name(rawValue: "friend"), object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friends.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TblCell_Friend", for: indexPath) as! TblCell_Friend

        // Fullname
        cell.Fullname.text = friends[indexPath.row].fullname
        
        // Remove index
        cell.Remove_Button.tag = indexPath.row
        
        // Avatar
        if(friends[indexPath.row].avatar_url.isEmpty == false){
            
            if(friends[indexPath.row].avatar_is_cached == true){
                // Use cached
                cell.Avatar.image = friends[indexPath.row].avatar
                
            }else{
                // DL
                let url = URL(string: friends[indexPath.row].avatar_url)!
                
                helper.download_image(url: url, on_complete: {image in
                    self.friends[indexPath.row].avatar = image // Cache
                    self.friends[indexPath.row].avatar_is_cached = true
                    cell.Avatar.image = image
                    
                }, on_fail: {
                    // Use default
                    let image = UIImage(named: self.settings.default_avatar) ?? UIImage()
                    self.friends[indexPath.row].avatar = image // Cache
                    self.friends[indexPath.row].avatar_is_cached = true
                    cell.Avatar.image = image
                })
            }
            
        }else{
            let image = UIImage(named: self.settings.default_avatar) ?? UIImage()
            self.friends[indexPath.row].avatar = image // Cache
            self.friends[indexPath.row].avatar_is_cached = true
            cell.Avatar.image = image
        }
        // Avatar END

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
    
    
    
    // Load friends
    func load_friends(){
        if(friends_loading){
            return
        }
        friends_loading = true
        
        guard let current_user_id = current_user["user_id"] as? String else{
            friends_loading = false
            return
        }
        
        var is_more = true
        if(friends_offset == 0){
            is_more = false
            friends.removeAll(keepingCapacity: false)
        }
        
        helper.api_get_friends(user_id: current_user_id, offset: friends_offset, limit: friends_limit, target_view: self, on_complete: {result in
            if(result["status"] as! Int == 1){
                
                let content = result["content"] as! NSDictionary
                guard let res_friends = content["friends"] as? [NSDictionary] else{
                    print("[friends] index not exists")
                    self.friends_loading = false
                    return
                }
                
                print("FRIENDS ARRAY", res_friends)
                
                if(res_friends.count > 0){
                    
                    if(is_more){
                        self.tableView.beginUpdates()
                    }
                    
                    var i = 0
                    for friend in res_friends {
                        
                        let user_id = self.helper.cast(value: friend["real_user_id"])
                        let first_name = self.helper.cast(value: friend["first_name"])
                        let last_name = self.helper.cast(value: friend["last_name"])
                        let avatar_url = self.helper.cast(value: friend["avatar"])
                        let cover_url = self.helper.cast(value: friend["cover"])
                        let biography = self.helper.cast(value: friend["biography"])
                        let allow_friends = self.helper.cast(value: friend["allow_friends"])
                        let allow_follow = self.helper.cast(value: friend["allow_follow"])
                        let is_followed = self.helper.cast(value: friend["is_followed"])
                        
                        let data_obj = User_Data()
                        data_obj.id = user_id
                        data_obj.avatar_url = avatar_url
                        data_obj.cover_url = cover_url
                        data_obj.biography = biography
                        data_obj.first_name = first_name
                        data_obj.last_name = last_name
                        data_obj.fullname = "\(first_name.capitalized) \(last_name.capitalized)"
                        data_obj.allow_friends = allow_friends
                        data_obj.allow_follow = allow_follow
                        data_obj.frindship_status = 3
                        
                        if(is_followed != ""){
                            data_obj.is_followed = true
                        }else{
                            data_obj.is_followed = false
                        }
                        
                        self.friends.append(data_obj)
                        if(is_more){
                            let section_index = self.tableView.numberOfSections - 1 // Column index?
                            let row_index = self.tableView.numberOfRows(inSection: section_index)
                            let path_to_last_row = IndexPath(row: row_index + i, section: section_index)
                            self.tableView.insertRows(at: [path_to_last_row], with: .fade)
                        }

                        i += 1
                    }
                    
                    
                    self.friends_offset = self.friends.count
                    if(is_more){
                        self.tableView.endUpdates()
                    }else{
                        self.tableView.reloadData()
                    }
                    self.friends_loading = false
                }
            }else{
                self.friends_loading = false
                print("STATUS ERROR")
            }
            
        })
    }
    
    
    // on Remove friend clicked
    @IBAction func Remove_clicked(_ sender: UIButton) {
        guard let current_user_id = current_user["user_id"] as? String else{
            return
        }
        
        // accessing tag of the button. Earlier indexPath was declared as the tag of the button
        let index = sender.tag
        let indexPath = IndexPath(row: index, section: 0)
        let cell = self.tableView.cellForRow(at: indexPath) as! TblCell_Friend
        
        helper.api_delete_friend(current_user_id: current_user_id, friend_id: friends[index].id, target_view: self, on_complete: {result in
            
            print(result)
            
            if(result["status"] as! Int == 1){
                
                print("INDEX PATH", indexPath)
                
                self.friends[index].frindship_status = 0
                cell.Message.isHidden = false
                cell.Remove_Button.isHidden = true
                cell.Message.text = "User removed from friendlist"
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "friend"), object: nil)
                
            }else{
                print("ERROR", result["message"])
            }
        })
        
        
    }
    
    @objc func event_friend(_ notification: Notification){
        
        // change friendship status and button appearence
        guard let event_data = notification.userInfo,
            let row = event_data["row"] as? Int,
            let new_status = event_data["new_friendship_status"] as? Int
        else{
                return
        }
        
        
        friends[row].frindship_status = new_status
        let indexPath = IndexPath(row: row, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! TblCell_Friend
        
        switch new_status {
        case 0:
            cell.Remove_Button.isHidden = true
            cell.Message.isHidden = false
            cell.Message.text = "User removed from friendlist"
        case 1:
            cell.Remove_Button.isHidden = true
            cell.Message.isHidden = false
            cell.Message.text = "User sent you a friendship request"
        case 2:
            cell.Remove_Button.isHidden = true
            cell.Message.isHidden = false
            cell.Message.text = "You sent a friendship request"
        case 3:
            cell.Remove_Button.isHidden = false
            cell.Message.isHidden = true
        default:
            print("new status error")
            return
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "FriendsVC_Guest"){
            
            guard let indexPath = tableView.indexPathForSelectedRow else{
                return
            }
            let selected_user_obj = friends[indexPath.row]
            let guest_vc = segue.destination as! GuestVC
            guest_vc.guest_data_obj = selected_user_obj
            guest_vc.index_row = indexPath.row
            
        }
    }

}









