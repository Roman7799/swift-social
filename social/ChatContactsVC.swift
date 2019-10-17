//
//  ContactsViewController.swift
//  CometChat
//
//  Created by Marin Benčević on 08/09/2019.
//  Copyright © 2019 marinbenc. All rights reserved.
//

import UIKit

final class ChatContactsVC: UIViewController {
  
  private enum Constants {
    static let cellIdentifier = "ContactsTableViewCell"
    static let showChatIdentifier = "ChatContactsVC_Chat"
  }
  
    var helper = Helper()
    var settings = Settings()
    
    public var chat_contacts: [Chat_Contact] = []
    public var offset = 0
    public var limit = 20
    public var is_loading = false
    
  private var refreshControl = UIRefreshControl()
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var tableViewFooter: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    //tableView.refreshControl = refreshControl
    
    tableView.dataSource = self
    tableView.delegate = self
    tableViewFooter.layer.addShadow(
      color: UIColor.black.withAlphaComponent(0.8),
      offset: CGSize(width: 0, height: 2),
      radius: 10)
    
    /*ChatService.shared.onUserStatusChanged = { [weak self] user in
      guard let self = self else { return }
      guard let index = self.contacts.firstIndex(of: user) else {
        return
      }
      
      self.contacts[index] = user
      self.tableView.reloadData()
    }
    */
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBar.shadowImage = nil
    
    offset = 0
    load_chat_contacts()
    //refresh()
  }
  
//
//  @objc private func refresh() {
//    ChatService.shared.getUsers { [weak self] users in
//      self?.refreshControl.endRefreshing()
//      self?.contacts = users
//      self?.tableView.reloadData()
//    }
//  }
//
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    guard let user_id = current_user["user_id"] as? String,
          let first_name = current_user["first_name"] as? String,
          let last_name = current_user["last_name"] as? String,
          let avatar_url = current_user["avatar"] as? String,
          let indexPath = tableView.indexPathForSelectedRow
    else {
        return
    }
    
    let avatar = current_user_avatar ?? UIImage(named: self.settings.default_avatar)!
    let full_name: String = "\(first_name.capitalized) \(last_name.capitalized)"
    let new_messages = 0
    
    let chat_id = chat_contacts[indexPath.row].chat_id
    
    switch segue.identifier {

    case "ChatContactsVC_Chat"?:
      guard
        let chatVC = segue.destination as? ChatVC
        //let contact = sender as? Chat_Contact
      else {
        return
      }
      
      chatVC.chat_id = chat_id
      
      var sender = Chat_Contact()
      sender.avatar = avatar
      sender.avatar_url = avatar_url
      sender.avatar_is_cached = false
      sender.chat_id = chat_id
      sender.first_name = first_name
      sender.last_name = last_name
      sender.full_name = full_name
      sender.user_id = user_id
      sender.new_messages = new_messages
      
      let reciever = chat_contacts[indexPath.row]
      chatVC.reciever = reciever
      chatVC.sender = sender
        
      let cell = tableView.cellForRow(at: indexPath) as! ContactsTableViewCell
        cell.New_Messages.text = "0"
        
    default:
      break
    }
  }
    
    
    func load_chat_contacts(){
        
        if(is_loading == true){
            return
        }
        is_loading = true
        
        guard let user_id = current_user["user_id"] as? String else {
            is_loading = false
            return
        }
        
        var is_more = true
        if(offset == 0){
            is_more = false
            chat_contacts.removeAll(keepingCapacity: false)
        }
        
        helper.api_chat_get(user_id: user_id, offset: offset, limit: limit, target_view: self, on_complete: {result in
            print("api_chat_get RESULT", result)
            
            if(result["status"] as! Int == 1){
                
                //print("GET POSTS RESULT", result)
                guard let found_rows = result["content"] as? [NSDictionary] else{
                    print("Can't let fail")
                    self.is_loading = false
                    return
                }
                
                if(found_rows.count > 0){
                    if(is_more){
                        self.tableView.beginUpdates()
                    }
                    
                    var i = 0
                    for row in found_rows {
                        
                        if let chat_id = row["id"] as? String,
                            let user_id = row["user_id"] as? String
                        {
                            let first_name = self.helper.cast(value: row["first_name"])
                            let last_name = self.helper.cast(value: row["last_name"])
                            let avatar_url = self.helper.cast(value: row["avatar"])
                            let new_messages_count = Int(self.helper.cast(value: row["new_messages"]))
                            
                            
                            var data_obj = Chat_Contact()
                            data_obj.chat_id = chat_id
                            data_obj.user_id = user_id
                            data_obj.avatar_url = avatar_url
                            data_obj.first_name = first_name
                            data_obj.last_name = last_name
                            data_obj.full_name = "\(first_name.capitalized) \(last_name.capitalized)"
                            data_obj.new_messages = new_messages_count!
 
                            self.chat_contacts.append(data_obj)
                            
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
                        self.offset = self.chat_contacts.count
                        if(is_more){
                            self.tableView.endUpdates()
                        }else{
                            self.tableView.reloadData()
                        }
                        
                        self.is_loading = false
                    }
                }else{
                    self.is_loading = false
                }
                
                
                
                
            }else{
                print("STATUS ERROR")
            }
        })
    
    }
    
}

// MARK: - UITableViewDelegate
extension ChatContactsVC: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    //let contact = chat_contacts[indexPath.row]
    //performSegue(withIdentifier: Constants.showChatIdentifier, sender: contact)
  }
  
}

// MARK: - UITableViewDataSource
extension ChatContactsVC: UITableViewDataSource {
  
  func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
    return chat_contacts.count
  }
  
  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    guard
      let cell = tableView.dequeueReusableCell(
      withIdentifier: Constants.cellIdentifier,
      for: indexPath) as? ContactsTableViewCell
    else {
        return UITableViewCell()
    }
    
    let contact = chat_contacts[indexPath.row]
    cell.contact = contact
    
    return cell
  }
}

