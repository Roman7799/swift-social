//
//  CommentsVC.swift
//  social
//
//  Created by Geolance on 7/11/19.
//  Copyright © 2019 Geolance. All rights reserved.
//

import UIKit

class CommentsVC: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource{
    
    let helper = Helper()
    let settings = Settings()
    
    //var texts = String()
    //var avatars = UIImage()
    //var fullnames = String()
    //var comments = [["id": String(), "user_id": String(), "avatar": UIImage(), "fullname": String(), "text": String()]]
    
    var comments = [Comment]()
    var comments_limit = 10
    var comments_offset = 0
    var is_loading = false

    var stored_user_id = String()
    var stored_post_id = Int()
    
    @IBOutlet weak var Avatar: UIImageView!
    @IBOutlet weak var Fullname: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var Post_Image: UIImageView!
    var stored_avatar = UIImage()
    var stored_fullname = String()
    var stored_date = String()
    
    @IBOutlet weak var Post_Container: UIView!
    @IBOutlet weak var Post_Text: UILabel!
    var stored_post_text = String()
    var stored_post_image = UIImage()
    
    @IBOutlet weak var Comments_Table: UITableView!
    
    @IBOutlet weak var Comment_Input: UITextView!
    @IBOutlet weak var Comment_Input_bottom: NSLayoutConstraint!
    @IBOutlet weak var Comment_Input_height: NSLayoutConstraint!
    var cached_Comment_Input_bottom = CGFloat()
    var keyboard_is_hidden = true
    
    


    override func viewDidLoad() {
        super.viewDidLoad()
        cached_Comment_Input_bottom = Comment_Input_bottom.constant

        Avatar.image = stored_avatar
        Fullname.text = stored_fullname
        Date.text = helper.date_string_convert(date_string: stored_date, from_format: settings.date_format_server, to_format: settings.date_format_post_front)
        
        Post_Text.text = stored_post_text
        print("load post in comments", stored_post_text)
        if(stored_post_image.size.width == 0 ){
            Post_Image.removeFromSuperview()
            Post_Container.frame.size.height -= Post_Image.frame.height
        }else{
            Post_Image.image = stored_post_image
        }
    
        load_comments(offset: comments_offset, limit: comments_limit)
        
        
        /* OBSERVERS */
        
        // on keyboard will show
        // 10.1
        //NotificationCenter.default.addObserver(self, selector: #selector(on_keyboard_will_show(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        // 9.2
        NotificationCenter.default.addObserver(self, selector: #selector(on_keyboard_will_show(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        
        // on keyboard will hide
        // 10.1
        //NotificationCenter.default.addObserver(self, selector: #selector(on_keyboard_will_hide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        // 9.2
        NotificationCenter.default.addObserver(self, selector: #selector(on_keyboard_will_hide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        /* OBSERVERS END */
        
        // Dynamic table cell height
        // 10.1
        //Comments_Table.rowHeight = UITableView.automaticDimension
        // 9.2
        Comments_Table.rowHeight = UITableViewAutomaticDimension
        Comments_Table.estimatedRowHeight = 70
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        helper.configure_avatar_post(element: Avatar)
        helper.style_border_radius(element: Comment_Input, value: 10)
        
        print("LAYOUT")
        view.layoutIfNeeded()
    }
    
    // Pre last func
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        // OBSERVERS REMOVE
        
        // on keyboard will show (remove event)
        // 10.1
        //NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        // 9.2
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        // on keyboard will hide (remove event)
        // 10.1
        //NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        // 9.2
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // OBSERVERS REMOVE END
    }
    
    /* Table Data */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return comments.count
    }
    
