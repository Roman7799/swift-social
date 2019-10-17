//
//  FeedVC.swift
//  social
//
//  Created by Denis Vesnin on 10/3/19.
//  Copyright © 2019 Geolance. All rights reserved.
//

import UIKit

class FeedVC: UITableViewController {
    
    let helper = Helper()
    let settings = Settings()
    
    var posts = [Post]()
    var offset = 0
    var limit = 5
    var is_posts_loading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Auto height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 303

        load_posts(offset: offset, limit: limit)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TblCell_Post_Image", for: indexPath) as! TblCell_Post_Image
        
        // Fullname
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
                    DispatchQueue.main.async {
                        cell.Avatar.image = image
                    }
                })
            }else{
                let image = UIImage(named: self.settings.default_avatar)
                self.posts[indexPath.row].cached_avatar = image! // Cache
                self.posts[indexPath.row].is_avatar_cached = true
                cell.Avatar.image = image
            }
        }
        
        // Post Image
        if(self.posts[indexPath.row].post_type == "image"){
            let post_image_url = self.posts[indexPath.row].post_image_url
            let url = URL(string: post_image_url)!
            
            //TODO: Try to use function for table cell update instead of this tableView cellForRowAt
            
            if(self.posts[indexPath.row].is_post_image_cached == true){
                // Use cached
                //DispatchQueue.main.async {
                    let image = self.posts[indexPath.row].cached_post_image
                    
                    //let aspect = image.size.width / image.size.height
                   
                    //cell.Post_Image.layoutIfNeeded()
                    
                    cell.Post_Image.image = image
                    //let newHeight = cell.Post_Image.frame.width / aspect
                    //print("NEW WIDTH-HEIGHT", cell.Post_Image.frame.width, newHeight)
                    //cell.Post_Image_height.constant = newHeight
                    //self.view.layoutIfNeeded()
                    //cell.updateConstraints()
                    //cell.layoutIfNeeded()
                    
                    // if uncommented need to rework a little
                    /*
                    let ratio = self.posts[indexPath.row].cached_post_image.size.width / self.posts[indexPath.row].cached_post_image.size.height
                    let newHeight = cell.Post_Image.frame.width / ratio
                    cell.Post_Image_height.constant = newHeight
                    self.view.layoutIfNeeded()
                    */
                    
                    
                //}
            }else{
                // Download and cache
                helper.download_image(url: url, on_complete: {(image) in
                    self.posts[indexPath.row].cached_post_image = image
                    self.posts[indexPath.row].is_post_image_cached = true
                    
                    
                    //let aspect = image.size.width / image.size.height
                    
                    
                    /*
                    let newConstraint = NSLayoutConstraint(item: cell.Post_Image, attribute: .width, relatedBy: .equal, toItem: cell.Post_Image, attribute: .height, multiplier: aspect, constant: 0)
                    cell.Post_Image.addConstraint(newConstraint)
                    NSLayoutConstraint.activate([newConstraint])
                    NSLayoutConstraint.deactivate(cell.Post_Image.constraints)
                    cell.Post_Image.layoutIfNeeded()
                    */
                    
                    cell.Post_Image.image = image
                    //let newHeight = (cell.Post_Image.superview!.frame.width / aspect) - 5
                    //print("NEW WIDTH-HEIGHT", cell.Post_Image.frame.width, newHeight)
                    //cell.Post_Image_height.constant = newHeight
                    
                    //self.posts[indexPath.row].cached_post_image_size = ["width": cell.Post_Image.superview!.frame.width, "height": newHeight]
                    //self.view.layoutIfNeeded()
      
                    //cell.setNeedsLayout()
                    
                    /*
                    UIView.performWithoutAnimation({
                        self.tableView.beginUpdates()
                        cell.updateConstraints()
                        //cell.layoutIfNeeded()
                        self.tableView.reloadRows(
                            at: [indexPath],
                            with: .none)
                        self.tableView.endUpdates()
                    })
 */
                    
                    
                    /*
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(
                        at: [indexPath],
                        with: .fade)
                    self.tableView.endUpdates()
 */

                    /*
                    print("OLD WIDTH-HEIGHT", self.posts[indexPath.row].cached_post_image.size.width, self.posts[indexPath.row].cached_post_image.size.height)
                    let ratio = self.posts[indexPath.row].cached_post_image.size.width / self.posts[indexPath.row].cached_post_image.size.height
                    print("RATIO", ratio)
                    let newHeight = cell.Post_Image.frame.width / ratio
                    print("NEW HEIGHT", newHeight)
                    cell.Post_Image_height.constant = newHeight
                    self.view.layoutIfNeeded()
 */
                })
            }
        }else{
            // image is empty - set height to 0
            cell.Post_Image_height?.constant = 0
            cell.updateConstraints()
        }
        // Post Image END
        
        // Set row index to Like button tag
        cell.tag = indexPath.row
        cell.Like.tag = indexPath.row
        cell.Comments.tag = indexPath.row
        cell.Post_Options.tag = indexPath.row
        
        // Assign image for like button
        DispatchQueue.main.async {
            if(self.posts[indexPath.row].is_liked_by_current_user == true){
                cell.Like.setImage(UIImage(named: "like.png"), for: .normal)
            }else{
                cell.Like.setImage(UIImage(named: "unlike.png"), for: .normal)
            }
        }
        
        return cell
        
    }
    
    
    // on scroll Load more posts
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if(tableView.contentOffset.y - tableView.contentSize.height + 60 > -tableView.frame.height && is_posts_loading == false)
        {
            load_posts(offset: self.offset, limit: self.limit)
        }
        
    }
    
    
    func load_posts(offset: Int, limit: Int){
        if(is_posts_loading == true){
            return
        }
        is_posts_loading = true
        
        guard let user_id = current_user["user_id"] as? String else {
            is_posts_loading = false
            return
        }
        
        var is_more = true
        if(offset == 0){
            is_more = false
            posts.removeAll(keepingCapacity: false)
        }
        
        helper.api_get_feed_posts(user_id: user_id, limit: limit, offset: offset, target_view: self, on_complete: {result in
            print("api_get_feed_posts RESULT", result)
            
            if(result["status"] as! Int == 1){
                
                //print("GET POSTS RESULT", result)
                guard let found_posts = result["content"] as? [NSDictionary] else{
                    print("Cant let new_posts fail")
                    self.is_posts_loading = false
                    return
                }
                
                if(found_posts.count > 0){
                    if(is_more){
                        self.tableView.beginUpdates()
                    }
                    
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
                            
                            if(is_more){
                                let section_index = self.tableView.numberOfSections - 1
                                let row_index = self.tableView.numberOfRows(inSection: section_index)
                                let path_to_last_row = IndexPath(row: row_index + i, section: section_index)
                                self.tableView.insertRows(at: [path_to_last_row], with: .fade)
                            }
                        }
                        
                        i += 1
                    }
                    
                    
                    DispatchQueue.main.async {
                        self.offset = self.posts.count
                        if(is_more){
                            self.tableView.endUpdates()
                        }else{
                            self.tableView.reloadData()
                        }
                        
                        self.is_posts_loading = false
                    }
                }else{
                    self.is_posts_loading = false
                }
                
                
                
                
            }else{
                print("STATUS ERROR")
            }
        })
    }
    
    
    
    
    
    
    // on Like button clicked
    @IBAction func Like_clicked(_ Like: UIButton) {
        
        guard let current_user_id = current_user["user_id"] as? String else{
            print("ERROR: CANT GET USER ID")
            return
        }
        
        let row_index = Like.tag
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
        
        helper.api_like(current_user_id: current_user_id, post_id: post_id, user_id: current_user_id, action: action, target_view: self, on_complete: {result in
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
    
    
    
    // On More button clicked
    @IBAction func More_clicked(_ sender: UIButton) {
        
        // calling function which shows action sheet for reporting
        let index = sender.tag
        showReportSheet(index: index)
    }
    
    // action sheet for reporting
    func showReportSheet(index: Int) {
        
        let indexPath = IndexPath(row: index, section: 0)
        let post_id = posts[index].id
        let user_id = posts[index].user_id
        
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
                
                // access reason from alert's textField
                let textField = alert.textFields![0]
                
                print("TRY TO SEND2")
                
                self.helper.api_add_report(current_user_id: current_user_id, user_id: user_id, post_id: post_id, reason: textField.text!, target_view: self, on_complete: { result in
                    
                    print("api_add_report", result)
                    if(result["status"] as! Int == 1){
                        self.helper.show_alert_ok(title: "Success", message: "Report sent successfully", target_view: self)
                    }
                    
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
    
    
    
    // Prepare and send data for Segue (show)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "CommentsVC"){
            let index_row = (sender as! UIButton).tag
            let index_path = IndexPath(item: index_row, section: 0)
            let vc = segue.destination as! CommentsVC
            
            vc.stored_user_id = posts[index_row].user_id
            vc.stored_post_id = Int(posts[index_row].id )!
            vc.stored_avatar = posts[index_row].cached_avatar
            vc.stored_fullname = posts[index_row].full_name
            vc.stored_date = posts[index_row].date
            vc.stored_post_text = posts[index_row].text

            if let cell = tableView.cellForRow(at: index_path) as? TblCell_Post_Image{
                vc.stored_post_image = cell.Post_Image.image ?? UIImage()
            }
            
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

}
