//
//  HomeVC.swift
//  social
//
//  Created by Geolance on 7/4/19.
//  Copyright © 2019 Geolance. All rights reserved.
//
// TODO:
// [TDDIL] - Delete image from server

import UIKit
import Photos

class HomeVC: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let helper = Helper()
    let settings = Settings()
    
    @IBOutlet weak var Cover_View: UIImageView!
    @IBOutlet weak var Avatar_View: UIImageView!
    @IBOutlet weak var Fullname_Label: UILabel!
    @IBOutlet weak var AddBiography_Button: UIButton!
    @IBOutlet weak var Biography_Label: UILabel!
    
    let picker = UIImagePickerController()
    var is_cover = false
    var is_avatar = false
    var image_view_tapped = ""
    var default_cover = "image_placeholder.png"
    var default_avatar = "image_placeholder.png"
    var cached_avatar: UIImage? = nil
    var cached_posts_image = [UIImage]()
    
    // Posts
    var posts = [Post]()
    var offset = 0
    var limit = 5
    var is_posts_loading = false
    var liked = [Int]()
    
    // Friends
    var friends = [User_Data]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        
        configure_Avatar_View()
        
        // Apply user data from current_user
        // Full name
        if let first_name = current_user["first_name"] as? String{
            if let last_name = current_user["last_name"] as? String{
                Fullname_Label.text = "\(first_name.capitalized) \(last_name.capitalized)"
            }
        }
        // Bio
        if let biography = current_user["biography"] as? String{
            Biography_Label.text = biography
            Biography_Label.isHidden = false
            AddBiography_Button.isHidden = true
        }else{
            Biography_Label.isHidden = true
            AddBiography_Button.isHidden = false
        }
        // Cover
        print("ON LOAD COVER PART")
        if let cover_url = current_user["cover"] as? String{
            if(cover_url.isEmpty == false){
                print("COVER URL NOT EMPTY", cover_url)
                let url = URL(string: cover_url)!
                
                helper.download_image(url: url, on_complete: {(image) in
                    self.Cover_View.image = image
                    self.is_cover = true
                    print("COVER RETRIEVED")
                })
            }
        }
        print("ON LOAD AVATAR PART")
        // Avatar
        if let avatar_url = current_user["avatar"] as? String{
            if(avatar_url.isEmpty == false){
                print("AVATAR URL NOT EMPTY", avatar_url)
                let url = URL(string: avatar_url)!
                
                if(current_user_avatar == nil){
                    // No stored Avatar
                    print("NO STORED AVATAR")
                    helper.download_image(url: url, on_complete: {(image) in
                        DispatchQueue.main.async {
                            self.Avatar_View.image = image
                        }
                        current_user_avatar = image
                        self.is_avatar = true
                        print("AVATAR RETRIEVED")
                    })
                    
                }else{
                    // Stored Avatar exists
                    print("STORED AVATAR:", current_user_avatar!)
                    self.Avatar_View.image = current_user_avatar
                    self.is_avatar = true
                }
                
                
            }
        }
        // current_user END
        
        // load posts (init)
        print("ON LOAD LOAD POSTS")
        load_posts(offset: offset, limit: limit)
        
        // load friends
        load_friends()
        
        // Add Event Observers
        // on Biography updated
        NotificationCenter.default.addObserver(self, selector: #selector(update_biography), name: NSNotification.Name(rawValue: "update_biography"), object: nil)
        
        // on User info updated
        NotificationCenter.default.addObserver(self, selector: #selector(update_user_info), name: NSNotification.Name(rawValue: "update_user_info"), object: nil)
        
        // on new post created
        NotificationCenter.default.addObserver(self, selector: #selector(objc_load_posts), name: NSNotification.Name(rawValue: "post_created"), object: nil)
        
        // on friend changed
        NotificationCenter.default.addObserver(self, selector: #selector(event_friend), name: NSNotification.Name(rawValue: "friend"), object: nil)
        
    
    }
    
    // pre-load func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // hide navigation bar on Home Pagex
        navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }

    // Rows count
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }else{
            return posts.count
        }
        
    }
    
    // Table row height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // Friends rows
        if indexPath.section == 0 {
            
            // height of the cell with 1 and 2 row
            if friends.count < 4 {
                return 200
            } else {
                return 370
            }
            
        // Posts rows
        } else {
            return UITableViewAutomaticDimension
        }
        
    }
    
    // Display of Table (posts) (initial)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        // Friends Section
        if(indexPath.section == 0){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TblCell_Friends", for: indexPath)
            
            // shortcuts, parameters of frame
            let gap : CGFloat = 15
            var x : CGFloat = 15
            var y : CGFloat = 50
            let width = (cell.contentView.frame.width / 3) - 20
            let height = width
            
            for i in 0 ..< friends.count {
                
                let frame = CGRect(x: x, y: y, width: width, height: height)
                let button = UIButton()
                button.frame = frame
                button.tag = 99
                button.setTitleColor(.black, for: .normal)
                button.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
                button.setTitle((friends[i].fullname).capitalized, for: .normal)
                button.centerVertically(gap: 30)
                cell.contentView.addSubview(button)
                
                // declare new x and y (coordinates) for the following button
                x += width + gap
                
                // if already 3 elements are shown, show the following elements in the new row
                if i == 2 {
                    x = 15
                    y += height + 30 + gap
                }
                
                // Avatar
                if(friends[i].avatar_url.isEmpty == false){
                    
                    if(friends[i].avatar_is_cached == true){
                        // Use cached
                        button.setBackgroundImage(friends[i].avatar, for: .normal)
                        
                    }else{
                        // DL
                        let url = URL(string: friends[i].avatar_url)!
                        
                        helper.download_image(url: url, on_complete: {image in
                            self.friends[i].avatar = image // Cache
                            self.friends[i].avatar_is_cached = true
                            
                            button.setBackgroundImage(image, for: .normal)
                            
                        }, on_fail: {
                            // Use default
                            let image = UIImage(named: self.settings.default_avatar) ?? UIImage()
                            self.friends[i].avatar = image // Cache
                            self.friends[i].avatar_is_cached = true
                            
                            button.setBackgroundImage(image, for: .normal)
                        })
                    }
                    
                }else{
                    let image = UIImage(named: self.settings.default_avatar) ?? UIImage()
                    self.friends[i].avatar = image // Cache
                    self.friends[i].avatar_is_cached = true
                    button.setBackgroundImage(image, for: .normal)
                }
                // Avatar END
                
            }
            
            return cell
            
        // Posts Section
        }else{
            
            
            if(self.posts[indexPath.row].post_type == "image"){
                let cell = tableView.dequeueReusableCell(withIdentifier: "TblCell_Post_Image", for: indexPath) as! TblCell_Post_Image
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
                }
                // Post Image END
                
                
                
                // Set post id to Like button tag
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
                print("cached_images", cached_posts_image.count)
                
                return cell
                
                
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "TblCell_Post_Plain", for: indexPath) as! TblCell_Post_Plain
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
                
                self.posts[indexPath.row].is_post_image_cached = true
                
                // Set post id to Like button tag
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
            
        // Posts Section END
        }
    }
    
    
    /****************** EVENTS *******************/
    /* INTERACTIONS */
    @IBAction func Cover_tapped(_ sender: Any) {
        print("COVER TAPPED")
        image_view_tapped = "cover"
        show_action_sheet()
        //show_image_picker(source: UIImagePickerController.SourceType.photoLibrary)
    }
    @IBAction func Avatar_tapped(_ sender: Any) {
        print("AVATAR TAPPED")
        image_view_tapped = "avatar"
        show_action_sheet()
    }
    
    // Tapped on filled biography
    @IBAction func Biography_Label_tapped(_ sender: Any) {
        
    }
    
    @IBAction func Log_clicked(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 2 // Go to Notifications
    }
    
    
    @IBAction func More_clicked(_ sender: UIButton) {
        // creating action sheet
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // creating buttons for action sheet
        let logout = UIAlertAction(title: "Log Out", style: .destructive, handler: { (action) in
            
            // access/instantiate loginViewController
            let loginvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            
            // show loginViewController
            self.present(loginvc, animated: false, completion: {
                
                // clear currentUser global var, after showing loginViewController - save as an empty user (blank NSMutableDictionary)
                current_user_avatar = nil
                
                current_user = NSMutableDictionary()
                UserDefaults.standard.set(current_user, forKey: "current_user")
                UserDefaults.standard.synchronize()
                
            })
            
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // add buttons to action sheet
        sheet.addAction(logout)
        sheet.addAction(cancel)
        
        // show action sheet
        present(sheet, animated: true, completion: nil)
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
        
        helper.api_like(current_user_id: user_id, post_id: post_id, user_id: user_id, action: action, target_view: self, on_complete: {result in
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
    
    // Post Options button clicked
    @IBAction func on_post_options_clicked(_ sender: UIButton) {
        guard let user_id = current_user["user_id"] as? String else{
            print("No current user")
            return
        }
        
        let alert_sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // creating Delete button
        let delete_action = UIAlertAction(title: "Delete Post", style: .destructive) { (delete) in
            
            let index = sender.tag
            let post_id = self.posts[index].id
               
            self.helper.api_delete_post(current_user_id: user_id, post_id: post_id, target_view: self, on_complete: {result in
                
                if(result["status"] as! Int == 1){
                    self.posts.remove(at: index)
                    self.liked.remove(at: index)
                    self.cached_posts_image.remove(at: index)
                    // delete cached avatar here if homeVC will have posts from multiple users
                    
                    let indexPath = IndexPath(row: index, section: 0)
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.tableView.endUpdates()
                    
                }else{
                    self.helper.show_alert_ok(title: "Error", message: result["error"] as! String, target_view: self)
                }
                
                
                
            })
            
        }
        
        // creating Cancel button
        let cancel_action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // assigning buttons to the sheet
        alert_sheet.addAction(delete_action)
        alert_sheet.addAction(cancel_action)
        
        // showing actionSheet
        present(alert_sheet, animated: true, completion: nil)
        
    }
    
    
    /* INTERACTIONS END */
    /* HOOKS */
    
    // Triggers after image was picked from library
    // 10.1
    //func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    // 9.2
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){

            let user_id = Int(current_user["user_id"] as! String)!
            // 10.1
            //let image = info[.editedImage] as? UIImage
            // 9.2
            let image = info[UIImagePickerControllerEditedImage] as? UIImage
        
            print("PICKED IMAGE")
        
            if(image == nil){
                print("image IS nil")
                return
            }
        
            if(self.image_view_tapped == "cover"){
                self.Cover_View.image = image
                
                let images = ["file0": image!]
                
                //self.helper.api_upload_image_of_type(user_id: user_id, type: "cover", image: image!, target_view: picker, on_complete: {result in
                self.helper.api_upload_image_of_type(user_id: user_id, type: "cover", images: images, target_view: picker, on_complete: {result in
                    print("UPLOAD FINISHED")
                    
                    if(result["status"] as! Int == 1){
                        let content = result["content"] as! NSDictionary
                        
                        current_user.setValue(content["image_url"], forKey: "cover")
                        UserDefaults.standard.set(current_user, forKey: "current_user")
                        
                        self.dismiss(animated: true, completion: {
                            print("IMAGE PICKER DISMISSED")
                            if(self.image_view_tapped == "cover"){
                                self.is_cover = true
                            }else if(self.image_view_tapped == "avatar"){
                                self.is_avatar = true
                            }
                        })
                        
                    }else{
                        self.helper.show_alert_ok(title: "Error", message: result["error"] as! String, target_view: picker)
                    }
                })
                
            }else if(self.image_view_tapped == "avatar"){
                self.Avatar_View.image = image
                current_user_avatar = image!
                
                let images = ["file0": image!]
                
                self.helper.api_upload_image_of_type(user_id: user_id, type: "avatar", images: images, target_view: self, on_complete: {result in
                    print("UPLOAD FINISHED")
                    
                    let content = result["content"] as! NSDictionary
                    
                    current_user.setValue(content["image_url"], forKey: "avatar")
                    UserDefaults.standard.set(current_user, forKey: "current_user")
                    
                    self.dismiss(animated: true, completion: {
                        print("IMAGE PICKER DISMISSED")
                        if(self.image_view_tapped == "cover"){
                            self.is_cover = true
                        }else if(self.image_view_tapped == "avatar"){
                            self.is_avatar = true
                        }
                    })
                    
                })
            }

        
    }
    
    
    // on scroll Load more posts
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if(tableView.contentOffset.y - tableView.contentSize.height + 60 > -tableView.frame.height && is_posts_loading == false)
        {
            load_more_posts(offset: self.offset, limit: self.limit)
        }
        
    }
    
    // Display loaded posts (load_more_posts)
    /*
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        
        print("TV SECOND TRIGGERED")
        let post_image = self.posts[indexPath.row]["image"] as! String
        
        if(post_image.isEmpty){
            // Post of type Plain
            let cell = tableView.dequeueReusableCell(withIdentifier: "TblCell_Post_Plain", for: indexPath) as! TblCell_Post_Plain
            
            // Cell Fullname
            let cell_first_name = self.posts[indexPath.row]["first_name"] as! String
            let cell_last_name = self.posts[indexPath.row]["last_name"] as! String
            cell.Fullname.text = "\(cell_first_name.capitalized) \(cell_last_name.capitalized)"
            
            // Cell Date
            let server_date_string = self.posts[indexPath.row]["date"] as! String
            let cell_date_string = helper.date_string_convert(date_string: server_date_string, from_format: settings.date_format_server, to_format: settings.date_format_post_front)
            cell.Date.text = cell_date_string
            
            // Cell Text
            let post_text = self.posts[indexPath.row]["text"] as! String
            cell.Post_Text.text = post_text
            
            // Avatar
            if(cached_avatar != nil){
                cell.Avatar.image = cached_avatar!
            }else{
                if let avatar_url = self.posts[indexPath.row]["avatar"] as? String{
                    if(avatar_url.isEmpty == false){
                        let url = URL(string: avatar_url)!
                        
                        helper.download_image(url: url, on_complete: {(image) in
                            self.cached_avatar = image // Cache
                            cell.Avatar.image = image
                        })
                    }else{
                        cell.Avatar.image = UIImage(named: self.settings.default_avatar)
                    }
                }else{
                    cell.Avatar.image = UIImage(named: self.settings.default_avatar)
                }
            }
            
            cached_posts_image.append(UIImage())
            
            // Set post id to Like button tag
            cell.Like.tag = indexPath.row
            cell.Comments.tag = indexPath.row
            
            // Assign image for like button
            DispatchQueue.main.async {
                if(self.liked[indexPath.row] == 1){
                    cell.Like.setImage(UIImage(named: "like.png"), for: .normal)
                }else{
                    cell.Like.setImage(UIImage(named: "unlike.png"), for: .normal)
                }
            }
        
            // Post of type Plain END
        }else{
            // Post of type Image
            let cell = tableView.dequeueReusableCell(withIdentifier: "TblCell_Post_Image", for: indexPath) as! TblCell_Post_Image
            
            // Cell Fullname
            let cell_first_name = self.posts[indexPath.row]["first_name"] as! String
            let cell_last_name = self.posts[indexPath.row]["last_name"] as! String
            cell.Fullname.text = "\(cell_first_name.capitalized) \(cell_last_name.capitalized)"
            
            // Cell Date
            let server_date_string = self.posts[indexPath.row]["date"] as! String
            let cell_date_string = helper.date_string_convert(date_string: server_date_string, from_format: settings.date_format_server, to_format: settings.date_format_post_front)
            cell.Date.text = cell_date_string
            
            // Cell Text
            let post_text = self.posts[indexPath.row]["text"] as! String
            cell.Post_Text.text = post_text
            
            // Avatar
            if(cached_avatar != nil){
                cell.Avatar.image = cached_avatar!
            }else{
                if let avatar_url = self.posts[indexPath.row]["avatar"] as? String{
                    if(avatar_url.isEmpty == false){
                        let url = URL(string: avatar_url)!
                        
                        helper.download_image(url: url, on_complete: {(image) in
                            self.cached_avatar = image // Cache
                            cell.Avatar.image = image
                        })
                    }else{
                        cell.Avatar.image = UIImage(named: self.settings.default_avatar)
                    }
                }else{
                    cell.Avatar.image = UIImage(named: self.settings.default_avatar)
                }
            }
            
            // Post Image
            if let post_image_url = self.posts[indexPath.row]["image"] as? String{
                if(post_image_url.isEmpty == false){
                    let url = URL(string: post_image_url)!
                    
                    if(posts.count != cached_posts_image.count){
                        // Download and cache
                        helper.download_image(url: url, on_complete: {(image) in
                            self.cached_posts_image.append(image)
                            cell.Post_Image.image = image
                            let ratio = image.size.width / image.size.height
                            let newHeight = cell.Post_Image.frame.width / ratio
                            cell.Post_Image_height.constant = newHeight
                            self.view.layoutIfNeeded()
                            
                        })
                    }else{
                        // Use cached
                        DispatchQueue.main.async {
                            cell.Post_Image.image = self.cached_posts_image[indexPath.row]
                            let ratio = self.cached_posts_image[indexPath.row].size.width / self.cached_posts_image[indexPath.row].size.height
                            let newHeight = cell.Post_Image.frame.width / ratio
                            cell.Post_Image_height.constant = newHeight
                            self.view.layoutIfNeeded()
                        }
                    }
                    
                    
                }else{
                    print("ERROR: post_image_url is empty")
                }
            }else{
                print("ERROR: let post_image_url failed")
            }
            
            // Set post id to Like button tag
            cell.Like.tag = indexPath.row
            cell.Comments.tag = indexPath.row
            
            // Assign image for like button
            DispatchQueue.main.async {
                if(self.liked[indexPath.row] == 1){
                    cell.Like.setImage(UIImage(named: "like.png"), for: .normal)
                }else{
                    cell.Like.setImage(UIImage(named: "unlike.png"), for: .normal)
                }
            }
            
        } // Post type Image END
        
        print("posts", posts.count)
        print("cached_images", cached_posts_image.count)
        
        
    }
  */
    // Prepare and send data for Segue (show)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "CommentsVC"){
            let index_row = (sender as! UIButton).tag
            let index_path = IndexPath(item: index_row, section: 0)
            let vc = segue.destination as! CommentsVC
            
            vc.stored_user_id = posts[index_row].user_id
            vc.stored_post_id = Int(posts[index_row].id )!
            vc.stored_avatar = Avatar_View.image!
            vc.stored_fullname = Fullname_Label.text!
            vc.stored_date = posts[index_row].date
            vc.stored_post_text = posts[index_row].text
            if let cell = tableView.cellForRow(at: index_path) as? TblCell_Post_Image{
                vc.stored_post_image = cell.Post_Image.image!
            }
        }
    }

 
    @objc func event_friend(_ notification: Notification){
        // change friendship status and button appearence
        
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: indexPath)
        print("event_friend(delete cell)")
        
        for view in (cell?.contentView.subviews)! {
            if(view.tag == 99){
                view.removeFromSuperview()
            }
        }

        //tableView.deleteRows(at: [indexPath], with: .fade)
        load_friends()
    }
    
    /* HOOKS END */
    /**************** EVENTS END *****************/
    /****************** VISUALS ******************/
    func configure_Avatar_View(){
        helper.add_border(target_view: Avatar_View, width: 5, color: UIColor.white.cgColor)
        
        Avatar_View.layer.cornerRadius = 10
        Avatar_View.layer.masksToBounds = true
        Avatar_View.clipsToBounds = true
        
    }
    /**************** VISUALS END ****************/
    /******************* FUNCS *******************/
    /* OTHER */
    func show_action_sheet(){
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Camera button
        let action_camera = UIAlertAction(title: "Camera", style: .default, handler: {(action) in
            print("ACTION CAMERA")
            if(UIImagePickerController.isSourceTypeAvailable( .camera )){
                self.show_image_picker(source: .camera)
            }else{
                print("CAMERA NOT AVAILIABLE")
            }
        })
        
        // Library button
        let action_library = UIAlertAction(title: "Photo library", style: .default, handler: {(action) in
            print("ACTION LIBRARY")
            
            if(UIImagePickerController.isSourceTypeAvailable( .photoLibrary )){
                self.show_image_picker(source: .photoLibrary)
            }else{
                print("LIBRARY NOT AVAILIABLE")
            }
        })
        
        // Cancel button
        let action_cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Delete button
        let action_delete = UIAlertAction(title: "Delete", style: .destructive, handler: {(action) in
            print("ACTION DELETE", self.image_view_tapped)
           
            guard let user_id = current_user["user_id"] as? String else{
                return
            }
            
            if(self.image_view_tapped == "cover"){
                self.helper.delete_image_of_type(user_id: user_id, type: "cover", target_view: self, on_complete: {(result) in
                    if(result["status"] as! Int == 1){
                        self.Cover_View.image = UIImage(named: self.settings.default_cover)
                        self.is_cover = false
                        current_user.setValue(nil, forKey: "cover")
                        UserDefaults.standard.set(current_user, forKey: "current_user")
                        self.dismiss(animated: true, completion: nil)
                    }else{
                        self.dismiss(animated: true, completion: nil)
                        self.helper.show_alert_ok(title: "Error", message: result["error"] as! String, target_view: self)
                    }
                })
            }else if(self.image_view_tapped == "avatar"){
                self.helper.delete_image_of_type(user_id: user_id, type: "cover", target_view: self, on_complete: {(result) in
                    if(result["status"] as! Int == 1){
                        self.Avatar_View.image = UIImage(named: self.settings.default_avatar)
                        self.is_avatar = false
                        current_user_avatar = UIImage(named: self.settings.default_avatar)!
                        current_user.setValue(nil, forKey: "avatar")
                        UserDefaults.standard.set(current_user, forKey: "current_user")
                        
                        self.dismiss(animated: true, completion: nil)
                    }else{
                        self.dismiss(animated: true, completion: nil)
                        self.helper.show_alert_ok(title: "Error", message: result["error"] as! String, target_view: self)
                    }
                })
            }
            
        })
        if(image_view_tapped == "cover" && is_cover == false){
            action_delete.isEnabled = false
        }else if(image_view_tapped == "avatar" && is_avatar == false){
            action_delete.isEnabled = false
        }
        
        sheet.addAction(action_camera)
        sheet.addAction(action_library)
        sheet.addAction(action_cancel)
        sheet.addAction(action_delete)
        self.present(sheet, animated: true, completion: nil)
    }
    
    // Tapped on biography, show actions
    func show_biography_sheet(){
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // New Biography button
        let action_new = UIAlertAction(title: "New Biography", style: .default, handler: {(action) in
            print("ACTION NEW_BIOGRAPHY")
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BiographyVC")
            self.present(vc, animated: true, completion: nil)
        })
        
        // Cancel button
        let action_cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Delete button
        let action_delete = UIAlertAction(title: "Delete", style: .destructive, handler: {(action) in
            print("ACTION DELETE")
            let user_id = current_user["id"] as! String
            self.helper.api_update_biography(user_id: user_id, text: "", target_view: self, on_complete: {result in
                print("BIOGRAPHY DELETED")
                
                // update global user
                current_user["biography"] = ""
                UserDefaults.standard.set(current_user, forKey: "current_user")
                
                // send event
                NotificationCenter.default.post(name: NSNotification.Name("update_biography"), object: nil)
            })
        })
        
        sheet.addAction(action_new)
        sheet.addAction(action_cancel)
        sheet.addAction(action_delete)
        self.present(sheet, animated: true, completion: nil)
    }
    
    // 10.1
    //func show_image_picker(source: UIImagePickerController.SourceType){
    // 9.2
    func show_image_picker(source: UIImagePickerControllerSourceType){
     
        if(source == .photoLibrary){
            let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
            switch photoAuthorizationStatus {
            case .authorized:
                print("photo library authorized")
                picker.allowsEditing = true
                picker.sourceType = source
                present(picker, animated: true, completion: nil)
                break
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({
                    (newStatus) in print("status is \(newStatus)")
                    if newStatus == PHAuthorizationStatus.authorized {
                        // Do here
                        print("photo library access granted")
                        self.picker.allowsEditing = true
                        self.picker.sourceType = source
                        self.present(self.picker, animated: true, completion: nil)
                    }else{
                        print("photo library access rejected")
                        self.helper.show_alert_ok(title: "Error", message: "Access to library is restricted", target_view: self)
                        
                    }
                })
                break
            case .restricted:
                print("User do not have access to photo album.")
                helper.show_alert_ok(title: "Error", message: "Access to library is restricted", target_view: self)
                break
            case .denied:
                print("User has denied the permission.")
                helper.show_alert_ok(title: "Error", message: "Access to library is restricted", target_view: self)
                break
            }
        }else{
            print("not photo library")
            picker.allowsEditing = true
            picker.sourceType = source
            present(picker, animated: true, completion: nil)
        }
        
    }
    
    @objc func update_biography(){
        
        print("update_biography EVENT")
        if let biography = current_user["biography"] as? String{
            Biography_Label.text = biography
            Biography_Label.isHidden = false
            AddBiography_Button.isHidden = true
        }else{
            Biography_Label.isHidden = true
            AddBiography_Button.isHidden = false
        }
    }
    
    @objc func update_user_info(){
        
        print("update_user_info EVENT")
        reload_user_data()
    }

    
    // Initial load posts (objc)
    @objc func objc_load_posts(){
        cached_posts_image.removeAll(keepingCapacity: false)
        load_posts(offset: 0, limit: offset + 1)
    }
    // Initial load posts
    func load_posts(offset: Int, limit: Int){
        if(is_posts_loading == true){
            return
        }
        print("LOAD POSTS TRIGGERED")
        print("OFFSET:", offset, " LIMIT:", limit)
        is_posts_loading = true
        guard let user_id = current_user["user_id"] as? String else{
            return
        }
        
        posts.removeAll(keepingCapacity: false)
        
        helper.api_get_posts(user_id: user_id, limit: limit, offset: offset, target_view: self, on_complete: {result in
            
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
                
                self.offset = self.posts.count
                self.tableView.reloadData()
                self.is_posts_loading = false
                
                
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
        guard let user_id = current_user["user_id"] as? String else{
            is_posts_loading = false
            return
        }
        
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
    
    // Load friends
    @objc func load_friends(){
        print("load_friends")
        guard let current_user_id = current_user["user_id"] as? String else{
            return
        }
        
        helper.api_get_friends(user_id: current_user_id, offset: 0, limit: 6, target_view: self, on_complete: {result in
            
            print("load_friends result", result)
            
            if(result["status"] as! Int == 1){
                
                let content = result["content"] as! NSDictionary
                guard let res_friends = content["friends"] as? [NSDictionary] else{
                    print("[friends] index not exists")
                    return
                }
                
                self.friends.removeAll(keepingCapacity: false)
                
                print("FRIENDS ARRAY", res_friends)
                
                if(res_friends.count > 0){
                    
                    for friend in res_friends {
                        
                        let user_id = self.helper.cast(value: friend["real_user_id"])
                        let first_name = self.helper.cast(value: friend["first_name"])
                        let last_name = self.helper.cast(value: friend["last_name"])
                        let avatar_url = self.helper.cast(value: friend["avatar"])
                        
                        let data_obj = User_Data()
                        data_obj.id = user_id
                        data_obj.avatar_url = avatar_url
                        data_obj.first_name = first_name
                        data_obj.last_name = last_name
                        data_obj.fullname = "\(first_name.capitalized) \(last_name.capitalized)"

                        
                        self.friends.append(data_obj)

                    }
                
                }
                
                self.tableView.reloadData()
 
            }else{
                print("STATUS ERROR")
            }
            
        })
    }
    
    
    func reload_user_data(){
        
        print("RELOAD USER", current_user)
        
        // Full name
        if let first_name = current_user["first_name"] as? String{
            if let last_name = current_user["last_name"] as? String{
                Fullname_Label.text = "\(first_name.capitalized) \(last_name.capitalized)"
            }
        }
        // Bio
        if let biography = current_user["biography"] as? String{
            Biography_Label.text = biography
            Biography_Label.isHidden = false
            AddBiography_Button.isHidden = true
        }else{
            Biography_Label.isHidden = true
            AddBiography_Button.isHidden = false
        }
        // Cover
        print("ON LOAD COVER PART")
        if let cover_url = current_user["cover"] as? String{
            if(cover_url.isEmpty == false){
                print("COVER URL NOT EMPTY", cover_url)
                let url = URL(string: cover_url)!
                
                helper.download_image(url: url, on_complete: {(image) in
                    self.Cover_View.image = image
                    self.is_cover = true
                    print("COVER RETRIEVED")
                })
            }else{
                self.is_cover = false
                self.Cover_View.image = UIImage(named: settings.default_cover)
            }
        }
        print("ON LOAD AVATAR PART")
        // Avatar
        if let avatar_url = current_user["avatar"] as? String{
            if(avatar_url.isEmpty == false){
                print("AVATAR URL NOT EMPTY", avatar_url)
                let url = URL(string: avatar_url)!
                
                if(current_user_avatar == nil){
                    // No stored Avatar
                    print("NO STORED AVATAR")
                    helper.download_image(url: url, on_complete: {(image) in
                        self.Avatar_View.image = image
                        current_user_avatar = image
                        self.is_avatar = true
                        print("AVATAR RETRIEVED")
                    })
                    
                }else{
                    // Stored Avatar exists
                    print("STORED AVATAR:", current_user_avatar!)
                    self.Avatar_View.image = current_user_avatar
                    self.is_avatar = true
                }
                
                
            }else{
                self.Avatar_View.image = UIImage(named: settings.default_avatar)
                self.is_avatar = false
            }
        }
    }
    
    // not used
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized: print("Access is granted by user")
        case .notDetermined: PHPhotoLibrary.requestAuthorization({
            (newStatus) in print("status is \(newStatus)")
            if newStatus == PHAuthorizationStatus.authorized {
                // Do here
                print("success")
            }
        })
        case .restricted:  print("User do not have access to photo album.")
        case .denied:  print("User has denied the permission.")
        }
    }
    
    /* OTHER END */
    /***************** FUNCS END *****************/
}
