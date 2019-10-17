//
//  ChatVC.swift
//  social
//
//  Created by Denis Vesnin on 10/8/19.
//  Copyright © 2019 Geolance. All rights reserved.
//

import UIKit

final class ChatVC: UIViewController {
    
    private enum Constants {
        static let incomingMessageCell = "incomingMessageCell"
        static let outgoingMessageCell = "outgoingMessageCell"
        static let contentInset: CGFloat = 24
        static let placeholderMessage = "Type something"
    }
    
    var helper = Helper()
    var settings = Settings()
    
    var topSafeArea: CGFloat = 0
    var bottomSafeArea: CGFloat = 0
    
    var sender = Chat_Contact()
    var reciever = Chat_Contact() // This is not current_user
    var chat_id:String!
    var timer:Timer? = nil
    
    var messages: [Message] = [] {
        didSet {
            emptyChatView.isHidden = !messages.isEmpty
            tableView.reloadData()
        }
    }
    var is_loading = false
    var offset = 0
    var limit = 20
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textAreaBackground: UIView!
    @IBOutlet weak var textAreaBackgroundHeight: NSLayoutConstraint!
    @IBOutlet weak var textAreaBackgroundBottom: NSLayoutConstraint!
    @IBOutlet weak var textAreaStack: UIStackView!
    @IBOutlet weak var textAreaBottom: NSLayoutConstraint!
    @IBOutlet weak var emptyChatView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    
    
    // MARK: - Actions
    
    @IBAction func onSendButtonTapped(_ sender: Any) {
        sendMessage()
    }
    