    // Load and display table view
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
     {
        print("COMMENTS_TABLE_VIEW TRIGGERED")
        let cell = tableView.dequeueReusableCell(withIdentifier: "TblCell_Comment", for: indexPath) as! TblCell_Comment

        
        cell.id = String(comments[indexPath.row].id)
        cell.user_id = comments[indexPath.row].user_id
        //cell.Comment_Avatar.image = comments[indexPath.row].avatar
        cell.Comment_Fullname.text = comments[indexPath.row].fullname
        cell.Comment_Text.text = comments[indexPath.row].text
        
        print("COMMENT AVATAR URL", comments[indexPath.row].avatar_url)
        if(comments[indexPath.row].avatar_url.isEmpty == false){

            print("COMMENT AVATAR IMAGE", comments[indexPath.row].avatar)
            if(comments[indexPath.row].avatar_is_cached == true){
                // Use cached
                print("COMMENT AVATAR USE CACHED")
                cell.Comment_Avatar.image = comments[indexPath.row].avatar
            }else{
                // DL
                print("COMMENT AVATAR USE DL")
                let url = URL(string: comments[indexPath.row].avatar_url)!
                
                helper.download_image(url: url, on_complete: {image in
                    self.comments[indexPath.row].avatar = image // Cache
                    self.comments[indexPath.row].avatar_is_cached = true
                    cell.Comment_Avatar.image = image
                    
                }, on_fail: {
                    // Use default
                    let image = UIImage(named: self.settings.default_avatar) ?? UIImage()
                    self.comments[indexPath.row].avatar = image // Cache
                    self.comments[indexPath.row].avatar_is_cached = true
                    cell.Comment_Avatar.image = image
                })
            }
            
        }else{
            let image = UIImage(named: self.settings.default_avatar) ?? UIImage()
            self.comments[indexPath.row].avatar = image // Cache
            self.comments[indexPath.row].avatar_is_cached = true
            cell.Comment_Avatar.image = image
        }
        
        
        return cell
     }
    
