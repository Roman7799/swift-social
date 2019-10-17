//
//  SearchVC.swift
//  social
//
//  Created by Denis Vesnin on 7/26/19.
//  Copyright © 2019 Geolance. All rights reserved.
//

import UIKit

class SearchVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, Friend_Request_Delegate {
    
    
    func Exec_Friend_Request(with action: String, status: Int, from cell: UITableViewCell)
    {
        print("Exec_Friend_Request", action)
        
        // getting indexPath of the cell
        guard let user_id = current_user["user_id"] as? String,
              let indexPath = Requests_Table.indexPath(for: cell) else
        {
            return
        }
        let friend_id = friend_requests[indexPath.row].id
        
        print(user_id, indexPath)
        
        if action == "confirm" {
            //friendshipStatus.append(3)
            helper.api_confirm_friend_request(current_user_id: user_id, friend_id: friend_id, target_view: self, on_complete: {result in
                
                if(result["status"] as! Int == 1){
                    //self.users[index].is_friend_requested = true
                    //let image = UIImage(named: "friend")
                    //Friend_button.setImage(image, for: .normal)
                    //Friend_button.tintColor = self.settings.color_1
                    
                }else{
                    self.helper.show_alert_ok(title: "Error", message: result["error"] as! String, target_view: self)
                }
            })
            
            
        } else if(action == "decline") {
            //friendshipStatus.append(0)
            helper.api_decline_friend_request(current_user_id: user_id, friend_id: friend_id, target_view: self, on_complete: {result in
                
                if(result["status"] as! Int == 1){
                    //self.users[index].is_friend_requested = true
                    //let image = UIImage(named: "friend")
                    //Friend_button.setImage(image, for: .normal)
                    //Friend_button.tintColor = self.settings.color_1
                    
                }else{
                    self.helper.show_alert_ok(title: "Error", message: result["error"] as! String, target_view: self)
                }
            })
            
        }
        
    }
    
    
    
    @IBOutlet weak var Friends_Table: UITableView!
    @IBOutlet weak var Requests_Table: UITableView!
    
    
    let settings = Settings()
    let helper = Helper()
    
    var Search_Bar = UISearchBar()
    
    var users = [User_Data]()
    var search_limit = 100
    var search_offset = 0
    
    var friend_requests = [User_Data]()
    var requests_limit = 100
    var requests_offset = 0
    
    var friend_recommended = [User_Data]()
    
    var is_loading = false
    
