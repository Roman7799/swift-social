//
//  HomeVC.swift
//  social
//
//  Created by Ancient on 7/4/19.
//  Copyright © 2019 Ancient. All rights reserved.
//
// TODO:
// [TDDIL] - Delete image from server

import UIKit

class HomeVC: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let helper = Helper()
    let settings = Settings()
    
    @IBOutlet weak var Cover_View: UIImageView!
    @IBOutlet weak var Avatar_View: UIImageView!
    @IBOutlet weak var Fullname_Label: UILabel!
    @IBOutlet weak var AddBiography_Button: UIButton!
    @IBOutlet weak var Biography_Label: UILabel!
    
    var is_cover = false
    var is_avatar = false
    var image_view_tapped = ""
    var default_cover = "image_placeholder.png"
    var default_avatar = "image_placeholder.png"
    var cached_avatar: UIImage? = nil
    var cached_posts_image = [UIImage]()
    
    // Posts
    var posts = [NSDictionary]() // [NSDictionary?]() ? - need?
    var offset = 0
    var limit = 10
    var is_posts_loading = false
    var liked = [Int]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        if let cover_url = current_user["cover"] as? String{
            if(cover_url.isEmpty == false){
                let url = URL(fileURLWithPath: cover_url)
                
                DispatchQueue.main.async {
                    do{
                        let data = try Data(contentsOf: url)
                        if let image = UIImage(data: data){
                            self.Cover_View.image = image
                        }
                    }catch{
                        print("CANT GET COVER IMAGE. URL:", url)
                    }
                }
            }
        }
        // Avatar
        if let avatar_url = current_user["avatar"] as? String{
            if(avatar_url.isEmpty == false){
                let url = URL(fileURLWithPath: avatar_url)
                
                DispatchQueue.main.async {
                    do{
                        let data = try Data(contentsOf: url)
                        if let image = UIImage(data: data){
                            self.Avatar_View.image = image
                            current_user_avatar = image
                        }
                    }catch{
                        print("CANT GET AVATAR IMAGE. URL:", url)
                    }
                }
            }
        }
        // current_user END
        
        // load posts (init)
        load_posts(offset: offset, limit: limit)
        
        // Add Event Observers
        // on Biography updated
        NotificationCenter.default.addObserver(self, selector: #selector(update_biography), name: NSNotification.Name(rawValue: "update_biography"), object: nil)
        
        // on User info updated
        NotificationCenter.default.addObserver(self, selector: #selector(update_user_info), name: NSNotification.Name(rawValue: "update_user_info"), object: nil)
        
        // on new post created
        NotificationCenter.default.addObserver(self, selector: #selector(objc_load_posts), name: NSNotification.Name(rawValue: "post_created"), object: nil)
        
    
    }

    // MARK: - Table view data source

/*
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 0
    }
 */

    // Rows count
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    // Display of Table (posts) (initial)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
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
                        let url = URL(fileURLWithPath: avatar_url)
                        
                        DispatchQueue.main.async {
                            do{
                                let data = try Data(contentsOf: url)
                                if let image = UIImage(data: data){
                                    self.cached_avatar = image // Cache
                                    cell.Avatar.image = image
                                }
                            }catch{
                                print("CANT GET AVATAR IMAGE. URL:", url)
                            }
                        }
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
            
            return cell
            
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
                        let url = URL(fileURLWithPath: avatar_url)
                        
                        DispatchQueue.main.async {
                            do{
                                let data = try Data(contentsOf: url)
                                if let image = UIImage(data: data){
                                    self.cached_avatar = image
                                    cell.Avatar.image = image
                                }
                            }catch{
                                print("CANT GET AVATAR IMAGE. URL:", url)
                            }
                        }
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
                    let url = URL(fileURLWithPath: post_image_url)
                    
                    if(posts.count != cached_posts_image.count){
                        // Download and cache
                        DispatchQueue.main.async {
                            do{
                                let data = try Data(contentsOf: url)
                                if let image = UIImage(data: data){
                                    self.cached_posts_image.append(image)
                                    cell.Post_Image.image = image
                                }
                            }catch{
                                print("CANT GET POST IMAGE. URL:", url)
                            }
                        }
                    }else{
                        // Use cached
                        DispatchQueue.main.async {
                            cell.Post_Image.image = self.cached_posts_image[indexPath.row]
                        }
                    }
                    
                    
                }else{
                    //cell.Avatar.image = UIImage(named: self.settings.default_avatar)
                }
            }else{
                //cell.Avatar.image = UIImage(named: self.settings.default_avatar)
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
            
            return cell
        } // Post type Image END
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
    
    // on Like button clicked
    @IBAction func Like_clicked(_ Like: UIButton) {
        
        guard let user_id = current_user["user_id"] as? String else{
            print("ERROR: CANT GET USER ID")
            return
        }
        
        let row_index = Like.tag
        
        guard let post_id = posts[row_index]["id"] as? Int else{
            print("ERROR: CANT GET POST ID")
            return
        }
        
        var action = ""
        if(liked[row_index] == 1){
            action = "delete"
            Like.setImage(UIImage(named: "unlike.png"), for: .normal)
        }else{
            action = "create"
            Like.setImage(UIImage(named: "like.png"), for: .normal)
        }
        
        helper.ani_pop(element: Like)
        
        helper.api_like(current_user_id: user_id, post_id: post_id, user_id: user_id, action: "create", target_view: self, on_complete: {result in
            print("api_like END:", result)
            
            if(result["status"] as! String == "1"){
                
                if(action == "delete"){
                    self.liked[row_index] = Int()
                    
                }else{
                    self.liked[row_index] = 1
                }
            }else{
                // If failed return images
                if(action == "delete"){
                    Like.setImage(UIImage(named: "like.png"), for: .normal)
                }else{
                    Like.setImage(UIImage(named: "unlike.png"), for: .normal)
                }
            }
        })
        
        
        
    }
    
    /* INTERACTIONS END */
    /* HOOKS */
    
    // Triggers after image was picked from library
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let user_id = Int(current_user["user_id"] as! String)!
        let image = info[.editedImage] as? UIImage
        if(image == nil){
            print("image IS nil")
            return
        }
        
        if(self.image_view_tapped == "cover"){
            Cover_View.image = image
            
            helper.api_upload_image_of_type(user_id: user_id, type: "cover", image: image!, target_view: self, on_complete: {result in
                print("UPLOAD FINISHED")
                
                current_user["cover"] = result.value(forKey: "content.image_url")
                UserDefaults.standard.set(current_user, forKey: "current_user")
            })
        }else if(self.image_view_tapped == "avatar"){
            Avatar_View.image = image
            current_user_avatar = image!
            
            helper.api_upload_image_of_type(user_id: user_id, type: "avatar", image: image!, target_view: self, on_complete: {result in
                print("UPLOAD FINISHED")
                
                current_user["avatar"] = result.value(forKey: "content.image_url")
                UserDefaults.standard.set(current_user, forKey: "current_user")
            })
        }
        
        dismiss(animated: true, completion: {
            print("IMAGE PICKER DISMISSED")
            if(self.image_view_tapped == "cover"){
                self.is_cover = true
            }else if(self.image_view_tapped == "avatar"){
                self.is_avatar = true
            }
        })
    }
    
    
    // on scroll Load more posts
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if(tableView.contentOffset.y - tableView.contentSize.height + 60 > -tableView.frame.height && is_posts_loading == false)
        {
            load_more_posts(offset: self.offset, limit: self.limit)
        }
        
    }
    
    // Display loaded posts (load_more_posts)
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
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
                        let url = URL(fileURLWithPath: avatar_url)
                        
                        DispatchQueue.main.async {
                            do{
                                let data = try Data(contentsOf: url)
                                if let image = UIImage(data: data){
                                    self.cached_avatar = image // Cache
                                    cell.Avatar.image = image
                                }
                            }catch{
                                print("CANT GET AVATAR IMAGE. URL:", url)
                            }
                        }
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
                        let url = URL(fileURLWithPath: avatar_url)
                        
                        DispatchQueue.main.async {
                            do{
                                let data = try Data(contentsOf: url)
                                if let image = UIImage(data: data){
                                    self.cached_avatar = image
                                    cell.Avatar.image = image
                                }
                            }catch{
                                print("CANT GET AVATAR IMAGE. URL:", url)
                            }
                        }
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
                    let url = URL(fileURLWithPath: post_image_url)
                    
                    if(posts.count != cached_posts_image.count){
                        // Download and cache
                        DispatchQueue.main.async {
                            do{
                                let data = try Data(contentsOf: url)
                                if let image = UIImage(data: data){
                                    self.cached_posts_image.append(image)
                                    cell.Post_Image.image = image
                                }
                            }catch{
                                print("CANT GET POST IMAGE. URL:", url)
                            }
                        }
                    }else{
                        // Use cached
                        DispatchQueue.main.async {
                            cell.Post_Image.image = self.cached_posts_image[indexPath.row]
                        }
                    }
                    
                    
                }else{
                    //cell.Avatar.image = UIImage(named: self.settings.default_avatar)
                }
            }else{
                //cell.Avatar.image = UIImage(named: self.settings.default_avatar)
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

        
    }
    
    // Prepare and send data for Segue (show)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "CommentsVC"){
            let index_row = (sender as! UIButton).tag
            let index_path = IndexPath(item: index_row, section: 0)
            let vc = segue.destination as! CommentsVC
            
            vc.stored_post_id = posts[index_row]["id"] as! Int
            vc.stored_avatar = Avatar_View.image!
            vc.stored_fullname = Fullname_Label.text!
            vc.stored_date = posts[index_row]["date"] as! String as String
            vc.stored_post_text = posts[index_row]["text"] as! String as String
            if let cell = tableView.cellForRow(at: index_path) as? TblCell_Post_Image{
                vc.stored_post_image = cell.Post_Image.image!
            }
          
        }
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
            print("ACTION DELETE")
            
            if(self.image_view_tapped == "cover"){
                // Write delete logic [TDDIL]
                self.Cover_View.image = UIImage(named: self.settings.default_cover)
                self.is_cover = false
            }else if(self.image_view_tapped == "avatar"){
                // Write delete logic [TDDIL]
                self.Avatar_View.image = UIImage(named: self.settings.default_avatar)
                self.is_avatar = false
                current_user_avatar = UIImage(named: self.settings.default_avatar)!
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
    
    func show_image_picker(source: UIImagePickerController.SourceType){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = source
        present(picker, animated: true, completion: nil)
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
        load_posts(offset: 0, limit: offset + 1)
    }
    // Initial load posts
    func load_posts(offset: Int, limit: Int){
        guard let user_id = current_user["user_id"] as? String else{
            return
        }
        
        helper.api_get_posts(user_id: user_id, limit: limit, offset: offset, target_view: self, on_complete: {result in
            if(result["status"] as! String == "1"){
                print("GET POSTS RESULT", result)
                guard let new_posts = result.value(forKey: "content.posts") as? [NSDictionary] else{
                    return
                }
                self.posts = new_posts
                self.offset = new_posts.count
                self.liked.removeAll(keepingCapacity: false) // clean likes array
                
                for post in self.posts {
                    if(post["liked"] is NSNull){
                        self.liked.append(Int())
                    }else{
                        self.liked.append(1)
                    }
                }
                
                self.tableView.reloadData()
                
            }else{
                print("STATUS ERROR")
            }
        })
    }
    
    // Load more posts
    func load_more_posts(offset: Int, limit: Int){
        is_posts_loading = true
        guard let user_id = current_user["user_id"] as? String else{
            is_posts_loading = false
            return
        }
        
        helper.api_get_posts(user_id: user_id, limit: limit, offset: offset, target_view: self, on_complete: {result in
            if(result["status"] as! String == "1"){
                print("GET POSTS RESULT", result)
                guard let new_posts = result.value(forKey: "content.posts") as? [NSDictionary] else{
                    self.is_posts_loading = false
                    return
                }
                self.posts += new_posts
                self.offset += new_posts.count
                //self.tableView.reloadData()
                
                // Append posts to table view
                self.tableView.beginUpdates()
                for i in 0 ..< self.posts.count{
                    let section_index = self.tableView.numberOfSections - 1 // Column index?
                    let row_index = self.tableView.numberOfRows(inSection: section_index)
                    let path_to_last_row = IndexPath(row: row_index + i, section: section_index)
                    self.tableView.insertRows(at: [path_to_last_row], with: .fade)
                }
                self.tableView.endUpdates()
                // Append posts to table view END
                self.is_posts_loading = false
                
            }else{
                self.is_posts_loading = false
                print("STATUS ERROR")
            }
        })
    }
    
    
    func reload_user_data(){
        
        // First name
        if let first_name = current_user["first_name"] as? String{
            if let last_name = current_user["last_name"] as? String{
                Fullname_Label.text = "\(first_name.capitalized) \(last_name.capitalized)"
            }
        }
        
        // Avatar
        if let avatar_url = current_user["avatar"] as? String{
            if(avatar_url.isEmpty == false){
                let url = URL(fileURLWithPath: avatar_url)
                
                DispatchQueue.main.async {
                    do{
                        let data = try Data(contentsOf: url)
                        if let image = UIImage(data: data){
                            self.Avatar_View.image = image
                            current_user_avatar = image
                        }
                    }catch{
                        print("CANT GET AVATAR IMAGE. URL:", url)
                    }
                }
            }else{
                self.Avatar_View.image = UIImage(named: settings.default_avatar)
                current_user_avatar = UIImage(named: settings.default_avatar)!
            }
        }
        
        // Cover
        if let cover_url = current_user["cover"] as? String{
            if(cover_url.isEmpty == false){
                let url = URL(fileURLWithPath: cover_url)
                
                DispatchQueue.main.async {
                    do{
                        let data = try Data(contentsOf: url)
                        if let image = UIImage(data: data){
                            self.Cover_View.image = image
                        }
                    }catch{
                        print("CANT GET COVER IMAGE. URL:", url)
                    }
                }
            }else{
                self.Cover_View.image = UIImage(named: default_cover)
            }
        }
    }
    /* OTHER END */
    /***************** FUNCS END *****************/
}