    // Allow to edit cells
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Allow comment editing only for own comments
        if(comments[indexPath.row].user_id == current_user["user_id"] as! String){
           return true
        }else{
           return false
        }
    }
    
    // Delete row
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // enable delete action of the cell - swipe to delete
        if editingStyle == .delete {
            
            // here cell / comment gets deleted
            guard let current_user_id = current_user["user_id"] as? String else{
                return
            }
            let comment_id = String(comments[indexPath.row].id)
            let user_id = String(comments[indexPath.row].user_id)
            
            helper.api_delete_comment(current_user_id: current_user_id, comment_id: comment_id, user_id: user_id, target_view: self, on_complete: {result in
                
                self.comments.remove(at: indexPath.row)
                self.Comments_Table.beginUpdates()
                self.Comments_Table.deleteRows(at: [indexPath], with: .automatic)
                self.Comments_Table.endUpdates()
            })
            
            
        }
    }
    
    /* Table Data END */

   
    /****************** EVENTS *******************/
    /* INTERACTIONS */
    
    // on cancel (return)
    @IBAction func Back_clicked(_ sender: Any) {
        // Return to prev VC
        navigationController?.popViewController(animated: true)
    }
    
    // on Comment_Send button clicked
    @IBAction func Comment_Send_clicked(_ sender: UIButton) {
        guard let current_user_id = current_user["user_id"] as? String,
              var text = Comment_Input.text,
              let first_name = current_user["first_name"] as? String,
              let last_name = current_user["last_name"] as? String
            else{
            print("ERROR: CANT GET VARS")
            return
        }
        text = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if(text.isEmpty){
            helper.show_alert_ok(title: "Error", message: "Empty message not allowed", target_view: self)
            return
        }
        
        //let post_id =
        let fullname = "\(first_name.capitalized) \(last_name.capitalized)"

        

        // Clear input
        Comment_Input.text = ""
        textViewDidChange(Comment_Input)
        
        helper.api_create_comment(current_user_id: current_user_id, post_id: stored_post_id, user_id: stored_user_id, text: text, target_view: self, on_complete: {result in
            print("api_create_comment END:", result)
            
            if(result["status"] as! Int == 1){
                let content = result["content"] as! NSDictionary
                
                let index =  0 //self.comments.count //to end
                self.comments.insert(Comment(), at: index)
                self.comments[index].id = String(content["comment_id"] as! Int)
                self.comments[index].user_id = current_user_id
                self.comments[index].fullname = fullname
                self.comments[index].avatar_url = current_user["avatar"] as! String
                self.comments[index].avatar = current_user_avatar ?? UIImage(named: self.settings.default_avatar)!
                self.comments[index].avatar_is_cached = true
                self.comments[index].text = text
                
                // Update TableView
                self.Comments_Table.beginUpdates()
                let index_path = IndexPath(row: index, section: 0)
                self.Comments_Table.insertRows(at: [index_path], with: .automatic)
                self.Comments_Table.endUpdates()
                
                // Scroll to index
                self.Comments_Table.scrollToRow(at: index_path, at: .bottom, animated: true)
            }
        })
    }
    
    /* INTERACTIONS END */
    /* HOOKS */
    
    // on keyboard will show
    @objc func on_keyboard_will_show(notification: Notification){
        if(keyboard_is_hidden){
            // 10.1
            //if let keyboard_size = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            // 9.2
            if let keyboard_size = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
            {
                print("Keyb height = \(keyboard_size.height)")
                Comment_Input_bottom.constant += keyboard_size.height
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.layoutIfNeeded()
                })
            }
            keyboard_is_hidden = false
        }
    }
    
    // on keyboard will hide
    @objc func on_keyboard_will_hide(notification: Notification){
        Comment_Input_bottom.constant = cached_Comment_Input_bottom
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
        keyboard_is_hidden = true
    }
    
    // on Comment_Input change
    func textViewDidChange(_ textView: UITextView) {
        
        // This piece of code resizes textfield to max height of content when typing
        let new_size = textView.sizeThatFits(CGSize.init(width: textView.frame.width, height: CGFloat(MAXFLOAT)))
        textView.frame.size = CGSize.init(width: CGFloat(fmaxf(Float(new_size.width), Float(textView.frame.width))), height: new_size.height)  // difficult T_T  I think it is possible to refactor this code. Is fmax really needed?
        Comment_Input_height.constant = new_size.height
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
        // End
        
    }
    
    /* HOOKS END */
    /**************** EVENTS END *****************/
    /****************** VISUALS ******************/
    /**************** VISUALS END ****************/
    /******************* FUNCS *******************/
    /* OTHER */
    
    // Load comments array and launch table view reload
    func load_comments(offset: Int, limit: Int){
        if(is_loading == true){
            return
        }
        is_loading = true
        
        guard let user_id = current_user["user_id"] as? String else{
            is_loading = false
            return
        }
        
        helper.api_get_posts_comments_by_post_id(current_user_id: user_id, post_id: stored_post_id, offset: offset, limit: limit, target_view: self, on_complete: {result in
            print("api_get_posts_comments_by_post_id END: ", result)
            
            if(result["status"] as! Int == 1){
                
                let content = result["content"] as! NSDictionary
                let comments = content["comments"] as! [NSDictionary]
                
                self.comments_offset = comments.count
                
                for content_comment in comments{
                    //let content_comment = content_comment as! NSDictionary
                    let id = content_comment["id"] as! String
                    let user_id = content_comment["user_id"] as! String
                    let avatar_url = content_comment["avatar"] as! String
                    let first_name = content_comment["first_name"] as! String
                    let last_name = content_comment["last_name"] as! String
                    let fullname = "\(first_name.capitalized) \(last_name.capitalized)"
                    let text = content_comment["text"] as! String
                    let date_created = content_comment["date_created"] as! String
                    
                    let tmp = Comment()
                    tmp.id = id
                    tmp.user_id = user_id
                    tmp.fullname = fullname
                    tmp.text = text
                    tmp.avatar_url = avatar_url
                    tmp.date_created = date_created
                    self.comments.append(tmp)
                }
                
                self.Comments_Table.reloadData()
                
                // Scroll to last comment
                if(self.comments.count > 0){
                    let indexPath = IndexPath(row: self.comments.count - 1, section: 0)
                    self.Comments_Table.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
                
                
                self.is_loading = false
            }else{
                // bad status
                self.is_loading = false
            }
        })
    }

    
    /* OTHER END */
    /***************** FUNCS END *****************/
    
}