    var requestedHeaders = ["FRIEND REQUESTS", "PEOPLE YOU MAY KNOW"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /* SEARCH BAR BEGIN */
        // creating search bar and configuring it
        Search_Bar.showsCancelButton = false
        Search_Bar.placeholder = "Search"
        Search_Bar.delegate = self
        Search_Bar.searchBarStyle = .minimal
        Search_Bar.tintColor = .black
        
        // accessing childView - textField inside of the searchBar
        let Search_Bar_Input = Search_Bar.value(forKey: "searchField") as? UITextField
        Search_Bar_Input?.textColor = .black
        Search_Bar_Input?.tintColor = .black
        
        // insert searchBar into navigationBar
        self.navigationItem.titleView = Search_Bar
        /* SEARCH BAR END */
        
        /*
        Friends_Table.rowHeight = UITableViewAutomaticDimension
        Friends_Table.estimatedRowHeight = 120
        */
        
        // Add event listeners
        NotificationCenter.default.addObserver(self, selector: #selector(load_search), name: Notification.Name(rawValue: "friend"), object: nil) // From GuestVC->Friend_clicked
        NotificationCenter.default.addObserver(self, selector: #selector(load_frient_requests), name: Notification.Name(rawValue: "friend"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(load_friend_recommended), name: Notification.Name(rawValue: "friend"), object: nil)
        //
        
        load_frient_requests()
        load_friend_recommended()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.Friends_Table.reloadData()
        
    }
    
    // total numb of sections in the tableView
    func numberOfSections(in tableView: UITableView) -> Int {
        if(tableView == Friends_Table){
            return 1
        }else{
            print("NUMBER OF SECTIONS", requestedHeaders.count)
            return requestedHeaders.count
        }
   
    }
    
    // Table number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(tableView == Friends_Table){
            print("TABLE COUNT", users.count)
            return users.count
        }else if(tableView == Requests_Table){
            
            if section == 0 {
                print("NUMBER OF ROWS IN SECTION 0", friend_requests.count)
                return friend_requests.count
            }else{
                print("NUMBER OF ROWS IN SECTION 0", friend_recommended.count)
                return friend_recommended.count
            }
            
        }else{
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    // section header of cells (top-left corner of table)
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // for Requests_Table only show headers
        if tableView == Requests_Table {
            
            switch section{
                case 0:
                if self.tableView(tableView, numberOfRowsInSection: section) > 0 {
                    return requestedHeaders[section]
                }
                
            case 1:
                if self.tableView(tableView, numberOfRowsInSection: section) > 0 {
                    return requestedHeaders[section]
                }
                
            default:
                return nil
            }
        }
        
        return nil
    }
    
    // configur-n of header / section
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        // accessing header
        let header = view as! UITableViewHeaderFooterView
        
        // change text color and font
        header.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 12)!
        header.textLabel?.textColor = UIColor.darkGray
        
    }
    
    
    // Allow to edit cells
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Table Cell Data and Rendering
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        if(tableView == Friends_Table){
            print("TABLE RENDER SEARCH")
            
            let cell = Friends_Table.dequeueReusableCell(withIdentifier: "TblCell_Search_User", for: indexPath) as! TblCell_Search_User
            
            print("id", users[indexPath.row].id)
            cell.id = users[indexPath.row].id
            print("fullname", users[indexPath.row].fullname)
            cell.Fullname.text = users[indexPath.row].fullname
            
            // Avatar
            print("avatar_url", users[indexPath.row].avatar_url)
            if(users[indexPath.row].avatar_url.isEmpty == false){
                
                if(users[indexPath.row].avatar_is_cached == true){
                    // Use cached
                    if(self.users.indices.contains(indexPath.row)){
                        cell.Avatar.image = users[indexPath.row].avatar
                    }

                }else{
                    // DL
                    print("COMMENT AVATAR USE DL")
                    let url = URL(string: users[indexPath.row].avatar_url)!
                    
                    helper.download_image(url: url, on_complete: {image in
                        if(self.users.indices.contains(indexPath.row)){
                            self.users[indexPath.row].avatar = image // Cache
                            self.users[indexPath.row].avatar_is_cached = true
                            DispatchQueue.main.async {
                                cell.Avatar.image = image
                            }
                        }
                        
                    }, on_fail: {
                        // Use default
                        if(self.users.indices.contains(indexPath.row)){
                            let image = UIImage(named: self.settings.default_avatar) ?? UIImage()
                            self.users[indexPath.row].avatar = image // Cache
                            self.users[indexPath.row].avatar_is_cached = true
                            cell.Avatar.image = image
                        }
                        
                    })
                }
                
            }else{
                if(self.users.indices.contains(indexPath.row)){
                    let image = UIImage(named: self.settings.default_avatar) ?? UIImage()
                    self.users[indexPath.row].avatar = image // Cache
                    self.users[indexPath.row].avatar_is_cached = true
                    cell.Avatar.image = image
                }
            }
            // Avatar END
            
            
            // Allow Friend Button
            if self.users[indexPath.row].allow_friends != "1" {
                cell.Friend.isHidden = true
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.Friend.isHidden = false
                cell.accessoryType = .none
            }
            
            // Friend Button
            switch self.users[indexPath.row].frindship_status {
            case 3:
                print("3")
                let image = UIImage(named: "friends")
                cell.Friend.setImage(image, for: .normal)
                cell.Friend.tintColor = self.settings.color_1
                break
            case 2:
                print("2")
                let image = UIImage(named: "respond")
                cell.Friend.setImage(image, for: .normal)
                cell.Friend.tintColor = self.settings.color_1
                break
            case 1:
                print("1")
                let image = UIImage(named: "request")
                cell.Friend.setImage(image, for: .normal)
                cell.Friend.tintColor = self.settings.color_1
                break
            case 0:
                print("0")
                let image = UIImage(named: "unfriend")
                cell.Friend.setImage(image, for: .normal)
                cell.Friend.tintColor = UIColor.darkGray
                break
            default:
                let image = UIImage(named: "unfriend")
                cell.Friend.setImage(image, for: .normal)
                cell.Friend.tintColor = UIColor.darkGray
                print("World will end soon...")
                break
            }
            
            
            cell.Friend.tag = indexPath.row
            
            return cell
            
            
            
            
        }else if(tableView == Requests_Table){
            
            if(indexPath.section == 0){
                print("TABLE RENDER REQUESTS SECTION 0")
                
                let cell = Requests_Table.dequeueReusableCell(withIdentifier: "TblCell_Friend_Request", for: indexPath) as! TblCell_Friend_Request
                
                print("id", friend_requests[indexPath.row].id)
                
                // creating delegate relations from the cell to current vc in order to access protocols of the delegate class
                cell.delegate = self
                
                cell.id = friend_requests[indexPath.row].id
                print("fullname", friend_requests[indexPath.row].fullname)
                cell.Fullname.text = friend_requests[indexPath.row].fullname
                
                // Avatar
                print("avatar_url", friend_requests[indexPath.row].avatar_url)
                if(friend_requests[indexPath.row].avatar_url.isEmpty == false){
                    
                    if(friend_requests[indexPath.row].avatar_is_cached == true){
                        // Use cached
                        cell.Avatar.image = friend_requests[indexPath.row].avatar
                        
                    }else{
                        // DL
                        print("COMMENT AVATAR USE DL")
                        let url = URL(string: friend_requests[indexPath.row].avatar_url)!
                        
                        helper.download_image(url: url, on_complete: {image in
                            self.friend_requests[indexPath.row].avatar = image // Cache
                            self.friend_requests[indexPath.row].avatar_is_cached = true
                            cell.Avatar.image = image
                            
                        }, on_fail: {
                            // Use default
                            let image = UIImage(named: self.settings.default_avatar) ?? UIImage()
                            self.friend_requests[indexPath.row].avatar = image // Cache
                            self.friend_requests[indexPath.row].avatar_is_cached = true
                            cell.Avatar.image = image
                        })
                    }
                    
                }else{
                    let image = UIImage(named: self.settings.default_avatar) ?? UIImage()
                    self.friend_requests[indexPath.row].avatar = image // Cache
                    self.friend_requests[indexPath.row].avatar_is_cached = true
                    cell.Avatar.image = image
                }
                // Avatar END
                
                cell.Confirm_Request.tag = Int(friend_requests[indexPath.row].id)!
                cell.Delete_Request.tag = Int(friend_requests[indexPath.row].id)!
                
                return cell
                
            }else{
                // Friends Recommended
                print("TABLE RENDER REQUESTS SECTION 1")
                
                let cell = Requests_Table.dequeueReusableCell(withIdentifier: "TblCell_Friend_Recommended", for: indexPath) as! TblCell_Friend_Recommended
                
                print("id", friend_recommended[indexPath.row].id)
                
                // creating delegate relations from the cell to current vc in order to access protocols of the delegate class
                //cell.delegate = self as! Friend_Recommended_Delegate
                
                cell.id = friend_recommended[indexPath.row].id
                print("fullname", friend_recommended[indexPath.row].fullname)
                cell.Fullname.text = friend_recommended[indexPath.row].fullname
                
                // Avatar
                print("avatar_url", friend_recommended[indexPath.row].avatar_url)
                if(friend_recommended[indexPath.row].avatar_url.isEmpty == false){
                    
                    if(friend_recommended[indexPath.row].avatar_is_cached == true){
                        // Use cached
                        cell.Avatar.image = friend_recommended[indexPath.row].avatar
                        
                    }else{
                        // DL
                        print("COMMENT AVATAR USE DL")
                        let url = URL(string: friend_recommended[indexPath.row].avatar_url)!
                        
                        helper.download_image(url: url, on_complete: {image in
                            self.friend_recommended[indexPath.row].avatar = image // Cache
                            self.friend_recommended[indexPath.row].avatar_is_cached = true
                            cell.Avatar.image = image
                            
                        }, on_fail: {
                            // Use default
                            let image = UIImage(named: self.settings.default_avatar) ?? UIImage()
                            self.friend_recommended[indexPath.row].avatar = image // Cache
                            self.friend_recommended[indexPath.row].avatar_is_cached = true
                            cell.Avatar.image = image
                        })
                    }
                    
                }else{
                    let image = UIImage(named: self.settings.default_avatar) ?? UIImage()
                    self.friend_recommended[indexPath.row].avatar = image // Cache
                    self.friend_recommended[indexPath.row].avatar_is_cached = true
                    cell.Avatar.image = image
                }
                // Avatar END
                
                cell.Confirm_Request.tag = indexPath.row
                cell.Delete_Request.tag = indexPath.row
                
                if(friend_recommended[indexPath.row].frindship_status == 0){
                    cell.Confirm_Request.isHidden = false
                    cell.Delete_Request.isHidden = false
                    cell.Action_Message.isHidden = true
                }
        
                return cell
                
            }
            
            
            
        }else{
            return UITableViewCell();
        }
        
    }
    
    
    
    /****************** EVENTS *******************/
    /* INTERACTIONS */
    
    // on Search bar input focus
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("search input")
        
        searchBar.setShowsCancelButton(true, animated: true)
        Friends_Table.isHidden = false
        Requests_Table.isHidden = true
    }
    
    // on Search bar cancel clicked
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel")
        
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        Friends_Table.isHidden = true
        Requests_Table.isHidden = false
        searchBar.resignFirstResponder()
        
        users.removeAll(keepingCapacity: false)
        Friends_Table.reloadData()
    }
    
    // on Search bar input
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        load_search()
    }
    
    // on Friend button clicked
    @IBAction func Friend_clicked(_ Friend_button: UIButton) {
        print("Friend_clicked")
        
        // accessing indexPath.row of the cell
        let index = Friend_button.tag
        
        // getting ids of the users
        guard let user_id = current_user["user_id"] as? String else {
            return
        }
        let target_user_id = users[index].id
        let friendship_status = users[index].frindship_status
        
        switch friendship_status {
        case 3: // Users are friends, show action with unfriend or cancel
            let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                // send request to the server
                
                self.helper.api_delete_friend(current_user_id: user_id, friend_id: target_user_id, target_view: self, on_complete: {result in
                    
                    if(result["status"] as! Int == 1){
                        
                        // Status
                        self.users[index].frindship_status = 0
                        
                        // Friend button appearence
                        let image = UIImage(named: "friends")
                        Friend_button.setImage(image, for: .normal)
                        Friend_button.tintColor = UIColor.darkGray
                        //
                        
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
                        // Status
                        self.users[index].frindship_status = 3
                        
                        // Friend button appearence
                        let image = UIImage(named: "friends")
                        Friend_button.setImage(image, for: .normal)
                        Friend_button.tintColor = self.settings.color_1
                        //
                        
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
                        // Status
                        self.users[index].frindship_status = 0
                        
                        // Friend button appearence
                        let image = UIImage(named: "unfriend")
                        Friend_button.setImage(image, for: .normal)
                        Friend_button.tintColor = UIColor.darkGray
                        //
                        
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
                    
                    // Status
                    self.users[index].frindship_status = 0
                    
                    // Friend button appearence
                    let image = UIImage(named: "unfriend")
                    Friend_button.setImage(image, for: .normal)
                    Friend_button.tintColor = UIColor.darkGray
                    //
                    
                }else{
                    self.helper.show_alert_ok(title: "Error", message: result["error"] as! String, target_view: self)
                }
            })
            break
            
        case 0: // Not interacted, Send friend request
            helper.api_add_friend_request(current_user_id: user_id, target_user_id: target_user_id, target_view: self, on_complete: {result in
                
                if(result["status"] as! Int == 1){
                    // Status
                    self.users[index].frindship_status = 1
                    
                    // Friend button appearence
                    let image = UIImage(named: "request")
                    Friend_button.setImage(image, for: .normal)
                    Friend_button.tintColor = self.settings.color_1
                    //
                    
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
    
    @IBAction func Recommended_Add_clicked(_ addButton: UIButton) {
        
        // accessing indexPath.row of the cell
        let index = addButton.tag
        let indexPath = IndexPath(row: index, section: 1)
        
        // getting ids of the users
        guard let user_id = current_user["user_id"] as? String else {
            return
        }
        let target_user_id = friend_recommended[index].id
        //let friendship_status = friend_recommended[index].frindship_status
        
        helper.api_add_friend_request(current_user_id: user_id, target_user_id: target_user_id, target_view: self, on_complete: {result in
            
            if(result["status"] as! Int == 1){
                // Status
                self.friend_recommended[index].frindship_status = 1
                
                let cell = self.Requests_Table.cellForRow(at: indexPath) as! TblCell_Friend_Recommended
                
                cell.Confirm_Request.isHidden = true
                cell.Delete_Request.isHidden = true
                cell.Action_Message.isHidden = false
                
                cell.Action_Message.text = "Request sent"
                
            }else{
                self.helper.show_alert_ok(title: "Error", message: result["error"] as! String, target_view: self)
            }
        })
        
    }
    
    
    @IBAction func Recommended_Remove_clicked(_ removeButton: UIButton) {
        
        // accessing indexPath.row
        let index = removeButton.tag
        let indexPath = IndexPath(row: index, section: 1)
        
        // remove value in array
        friend_recommended.remove(at: index)
        
        // remove physical cell
        Requests_Table.beginUpdates()
        Requests_Table.deleteRows(at: [indexPath], with: .automatic)
        Requests_Table.endUpdates()
    }
    
    
    
    /* INTERACTIONS END */
    /**************** EVENTS END *****************/
    /******************* FUNCS *******************/
    /* OTHER */
    
    // Send request and form users array, update table
    @objc func load_search(){
        if(is_loading == true){
            return
        }
        is_loading = true
        
        guard let current_user_id = current_user["user_id"] as? String,
            var search_text = Search_Bar.text
            else{
                is_loading = false
                return
        }
        
        search_text = search_text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if(search_text.count < 3){
            DispatchQueue.main.async {
                self.users.removeAll(keepingCapacity: false)
                self.Friends_Table.reloadData()
                self.is_loading = false
            }
            return
        }
        
        users.removeAll(keepingCapacity: false)
        
        helper.api_search_user(current_user_id: current_user_id, search_value: search_text, target_view: self, on_complete: {result in
            
            print(result)
            if(result["status"] as! Int == 1){
                
                let content = result["content"] as! [String: Any]
                let found = content["found"] as! [NSDictionary]
                
                for found_user in found{
                    
                    if let id = found_user["id"] as? String,
                       let first_name = found_user["first_name"] as? String,
                       let last_name = found_user["last_name"] as? String
                    {
                        
                        print(found_user)
                        let avatar_url = self.helper.cast(value: found_user["avatar"])
                        
                        let fullname = "\(first_name) \(last_name)"
                        let is_friend_requested = self.helper.cast(value: found_user["is_friend_requested"])
                        let is_friend_recieved = self.helper.cast(value: found_user["is_friend_recieved"])
                        let is_friend1 = self.helper.cast(value: found_user["is_friend1"])
                        let is_friend2 = self.helper.cast(value: found_user["is_friend2"])
                        let cover_url = self.helper.cast(value: found_user["cover"])
                        let biography = self.helper.cast(value: found_user["biography"])
                        let allow_friends = self.helper.cast(value: found_user["allow_friends"])
                        let allow_follow = self.helper.cast(value: found_user["allow_follow"])
                        let is_followed = self.helper.cast(value: found_user["is_followed"])
                        
                        
                        
                        let data_obj = User_Data()
                        data_obj.id = id
                        data_obj.first_name = first_name
                        data_obj.last_name = last_name
                        data_obj.fullname = fullname
                        data_obj.avatar_url = avatar_url
                        data_obj.cover_url = cover_url
                        data_obj.biography = biography
                        data_obj.allow_friends = allow_friends
                        data_obj.allow_follow = allow_follow
                        /*
                        if(is_friend_requested != ""){
                            data_obj.is_friend_requested = true
                        }else{
                            data_obj.is_friend_requested = false
                        }
                        */
                        
                        // is followed
                        if(is_followed != ""){
                            data_obj.is_followed = true
                        }else{
                            data_obj.is_followed = false
                        }
                        
                        // Determine friendship status
                        if(is_friend1 != "" || is_friend2 != ""){
                            data_obj.frindship_status = 3 // two users are friends
                        }else if(is_friend_recieved != "" && is_friend_recieved == current_user_id){
                            data_obj.frindship_status = 2 // current user recieved friendship request
                        }else if(is_friend_requested != "" && is_friend_requested == current_user_id){
                            data_obj.frindship_status = 1 // current user sent friendship request
                        }else{
                            data_obj.frindship_status = 0 // users not interacted
                        }
                        
                        
                        
                        self.users.append(data_obj)
                        
                    }else{
                        print("User from array failed to get all data")
                    }
                    
                }
                
            }else{
                self.helper.show_alert_ok(title: "Error", message: result["error"] as! String, target_view: self)
            }
            
            self.search_offset = self.users.count
            self.Friends_Table.reloadData()
            self.is_loading = false
    
        })
    }
    
    // Send request and form friend_requests array, update table
    @objc func load_frient_requests(){
        if(is_loading == true){
            return
        }
        is_loading = true
        
        guard let current_user_id = current_user["user_id"] as? String
            else{
                is_loading = false
                return
        }
        
        friend_requests.removeAll(keepingCapacity: false)
        
        helper.api_get_friend_requests(current_user_id: current_user_id, offset: requests_offset, limit: requests_limit, target_view: self, on_complete: {result in
            
            print(result)
            if(result["status"] as! Int == 1){
                
                let content = result["content"] as! [String: Any]
                let requests = content["requests"] as! [NSDictionary]
                
                for request in requests{
                    
                    if let id = request["id"] as? String,
                        let first_name = request["first_name"] as? String,
                        let last_name = request["last_name"] as? String
                    {
                        let avatar_url = self.helper.cast(value: request["avatar"])
                        
                        let fullname = "\(first_name) \(last_name)"
                        let cover_url = self.helper.cast(value: request["cover"])
                        let biography = self.helper.cast(value: request["biography"])
                        
                        
                        let allow_friends = self.helper.cast(value: request["allow_friends"])
                        let allow_follow = self.helper.cast(value: request["allow_follow"])
                        let is_followed = self.helper.cast(value: request["is_followed"])
                        
                        
                        let data_obj = User_Data()
                        data_obj.id = id
                        data_obj.first_name = first_name
                        data_obj.last_name = last_name
                        data_obj.fullname = fullname
                        data_obj.avatar_url = avatar_url
                        data_obj.cover_url = cover_url
                        data_obj.biography = biography
                        data_obj.allow_friends = allow_friends
                        data_obj.allow_follow = allow_follow
                        
                        // is followed
                        if(is_followed != ""){
                            data_obj.is_followed = true
                        }else{
                            data_obj.is_followed = false
                        }
                        
                        // Determine friendship status //
                        data_obj.frindship_status = 2 // current user recieved friendship

                        
                        self.friend_requests.append(data_obj)
                        
                    }else{
                        print("User from array failed to get all data")
                    }
                    
                }
                
            }else{
                self.helper.show_alert_ok(title: "Error", message: result["error"] as! String, target_view: self)
            }
            
            self.search_offset = self.friend_requests.count
            self.Requests_Table.reloadData()
            self.is_loading = false
            
        })
    }
    
    @objc func load_friend_recommended(){
        
        guard let current_user_id = current_user["user_id"] as? String
            else{
                return
        }
        
        friend_recommended.removeAll(keepingCapacity: false)
        
        helper.api_get_friend_recommended(current_user_id: current_user_id, offset: 0, limit: 20, target_view: self, on_complete: {result in
            
            print(result)
            if(result["status"] as! Int == 1){
                
                //let content = result["content"] as! [String: Any]
                let requests = result["content"] as! [NSDictionary]
                
                for request in requests{
                    
                    if let id = request["id"] as? String,
                        let first_name = request["first_name"] as? String,
                        let last_name = request["last_name"] as? String
                    {
                        let avatar_url = self.helper.cast(value: request["avatar"])
                        
                        let fullname = "\(first_name) \(last_name)"
                        let cover_url = self.helper.cast(value: request["cover"])
                        let biography = self.helper.cast(value: request["biography"])
                        
                        
                        let allow_friends = self.helper.cast(value: request["allow_friends"])
                        let allow_follow = self.helper.cast(value: request["allow_follow"])
                        let is_followed = self.helper.cast(value: request["is_followed"])
                        
                        
                        let data_obj = User_Data()
                        data_obj.id = id
                        data_obj.first_name = first_name
                        data_obj.last_name = last_name
                        data_obj.fullname = fullname
                        data_obj.avatar_url = avatar_url
                        data_obj.cover_url = cover_url
                        data_obj.biography = biography
                        data_obj.allow_friends = allow_friends
                        data_obj.allow_follow = allow_follow
                        
                        // is followed
                        if(is_followed != ""){
                            data_obj.is_followed = true
                        }else{
                            data_obj.is_followed = false
                        }
                        
                        // Determine friendship status //
                        data_obj.frindship_status = 0 // not interacted
                        
                        
                        self.friend_recommended.append(data_obj)
                        
                    }else{
                        print("User from array failed to get all data")
                    }
                    
                }
                
            }else{
                self.helper.show_alert_ok(title: "Error", message: result["error"] as! String, target_view: self)
            }
            
            self.search_offset = self.friend_recommended.count
            self.Requests_Table.reloadData()
            self.is_loading = false
            
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "GuestVC_Search"){
            guard let indexPath = Friends_Table.indexPathForSelectedRow else{
                return
            }
            let selected_user_obj = users[indexPath.row]
            let guest_vc = segue.destination as! GuestVC
            guest_vc.guest_data_obj = selected_user_obj
            
        }else if(segue.identifier == "GuestVC_Friend_Requests"){
            guard let indexPath = Requests_Table.indexPathForSelectedRow else{
                return
            }
            let selected_user_obj = friend_requests[indexPath.row]
            let guest_vc = segue.destination as! GuestVC
            guest_vc.guest_data_obj = selected_user_obj
            
        }else if(segue.identifier == "GuestVC_Friend_Recommended"){
            guard let indexPath = Requests_Table.indexPathForSelectedRow else{
                return
            }
            let selected_user_obj = friend_recommended[indexPath.row]
            let guest_vc = segue.destination as! GuestVC
            guest_vc.guest_data_obj = selected_user_obj
        }
    
    }
    
    
    // Shortcut to api
    func send_friend_request(action: String, user_id: String, friend_id: String){
    
    }
    
    /* OTHER END */
    /***************** FUNCS END *****************/
    
    
}
