//
//  GuestVC.swift
//  social
//
//  Created by Denis Vesnin on 7/31/19.
//  Copyright © 2019 Geolance. All rights reserved.
//

import UIKit

class GuestVC: UITableViewController {

    @IBOutlet weak var Cover: UIImageView!
    @IBOutlet weak var Avatar: UIImageView!
    @IBOutlet weak var Fullname: UILabel!
    @IBOutlet weak var Biography: UILabel!
    
    @IBOutlet weak var Friend: UIButton!
    @IBOutlet weak var Follow: UIButton!
    @IBOutlet weak var Message: UIButton!
    @IBOutlet weak var More: UIButton!
    
    @IBOutlet var Guest_Posts_Table: UITableView!
    
    let helper = Helper()
    let settings = Settings()
    var guest_data_obj = User_Data()
    var index_row = -1
    
    var posts = [Post]()
    var offset = 0
    var limit = 5
    var is_posts_loading = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Friend.centerVertically(gap: 10)
        Follow.centerVertically(gap: 10)
        Message.centerVertically(gap: 10)
        More.centerVertically(gap: 10)
        
        // Avatar config
        helper.add_border(target_view: Avatar, width: 5, color: UIColor.white.cgColor)
        Avatar.layer.cornerRadius = 10
        Avatar.layer.masksToBounds = true
        Avatar.clipsToBounds = true
        
        // Auto height
        Guest_Posts_Table.rowHeight = UITableViewAutomaticDimension
        Guest_Posts_Table.estimatedRowHeight = 383
        
        // Reload User data
        reload_user_data()
        