    // Touched everywhere excluding objects
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // End editing and hide keyboard
        print("Touch")

    }
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        let text_height = textView.frame.height
        print("text_height", text_height)
        print("BG height", textAreaBackgroundHeight.constant)
        if(text_height > 50){
            textAreaBackgroundHeight.constant = text_height + 40
            self.view.layoutIfNeeded()
        }else{
            textAreaBackgroundHeight.constant = 90
        }
        
    }
    
    
    // MARK: - Interaction
    
    private func sendMessage() {
        let message: String = textView.text
        guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        textView.endEditing(true)
        addTextViewPlaceholer()
        
        helper.api_chat_message_add(chat_id: chat_id, user_id: sender.user_id, type: "text", content: message, target_view: self, on_complete: {result in
            print("api_chat_get RESULT", result)
            
            if(result["status"] as! Int == 1){
                
                guard let row = result["content"] as? NSDictionary else{
                    print("Can't let fail")
                    return
                }
                
                //let m_id = self.helper.cast(value: row["id"])
                let m_chat_id = self.helper.cast(value: row["chat_id"])
                //let m_user_id = self.helper.cast(value: row["user_id"])
                let m_type = self.helper.cast(value: row["type"])
                let m_content = self.helper.cast(value: row["content"])
                //let m_viewed = self.helper.cast(value: row["viewed"])
                let m_date_created = self.helper.cast(value: row["date_created"])
                
                var message = Message()
                message.chat_id = m_chat_id
                message.type = m_type
                message.content = m_content
                message.date_created = m_date_created
                message.user = self.sender
                message.is_incoming = false
                
                self.tableView.beginUpdates()
                self.messages.append(message)
                print(self.messages)
                self.offset = self.offset+1
                let section_index = self.tableView.numberOfSections - 1
                let row_index = self.tableView.numberOfRows(inSection: section_index)
                let path_to_last_row = IndexPath(row: row_index, section: section_index)
                //let path_to_last_row = IndexPath(row: 0, section: section_index)
                self.tableView.insertRows(at: [path_to_last_row], with: .top)
                self.tableView.endUpdates()
                
                DispatchQueue.main.async {
                    self.scrollToLastCell()
                }                

            }else{
                print("STATUS ERROR")
            }
        })
        
        //ChatService.shared.send(message: message, to: reciever)
        //TODO: api send message
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("DIdLoad Reciever", reciever)
        
        title = self.reciever.full_name
        
        print("title", title)
        
        emptyChatView.isHidden = false
        
        setUpTableView()
        setUpTextView()
        
        /*
        ChatService.shared.onRecievedMessage = { [weak self] message in
            guard let self = self else { return }
            let isFromReciever = message.user == self.reciever
            if !message.isIncoming || isFromReciever {
                self.messages.append(message)
                self.scrollToLastCell()
            }
        }
         */
        
        tableView.dataSource = self
        
        load_messages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addTextViewPlaceholer()
        startObservingKeyboard()
        
        /*
        ChatService.shared.getMessages(from: reciever) { [weak self] messages in
            self?.messages = messages
            self?.scrollToLastCell()
        }
 */
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Add default shadow to navigation bar
        let navigationBar = navigationController?.navigationBar
        navigationBar?.shadowImage = nil
        
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(timer_fire), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if(timer !== nil){
            timer?.invalidate()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if #available(iOS 11.0, *) {
            topSafeArea = view.safeAreaInsets.top
            bottomSafeArea = view.safeAreaInsets.bottom
        } else {
            topSafeArea = topLayoutGuide.length
            bottomSafeArea = bottomLayoutGuide.length
        }
        print("topSafeArea", topSafeArea)
        print("bottomSafeArea", bottomSafeArea)
        
        // safe area values are now available to use
        
    }
    
    
    // MARK: - Keyboard
    
    private func startObservingKeyboard() {
        
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            forName: NSNotification.Name.UIKeyboardWillShow,
            object: nil,
            queue: nil,
            using: keyboardWillAppear)
        notificationCenter.addObserver(
            forName: NSNotification.Name.UIKeyboardWillHide,
            object: nil,
            queue: nil,
            using: keyboardWillDisappear)
    }
    
    deinit {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(
            self,
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil)
        notificationCenter.removeObserver(
            self,
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil)
    }
    
    private func keyboardWillAppear(_ notification: Notification) {
        print("keyboard will appear")
        
        /*
        let key = UIKeyboardFrameEndUserInfoKey //UIResponder.keyboardFrameEndUserInfoKey
        guard let keyboardFrame = notification.userInfo?[key] as? CGRect else {
            return
        }
        */
        
        if let keyboard_size = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            print("Keyb height = \(keyboard_size.height)")
            
            //let safeAreaBottom = view.safeAreaLayoutGuide.layoutFrame.maxY
            let safeAreaBottom = bottomSafeArea//view.bottomAnchor
            let viewHeight = view.bounds.height
            let safeAreaOffset = viewHeight - safeAreaBottom
            
            let lastVisibleCell = tableView.indexPathsForVisibleRows?.last
            
            print("safeAreaBottom", safeAreaBottom)
            print("viewHeight", viewHeight)
            print("safeAreaOffset", safeAreaOffset)
            
            let bottom_final_value = -keyboard_size.height
            print("bottom_final_value", bottom_final_value)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.textAreaBackgroundBottom.constant = bottom_final_value
                self.textAreaBottom.constant = bottom_final_value//-keyboard_size.height + safeAreaOffset
                //self.textAreaStack.layer.zPosition = 1
                //bringSubviewToFront(label)
                
                //self.textAreaStack.isUserInteractionEnabled = true
                self.view.layoutIfNeeded()
                if let lastVisibleCell = lastVisibleCell {
                    self.tableView.scrollToRow(
                        at: lastVisibleCell, at: .bottom, animated: false)
                }
            })
            /*
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: [.curveEaseInOut],
                animations: {
                    self.textAreaBottom.constant = -keyboard_size.height + safeAreaOffset
                    self.view.layoutIfNeeded()
                    if let lastVisibleCell = lastVisibleCell {
                        self.tableView.scrollToRow(
                            at: lastVisibleCell, at: .bottom, animated: false)
                    }
            })
 */
            
            
            //let safeAreaBottom = view.safeAreaLayoutGuide.layoutFrame.maxY
            //let viewHeight = view.bounds.height
            //let safeAreaOffset = viewHeight - safeAreaBottom
            
            
