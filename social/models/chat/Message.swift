//
//  Message.swift
//  CometChat
//
//  Created by Marin Benčević on 08/08/2019.
//  Copyright © 2019 marinbenc. All rights reserved.
//

import UIKit

struct Message {
    var id = String()
    var chat_id = String()
    var user = Chat_Contact()
    var content: String = String()
    var is_incoming: Bool = false
    var type:String = ""
    var date_created = String()
}