        // Load initial posts
        load_posts(offset: offset, limit: limit)
    }

    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
 */

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        print("numberOfRowsInSection TRIGGERED")
        print("posts count", posts.count)
        return posts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        print("TV INITIAL TRIGGERED")
        
        let cell = Guest_Posts_Table.dequeueReusableCell(withIdentifier: "TblCell_Post_Image", for: indexPath) as! TblCell_Post_Image
        cell.Fullname.text = self.posts[indexPath.row].full_name
        
        // Cell Date
        let server_date_string = self.posts[indexPath.row].date
        let cell_date_string = helper.date_string_convert(date_string: server_date_string, from_format: settings.date_format_server, to_format: settings.date_format_post_front)
        cell.Date.text = cell_date_string
        
        // Cell Text
        let post_text = self.posts[indexPath.row].text
        cell.Post_Text.text = post_text
        
        // Avatar
        if(posts[indexPath.row].is_avatar_cached == true){
            cell.Avatar.image = posts[indexPath.row].cached_avatar
        }else{
            let avatar_url = self.posts[indexPath.row].avatar_url
            if(avatar_url.isEmpty == false){
                let url = URL(string: avatar_url)!
                
                helper.download_image(url: url, on_complete: {(image) in
                    self.posts[indexPath.row].cached_avatar = image // Cache
                    self.posts[indexPath.row].is_avatar_cached = true
                    cell.Avatar.image = image
                })
            }else{
                let image = UIImage(named: self.settings.default_avatar)
                self.posts[indexPath.row].cached_avatar = image! // Cache
                self.posts[indexPath.row].is_avatar_cached = true
                cell.Avatar.image = image
            }
        }
        
        // Post Image END
        if(self.posts[indexPath.row].post_type == "image"){
            let post_image_url = self.posts[indexPath.row].post_image_url
            let url = URL(string: post_image_url)!
            
            if(self.posts[indexPath.row].is_post_image_cached == true){
                // Use cached
                DispatchQueue.main.async {
                    cell.Post_Image.image = self.posts[indexPath.row].cached_post_image
                    
                    /* if uncommented need to rework a little
                     let ratio = self.cached_posts_image[indexPath.row].size.width / self.cached_posts_image[indexPath.row].size.height
                     let newHeight = cell.Post_Image.frame.width / ratio
                     cell.Post_Image_height.constant = newHeight
                     self.view.layoutIfNeeded()
                     */
                }
            }else{
                // Download and cache
                helper.download_image(url: url, on_complete: {(image) in
                    self.posts[indexPath.row].cached_post_image = image
                    self.posts[indexPath.row].is_post_image_cached = true
                    cell.Post_Image.image = image
                    /* if uncommented need to rework a little
                     let ratio = image.size.width / image.size.height
                     let newHeight = cell.Post_Image.frame.width / ratio
                     cell.Post_Image_height.constant = newHeight
                     self.view.layoutIfNeeded()
                     */
                })
            }
        }else{
            cell.Post_Image_height?.constant = 0
            cell.updateConstraints()
        }
        // Post Image END
        
        
        
        // Set row index to Like button tag
        cell.tag = indexPath.row
        cell.Like.tag = indexPath.row
        cell.Comments.tag = indexPath.row
        
        // Assign image for like button
        DispatchQueue.main.async {
            if(self.posts[indexPath.row].is_liked_by_current_user == true){
                cell.Like.setImage(UIImage(named: "like.png"), for: .normal)
            }else{
                cell.Like.setImage(UIImage(named: "unlike.png"), for: .normal)
            }
        }
        
        print("posts", posts.count)
        //print("cached_images", cached_posts_image.count)
        
        return cell
    }
    
    // on scroll Load more posts
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if(tableView.contentOffset.y - tableView.contentSize.height + 60 > -tableView.frame.height && is_posts_loading == false)
        {
            load_more_posts(offset: self.offset, limit: self.limit)
        }
        
    }
    
    // Override to support conditional editing of the table view.
    /*
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

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    /****************** EVENTS *******************/
    /* INTERACTIONS */
    
    
    @IBAction func Friend_clicked(_ sender: UIButton) {
        
        // getting ids of the user
        guard let user_id = current_user["user_id"] as? String else {
            return
        }
        let target_user_id = guest_data_obj.id
        
        switch guest_data_obj.frindship_status {
        case 3: // Users are friends, show action with unfriend or cancel
            let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                // send request to the server
                
                self.helper.api_delete_friend(current_user_id: user_id, friend_id: target_user_id, target_view: self, on_complete: {result in
                    
                    if(result["status"] as! Int == 1){
                        // Set status
                        self.guest_data_obj.frindship_status = 0
                        
                        // Friend button appearence
                        let image = UIImage(named: "unfriend.png")
                        self.Friend.setBackgroundImage(image, for: .normal)
                        self.Friend.tintColor = UIColor.darkGray
                        self.Friend.setTitle("Add", for: .normal)
                        self.Friend.titleLabel?.textColor = UIColor.darkGray
                        self.helper.ani_pop(element: self.Friend)
                        //
                        
                        // send event
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "friend"), object: nil, userInfo: ["row": self.index_row, "new_friendship_status": self.guest_data_obj.frindship_status])
                        
                    }else{
                        self.helper.show_alert_ok(title: "Error", message: result["error"] as! String, target_view: self)
                    }
                })
                
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            
            
            sheet.addAction(delete)
            sheet.addAction(cancel)
            
            present(sheet, animated: true, completion: nil)
            
            break
            
        case 2: // Current user recieved friend request, show action with accept or decline or cancel
            let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            // Befriend
            let confirm = UIAlertAction(title: "Accept", style: .default) { (action) in
                
                self.helper.api_confirm_friend_request(current_user_id: user_id, friend_id: target_user_id, target_view: self, on_complete: {result in
                    
                    if(result["status"] as! Int == 1){
                        // update status
                        self.guest_data_obj.frindship_status = 3
                        
                        // Friend button appearence
                        let image = UIImage(named: "friends")
                        self.Friend.setBackgroundImage(image, for: .normal)
                        self.Friend.tintColor = self.settings.color_1
                        self.Friend.setTitle("Friends", for: .normal)
                        self.Friend.titleLabel?.textColor = self.settings.color_1
                        self.helper.ani_pop(element: self.Friend)
                        //
                        
                        // send event
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "friend"), object: nil, userInfo: ["row": self.index_row, "new_friendship_status": self.guest_data_obj.frindship_status])
                        
                    }else{
                        self.helper.show_alert_ok(title: "Error", message: result["error"] as! String, target_view: self)
                    }
                })
            }
            
            // Friend decline
            let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                // send request to the server
                self.helper.api_decline_friend_request(current_user_id: user_id, friend_id: target_user_id, target_view: self, on_complete: {result in
                    
                    if(result["status"] as! Int == 1){
                        self.guest_data_obj.frindship_status = 0
                        
                        // Friend button appearence
                        let image = UIImage(named: "unfriend")
                        self.Friend.setBackgroundImage(image, for: .normal)
                        self.Friend.tintColor = UIColor.darkGray
                        self.Friend.setTitle("Add", for: .normal)
                        self.Friend.titleLabel?.textColor = UIColor.darkGray
                        self.helper.ani_pop(element: self.Friend)
                        //

                        // send event
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "friend"), object: nil, userInfo: ["row": self.index_row, "new_friendship_status": self.guest_data_obj.frindship_status])
                        
                    }else{
                        self.helper.show_alert_ok(title: "Error", message: result["error"] as! String, target_view: self)
                    }
                })
                
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            
            
            sheet.addAction(delete)
            sheet.addAction(confirm)
            sheet.addAction(cancel)
            
            present(sheet, animated: true, completion: nil)
            break
            
        case 1:  // Request has been sent by current user, remove this request
            helper.api_delete_friend_request(current_user_id: user_id, target_user_id: target_user_id, target_view: self, on_complete: {result in
                
                if(result["status"] as! Int == 1){
                    // Update status
                    self.guest_data_obj.frindship_status = 0
                    
                    let image = UIImage(named: "unfriend.png")
                    self.Friend.setBackgroundImage(image, for: .normal)
                    self.Friend.tintColor = UIColor.darkGray
                    self.Friend.setTitle("Add", for: .normal)
                    self.Friend.titleLabel?.textColor = UIColor.darkGray
                    self.helper.ani_pop(element: self.Friend)
                    
                    // send event
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "friend"), object: nil, userInfo: ["row": self.index_row, "new_friendship_status": self.guest_data_obj.frindship_status])
                    
                }else{
                    self.helper.show_alert_ok(title: "Error", message: result["error"] as! String, target_view: self)
                }
            })
            break
            
        case 0: // Not interacted, Send friend request
            helper.api_add_friend_request(current_user_id: user_id, target_user_id: target_user_id, target_view: self, on_complete: {result in
                
                if(result["status"] as! Int == 1){
                    self.guest_data_obj.frindship_status = 1
                    
                    let image = UIImage(named: "request.png")
                    self.Friend.setBackgroundImage(image, for: .normal)
                    self.Friend.tintColor = self.settings.color_2
                    self.Friend.setTitle("Requested", for: .normal)
                    self.Friend.titleLabel?.textColor = self.settings.color_2
                    self.helper.ani_pop(element: self.Friend)
                    
                    // send event
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "friend"), object: nil, userInfo: ["row": self.index_row, "new_friendship_status": self.guest_data_obj.frindship_status])
                    
                }else{
                    self.helper.show_alert_ok(title: "Error", message: result["error"] as! String, target_view: self)
                }
            })
            break
            
        default:
            print("World will end soon...")
            break
        }
    }
    
    // On More button clicked
    @IBAction func More_clicked(_ sender: Any) {
        
        // calling function which shows action sheet for reporting
        showReportSheet(post_id: "0")
    }
    
    // On Follow button clicked
    @IBAction func Follow_clicked(_ sender: UIButton) {
        guard let current_user_id = current_user["user_id"] as? String else {
            return
        }
        let target_user_id = guest_data_obj.id
        
        if(guest_data_obj.is_followed == true){
            
            helper.api_delete_follow(current_user_id: current_user_id, target_user_id: target_user_id, target_view: self, on_complete: {result in
                
                if(result["status"] as! Int == 1){
                    self.guest_data_obj.is_followed = false
                    
                    let image = UIImage(named: "unfollow")
                    self.Follow.setBackgroundImage(image, for: .normal)
                    self.Follow.tintColor = UIColor.darkGray
                    self.Follow.setTitle("Follow", for: .normal)
                    self.Friend.titleLabel?.textColor = UIColor.darkGray
                    self.helper.ani_pop(element: self.Follow)
                    
                }else{
                    self.helper.show_alert_ok(title: "Error", message: result["error"] as! String, target_view: self)
                }
            })
            
        }else{
            
            helper.api_add_follow(current_user_id: current_user_id, target_user_id: target_user_id, target_view: self, on_complete: {result in
                
                if(result["status"] as! Int == 1){
                    self.guest_data_obj.is_followed = true
                    
                    let image = UIImage(named: "follow")
                    self.Follow.setBackgroundImage(image, for: .normal)
                    self.Follow.tintColor = self.settings.color_1
                    self.Follow.setTitle("Following", for: .normal)
                    self.Friend.titleLabel?.textColor = self.settings.color_1
                    self.helper.ani_pop(element: self.Follow)
                    
                }else{
                    self.helper.show_alert_ok(title: "Error", message: result["error"] as! String, target_view: self)
                }
            })
            
        }
    }
    
    // On post options button clicked
    @IBAction func Post_Options_clicked(_ optionsButton: UIButton) {
        
        // accessing indexPath.row of the cell
        let indexPathRow = optionsButton.tag
        
        // accessing id of the post in order to specity it in the server
        let post_id = posts[indexPathRow].id
        
        // calling function which shows action sheet for reporting
        showReportSheet(post_id: post_id)
    }
    
    // on Like button clicked
    @IBAction func Like_clicked(_ Like: UIButton) {
        
        guard let user_id = current_user["user_id"] as? String else{
            print("ERROR: CANT GET USER ID")
            return
        }
        
        let row_index = Like.tag
        print("LIKE TAG", row_index)
        print("POST CONTENT", posts[row_index])
        //print("CORRESPONDING ELEMENT IN LIKES", liked[row_index])
        guard let post_id = Int(posts[row_index].id) else{
            print("ERROR: CANT GET POST ID")
            return
        }
        
        //print("LIKES ARR", self.liked)
        
        var action = ""
        if(posts[row_index].is_liked_by_current_user == true){
            action = "delete"
            Like.setImage(UIImage(named: "unlike.png"), for: .normal)
            Like.tintColor = UIColor.darkGray
            
        }else{
            action = "create"
            Like.setImage(UIImage(named: "like.png"), for: .normal)
            Like.tintColor = settings.color_2
        }
        
        
        
        helper.ani_pop(element: Like)
        
        helper.api_like(current_user_id: user_id, post_id: post_id, user_id: posts[row_index].user_id, action: action, target_view: self, on_complete: {result in
            print("api_like END:", result)
            
            if(result["status"] as! Int == 1){
                
                if(action == "delete"){
                    self.posts[row_index].is_liked_by_current_user = false
                }else{
                    self.posts[row_index].is_liked_by_current_user = true
                }
            }else{
                // If failed return images
                if(action == "delete"){
                    Like.setImage(UIImage(named: "like.png"), for: .normal)
                    Like.tintColor = self.settings.color_2
                }else{
                    Like.setImage(UIImage(named: "unlike.png"), for: .normal)
                    Like.tintColor = UIColor.darkGray
                }
            }
        })
    }
    
    /* INTERACTIONS END */
    /**************** EVENTS END *****************/
    /******************* FUNCS *******************/
    /* OTHER */
    
    func reload_user_data(){
        // Fullname
        Fullname.text = guest_data_obj.fullname
        // Biography
        let biotext = guest_data_obj.biography
        Biography.text = biotext
        if(biotext.isEmpty){
            Biography.frame.size.height = 0
        }
        
        // Allowed friends
        if(guest_data_obj.allow_friends != "1"){
            Friend.isEnabled = false
        }
        
        // Allowed follow
        if(guest_data_obj.allow_follow != "1"){
            Follow.isEnabled = false
        }
        
        // Is following this user -> change button appearence
        if(guest_data_obj.is_followed == true){
            Follow.isEnabled = true
            let image = UIImage(named: "follow")
            Follow.setBackgroundImage(image, for: .normal)
            Follow.tintColor = settings.color_1
            Follow.setTitle("Following", for: .normal)
            Follow.titleLabel?.textColor = settings.color_1
        }
        
  
        
        // Avatar
        if(guest_data_obj.avatar_url.isEmpty == false){
            
            if(guest_data_obj.avatar_is_cached == true){
                // Use cached
                Avatar.image = guest_data_obj.avatar
                
            }else{
                // DL
                let url = URL(string: guest_data_obj.avatar_url)!
                
                helper.download_image(url: url, on_complete: {image in
                    self.guest_data_obj.avatar = image // Cache
                    self.guest_data_obj.avatar_is_cached = true
                    self.Avatar.image = image
                    
                }, on_fail: {
                    // Use default
                    let image = UIImage(named: self.settings.default_avatar) ?? UIImage()
                    self.guest_data_obj.avatar = image // Cache
                    self.guest_data_obj.avatar_is_cached = true
                    self.Avatar.image = image
                })
            }
            
        }else{
            let image = UIImage(named: self.settings.default_cover) ?? UIImage()
            guest_data_obj.avatar = image // Cache
            guest_data_obj.avatar_is_cached = true
            Avatar.image = image
        }
        
        // Cover
        if(guest_data_obj.cover_url.isEmpty == false){
            
            if(guest_data_obj.cover_is_cached == true){
                // Use cached
                Cover.image = guest_data_obj.cover
                
            }else{
                // DL
                let url = URL(string: guest_data_obj.cover_url)!
                
                helper.download_image(url: url, on_complete: {image in
                    self.guest_data_obj.cover = image // Cache
                    self.guest_data_obj.cover_is_cached = true
                    self.Cover.image = image
                    
                }, on_fail: {
                    // Use default
                    let image = UIImage(named: self.settings.default_cover) ?? UIImage()
                    self.guest_data_obj.cover = image // Cache
                    self.guest_data_obj.cover_is_cached = true
                    self.Cover.image = image
                })
            }
            
        }else{
            let image = UIImage(named: self.settings.default_cover) ?? UIImage()
            guest_data_obj.cover = image // Cache
            guest_data_obj.cover_is_cached = true
            Cover.image = image
        }
        
        // Friend request button appearence
        switch guest_data_obj.frindship_status {
        case 3:
            let image = UIImage(named: "friends")
            Friend.setBackgroundImage(image, for: .normal)
            Friend.tintColor = settings.color_1
            Friend.setTitle("Friends", for: .normal)
            Friend.titleLabel?.textColor = settings.color_1
            break
        case 2:
            let image = UIImage(named: "respond")
            Friend.setBackgroundImage(image, for: .normal)
            Friend.tintColor = settings.color_1
            Friend.setTitle("Respond", for: .normal)
            Friend.titleLabel?.textColor = settings.color_1
            break
        case 1:
            let image = UIImage(named: "request")
            Friend.setBackgroundImage(image, for: .normal)
            Friend.tintColor = settings.color_1
            Friend.setTitle("Requested", for: .normal)
            Friend.titleLabel?.textColor = settings.color_1
            break
        case 0:
            let image = UIImage(named: "unfriend")
            Friend.setBackgroundImage(image, for: .normal)
            Friend.tintColor = settings.color_1
            Friend.setTitle("Add", for: .normal)
            Friend.titleLabel?.textColor = UIColor.darkGray
            break
        default:
            let image = UIImage(named: "unfriend")
            Friend.setBackgroundImage(image, for: .normal)
            Friend.tintColor = settings.color_1
            Friend.setTitle("Add", for: .normal)
            Friend.titleLabel?.textColor = UIColor.darkGray
            print("World will end soon...")
            break
        }
        
        /*
        if(guest_data_obj.is_friend_requested == true){
            let image = UIImage(named: "request.png")
            Friend.setBackgroundImage(image, for: .normal)
            Friend.tintColor = settings.color_2
            Friend.setTitle("Requested", for: .normal)
            Friend.titleLabel?.textColor = settings.color_2
        }else{
            let image = UIImage(named: "unfriend.png")
            Friend.setBackgroundImage(image, for: .normal)
            Friend.tintColor = UIColor.darkGray
            Friend.setTitle("Add", for: .normal)
            Friend.titleLabel?.textColor = UIColor.darkGray
        }
        */
        
    }
    
    // action sheet for reporting
    func showReportSheet(post_id: String) {
        
        // declaring action sheet
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // creating buttons
        let report = UIAlertAction(title: "Report", style: .default) { (action) in
            
            // declaring alert controller
            let alert = UIAlertController(title: "Report", message: "Please explain the reason", preferredStyle: .alert)
            
            // creating buttons
            let send = UIAlertAction(title: "Send", style: .default) { (action) in
                
                // accessing current user's id
                guard let current_user_id = current_user["user_id"] as? String else {
                    return
                }
                
                // id of the user we're complaining about
                let user_id = self.guest_data_obj.id
                
                // access reason from alert's textField
                let textField = alert.textFields![0]
                
                self.helper.api_add_report(current_user_id: current_user_id, user_id: user_id, post_id: post_id, reason: textField.text!, target_view: self, on_complete: { result in
                    
                    self.helper.show_alert_ok(title: "Success", message: "Report sent successfully", target_view: self)
                })
                
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            // assigning buttons and adding textField
            alert.addAction(send)
            alert.addAction(cancel)
            alert.addTextField { (textField) in
                textField.placeholder = "I'm reporting because..."
                textField.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
            }
            
            // showing alert controller
            self.present(alert, animated: true, completion: nil)
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // assigning buttons
        sheet.addAction(report)
        sheet.addAction(cancel)
        
        // showing action sheet
        present(sheet, animated: true, completion: nil)
        
    }
    
    // Initial load posts
    func load_posts(offset: Int, limit: Int){
        if(is_posts_loading == true){
            return
        }
        print("LOAD POSTS TRIGGERED")
        print("OFFSET:", offset, " LIMIT:", limit)
        is_posts_loading = true
        let user_id = guest_data_obj.id
        
        posts.removeAll(keepingCapacity: false)
        
        helper.api_get_posts(user_id: user_id, limit: limit, offset: offset, target_view: self, on_complete: {result in
            print("api_get_posts RESULT", result)
            
            if(result["status"] as! Int == 1){
                
                let content = result["content"] as! NSDictionary
                //print("GET POSTS RESULT", result)
                guard let found_posts = content["posts"] as? [NSDictionary] else{
                    print("Cant let new_posts fail")
                    return
                }
                
                
                
                for post in found_posts {
                    
                    if let id = post["id"] as? String,
                        let user_id = post["user_id"] as? String
                    {
                        let first_name = self.helper.cast(value: post["first_name"])
                        let last_name = self.helper.cast(value: post["last_name"])
                        let text = self.helper.cast(value: post["text"])
                        let avatar_url = self.helper.cast(value: post["avatar"])
                        let post_image_url = self.helper.cast(value: post["image"])
                        let date = self.helper.cast(value: post["date"])
                        
                        let data_obj = Post()
                        data_obj.id = id
                        data_obj.user_id = user_id
                        data_obj.avatar_url = avatar_url
                        data_obj.post_image_url = post_image_url
                        data_obj.first_name = first_name
                        data_obj.last_name = last_name
                        data_obj.full_name = "\(first_name.capitalized) \(last_name.capitalized)"
                        data_obj.text = text
                        data_obj.date = date
                        if(post_image_url.isEmpty == false){
                            data_obj.post_type = "image"
                        }else{
                            data_obj.post_type = "plain"
                        }
                        
                        if(post["liked"] is NSNull){
                            data_obj.is_liked_by_current_user = false
                        }else{
                            data_obj.is_liked_by_current_user = true
                        }
                        
                        print("---- \(id) ----")
                        print("avatar_url", avatar_url)
                        print("post_image_url", post_image_url)
                        print("post_type", data_obj.post_type)
                        
                        self.posts.append(data_obj)
                    }
                }
                
                
                DispatchQueue.main.async {
                    self.offset = self.posts.count
                    self.Guest_Posts_Table.reloadData()
                    self.is_posts_loading = false
                }
                
                
            }else{
                print("STATUS ERROR")
            }
            
            self.is_posts_loading = false
        })
    }
    
    // Load more posts
    func load_more_posts(offset: Int, limit: Int){
        if(is_posts_loading == true){
            return
        }
        print("LOAD MORE POSTS TRIGGERED")
        print("OFFSET:", offset, " LIMIT:", limit)
        is_posts_loading = true
        let user_id = guest_data_obj.id
        
        helper.api_get_posts(user_id: user_id, limit: limit, offset: offset, target_view: self, on_complete: {result in
            if(result["status"] as! Int == 1){
                
                let content = result["content"] as! NSDictionary
                //print("GET POSTS RESULT", result)
                guard let found_posts = content["posts"] as? [NSDictionary] else{
                    print("Cant let new_posts fail")
                    return
                }
                
                if(found_posts.count > 0){
                    
                    self.tableView.beginUpdates()
                    
                    var i = 0
                    for post in found_posts {
                        
                        if let id = post["id"] as? String,
                            let user_id = post["user_id"] as? String
                        {
                            let first_name = self.helper.cast(value: post["first_name"])
                            let last_name = self.helper.cast(value: post["last_name"])
                            let text = self.helper.cast(value: post["text"])
                            let avatar_url = self.helper.cast(value: post["avatar"])
                            let post_image_url = self.helper.cast(value: post["image"])
                            let date = self.helper.cast(value: post["date"])
                            
                            let data_obj = Post()
                            data_obj.id = id
                            data_obj.user_id = user_id
                            data_obj.avatar_url = avatar_url
                            data_obj.post_image_url = post_image_url
                            data_obj.first_name = first_name
                            data_obj.last_name = last_name
                            data_obj.full_name = "\(first_name.capitalized) \(last_name.capitalized)"
                            data_obj.text = text
                            data_obj.date = date
                            if(post_image_url.isEmpty == false){
                                data_obj.post_type = "image"
                            }else{
                                data_obj.post_type = "plain"
                            }
                            
                            if(post["liked"] is NSNull){
                                data_obj.is_liked_by_current_user = false
                            }else{
                                data_obj.is_liked_by_current_user = true
                            }
                            
                            print("---- \(id) ----")
                            print("avatar_url", avatar_url)
                            print("post_image_url", post_image_url)
                            print("post_type", data_obj.post_type)
                            
                            self.posts.append(data_obj)
                            
                            // Insert in table
                            let section_index = self.tableView.numberOfSections - 1 // Column index?
                            let row_index = self.tableView.numberOfRows(inSection: section_index)
                            let path_to_last_row = IndexPath(row: row_index + i, section: section_index)
                            self.tableView.insertRows(at: [path_to_last_row], with: .fade)
                            
                            i += 1
                        }
                    }
                    
                    self.offset += found_posts.count
                    self.tableView.endUpdates()
                }
            }else{
                print("STATUS ERROR")
            }
            
            self.is_posts_loading = false
        })
    }
    
    // Prepare and send data for Segue (show)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "CommentsVC"){
            let index_row = (sender as! UIButton).tag
            let index_path = IndexPath(item: index_row, section: 0)
            let vc = segue.destination as! CommentsVC
            
            vc.stored_user_id = posts[index_row].user_id
            vc.stored_post_id = Int(posts[index_row].id )!
            vc.stored_avatar = Avatar.image!
            vc.stored_fullname = Fullname.text!
            vc.stored_date = posts[index_row].date
            vc.stored_post_text = posts[index_row].text
            print("stored_post_text", posts[index_row].text)
            if let cell = tableView.cellForRow(at: index_path) as? TblCell_Post_Image{
                vc.stored_post_image = cell.Post_Image.image ?? UIImage()
            }
            
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }else if(segue.identifier == "GuestVC_Chat"){
            guard
                let chatVC = segue.destination as? ChatVC
                //let contact = sender as? Chat_Contact
                else {
                    return
            }
            
            guard let user_id = current_user["user_id"] as? String,
                let first_name = current_user["first_name"] as? String,
                let last_name = current_user["last_name"] as? String,
                let avatar_url = current_user["avatar"] as? String
                else {
                    return
            }
            
            let avatar = current_user_avatar ?? UIImage(named: self.settings.default_avatar)!
            let full_name: String = "\(first_name.capitalized) \(last_name.capitalized)"
            let new_messages = 0
            
            chatVC.chat_id = "-1"
            
            var sender = Chat_Contact()
            sender.avatar = avatar
            sender.avatar_url = avatar_url
            sender.avatar_is_cached = true
            //sender.chat_id = chat_id
            sender.first_name = first_name
            sender.last_name = last_name
            sender.full_name = full_name
            sender.user_id = user_id
            sender.new_messages = new_messages
            
            var reciever = Chat_Contact()
            reciever.avatar = guest_data_obj.avatar
            reciever.avatar_url = guest_data_obj.avatar_url
            reciever.avatar_is_cached = true
            //reciever = chat_id
            reciever.first_name = guest_data_obj.first_name
            reciever.last_name = guest_data_obj.last_name
            reciever.full_name = guest_data_obj.fullname
            reciever.user_id = guest_data_obj.id
            reciever.new_messages = new_messages
            
            //print("segue reciever", reciever)
            //print("segue sender", sender)
            
            chatVC.reciever = reciever
            chatVC.sender = sender
            
            //print("segue chatVC reciever", chatVC.reciever)
            //print("segue chatVC sender", chatVC.sender)
            
            //let cell = tableView.cellForRow(at: indexPath) as! ContactsTableViewCell
            //cell.New_Messages.text = "0"
            
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
        
    
    /* OTHER END */
    /***************** FUNCS END *****************/
    

}