//            UIView.animate(
//                withDuration: 0.3,
//                delay: 0,
//                options: [.curveEaseInOut],
//                animations: {
//                    self.textAreaBottom.constant = keyboard_size.height
//                    self.view.layoutIfNeeded()
//                    if let lastVisibleCell = lastVisibleCell {
//                        self.tableView.scrollToRow(
//                            at: lastVisibleCell, at: .bottom, animated: false)
//                    }
//            })
        }
        
        
    }
    
    private func keyboardWillDisappear(_ notification: Notification) {
        print("keyboard will disappear")
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseInOut],
            animations: {
                self.textAreaBackgroundBottom.constant = 0
                self.textAreaBottom.constant = 0
                self.textAreaBackgroundHeight.constant = 90
                self.view.layoutIfNeeded()
        })
    }
    
    
    // MARK: - Set up
    
    private func setUpTextView() {
        textView.isScrollEnabled = false
        textView.textContainer.heightTracksTextView = true
        textView.delegate = self
        
        textAreaBackground.layer.addShadow(
            color: UIColor(red: 189 / 255, green: 204 / 255, blue: 215 / 255, alpha: 54 / 100),
            offset: CGSize(width: 2, height: -2),
            radius: 4)
    }
    
    private func setUpTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: Constants.contentInset, left: 0, bottom: 0, right: 0)
        tableView.allowsSelection = false
    }
    
    func load_messages(timed: Bool = false){
        if(is_loading == true){
            return
        }
        is_loading = true
        
        guard let current_user_id = current_user["user_id"] as? String else {
            is_loading = false
            return
        }
        
        var is_more = true
        var order = "DESC"
        if(offset == 0){
            is_more = false
            messages.removeAll(keepingCapacity: false)
            order = "ASC"
        }
        
        var last_id = ""
        if(timed){
            if(messages.count > 0){
                last_id = messages[messages.count-1].id
            }else{
                last_id = "0"
            }
            
        }
        helper.api_chat_messages_get(chat_id: String(chat_id), user_id: reciever.user_id, user2_id: sender.user_id, offset: offset, limit: limit, order: order, last_id: last_id, target_view: self, on_complete: {result in
            print("api_chat_messages_get RESULT", result)
            
            if(result["status"] as! Int == 1){
                
                let chat_id = self.helper.cast(value: result["chat_id"])
                
                print(self.chat_id, "-1", chat_id)
                if(self.chat_id == String("-1")){
                    self.chat_id = chat_id
                }

                guard let found_rows = result["content"] as? [NSDictionary] else{
                    print("Can't let fail")
                    self.is_loading = false
                    return
                }
                
                if(found_rows.count > 0){
                    if(is_more){
                        //self.tableView.beginUpdates()
                    }
                    
                    var i = 0
                    for row in found_rows {
                        
                        if  let message_id =  row["id"] as? String,
                            let message_user_id = row["user_id"] as? String,
                            let message_chat_id = row["chat_id"] as? String,
                            let message_type = row["type"] as? String,
                            var message_content = row["content"] as? String,
                            let message_date = row["date_created"] as? String
                        {
                            message_content = message_content.decodingHTMLEntities()
                            
                            var data_obj = Message()
                            var user_obj: Chat_Contact
                            if(message_user_id == current_user_id){
                                user_obj = self.sender
                                data_obj.is_incoming = false
                            }else{
                                user_obj = self.reciever
                                data_obj.is_incoming = true
                            }
                            
                            
                            data_obj.id = message_id
                            data_obj.user = user_obj
                            data_obj.chat_id = message_chat_id
                            data_obj.content = message_content
                            data_obj.type = message_type
                            data_obj.date_created = message_date
                            
                            
                            

                            if(is_more){
                                if(timed){
                                    self.messages.insert(data_obj, at: self.messages.count)
                                }else{
                                    self.messages.insert(data_obj, at: 0)
                                    //let section_index = self.tableView.numberOfSections - 1
                                    //let path_to_last_row = IndexPath(row: 0, section: section_index)
                                    //self.tableView.insertRows(at: [path_to_last_row], with: .top)
                                }
                            }else{
                                self.messages.append(data_obj)
                            }
                        }
                        
                        i += 1
                    }
                    
                    
                    DispatchQueue.main.async {
                        self.offset = self.messages.count
                        if(is_more || timed){
                            //self.tableView.endUpdates()
                            self.tableView.reloadData()
                        }else{
                            self.tableView.reloadData()
                            self.scrollToLastCell(animated: false)
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
    
    
    @objc func timer_fire(){
        print("Timer fired")
        load_messages(timed: true)
    }
}

// MARK: - UITableViewDataSource
extension ChatVC: UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let message = messages[indexPath.row]
        
        let cellIdentifier = message.is_incoming ?
            Constants.incomingMessageCell :
            Constants.outgoingMessageCell
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: cellIdentifier, for: indexPath)
            as? MessageCell & UITableViewCell else {
                return UITableViewCell()
        }
        
        cell.message = message
        
        if indexPath.row < messages.count - 1 {
            let nextMessage = messages[indexPath.row + 1]
            cell.showsAvatar = message.is_incoming != nextMessage.is_incoming
        } else {
            cell.showsAvatar = true
        }
        
        return cell
    }
    
    private func scrollToLastCell(animated:Bool = true) {
        let lastRow = tableView.numberOfRows(inSection: 0) - 1
        guard lastRow > 0 else {
            return
        }
        
        let lastIndexPath = IndexPath(row: lastRow, section: 0)
        tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: animated)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(tableView.contentOffset.y < 2 && is_loading == false)
        {
            load_messages()
        }
        
    }
}

// MARK: - UITextViewDelegate
extension ChatVC: UITextViewDelegate {
    private func addTextViewPlaceholer() {
        textView.text = Constants.placeholderMessage
        textView.textColor = UIColor.groupTableViewBackground
    }
    
    private func removeTextViewPlaceholder() {
        textView.text = ""
        textView.textColor = UIColor.darkGray
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        removeTextViewPlaceholder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            addTextViewPlaceholer()
        }
    }
}


