// TODO: Change regex for validation

import UIKit
import Alamofire
import Photos

class Helper{
    var api_base_url: String
    var api_base_command: String
    let settings = Settings()
    
    init(){
        self.api_base_url = "http://swift-social.pria.digital"
        self.api_base_command = self.api_base_url + "/command"
    }
    
    
    // Date formatter
    func date_string_convert(date_string: String, from_format: String, to_format: String) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = from_format
        let date = formatter.date(from: date_string)!
        formatter.dateFormat = to_format
        let converted = formatter.string(from: date)
        return converted
    }
    // Date formatter Front->Server
    func date_string_convert(front_date_string: String) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = settings.date_format_front
        let date = formatter.date(from: front_date_string)!
        formatter.dateFormat = settings.date_format_server
        let converted = formatter.string(from: date)
        return converted
    }
    // Date formatter Server->Front
    func date_string_convert(server_date_string: String) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = settings.date_format_server
        let date = formatter.date(from: server_date_string)!
        formatter.dateFormat = settings.date_format_front
        let converted = formatter.string(from: date)
        return converted
    }
    
    // Cast value to string or nil
    func cast(value: Any?) -> String{
        //print("CAST value is", type(of: value))
        if value is NSNull || value == nil{ // value in NSNull
            return "" as String!
        }else{
            let cast = "\(value!)"
            return cast as String!
            
//            if(value is NSString || value is String){
//                let cast = "\(value)"
//                return cast
//            }
        }
    }

 
    
    // Valid email
    func isValid(email: String) -> Bool{
        let regex = "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,64}"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = test.evaluate(with: email)
        return result
    }
    
    // Valid name
    func isValid(name: String) -> Bool{
        let regex = "[A-Za-z]{3,}"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = test.evaluate(with: name)
        return result
    }
    
    func isValid(password: String) -> Bool{
        let regex = "[A-Za-z0-9!@#$%^&*()]{6,}"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = test.evaluate(with: password)
        return result
    }
    
    // set ScrollView position
    func set_scroll_horizontal_position(scrollView: UIScrollView, slide_num: Int){
        let pos = CGPoint(x: UIScreen.main.bounds.width * CGFloat(slide_num-1) , y: 0)
        scrollView.setContentOffset(pos, animated: true)
    }
    
    func show_alert_ok(title: String, message: String, target_view: UIViewController){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        target_view.present(alert, animated: true, completion: nil)
        
    }
    
    // Launch target view controller by identifier
    func instantinate_view_controller(id: String, animated: Bool, by current_view_controller: UIViewController, on_complete: (() -> Void)?){
        let target_vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: id)
        current_view_controller.present(target_vc, animated: true, completion: on_complete)
        
    }
    
    // Download image from url
    func download_image(url: URL, on_complete: @escaping (_ image: UIImage) -> Void, on_fail: @escaping () -> Void = {})
    {
        print("DOWNLOAD START")
        
        //
        //let test_url = URL(string: "https://swift-social.pria.digital/uploads/19/cover/image.jpg")!
        
        /*
         
         
         */
        
        DispatchQueue.global().async {
            do{
                print("FILE URL:", url)
                if let image = cache_image.object(forKey: url.absoluteString as NSString) {
                    print("USED CACHED")
                    on_complete(image)
                }else{
                    let data = try Data(contentsOf: url)
                    DispatchQueue.main.async {
                        if let image = UIImage(data: data){
                            cache_image.setObject(image, forKey: url.absoluteString as NSString)
                            print("DOWNLOAD COMPLETE")
                            on_complete(image)
                        }else{
                            print("NOT IMAGE")
                            on_fail()
                        }
                        
                    }
                }
                
                
                
            }catch{
                print("DOWNLOAD FAILED", error)
                on_fail()
            }
        }
        
        /*
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            guard let data = data, error == nil else {
                print("DOWNLOAD FAILED", error)
                return
            }
            //print(response?.suggestedFilename ?? url.lastPathComponent)
            
            DispatchQueue.main.async() {
                if let image = UIImage(data: data){
                    print("DOWNLOAD FINISHED")
                    on_complete(image)
                }else{
                    print("DOWNLOAD FAILED - DATA NOT IMAGE")
                }
                
            }
        }).resume()
        */
    }
    
    // Get access for photo library
    func access_photo(on_success: @escaping () -> Void, on_denied: @escaping () -> Void) {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("photo library authorized")
            on_success()
            break
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in print("status is \(newStatus)")
                if newStatus == PHAuthorizationStatus.authorized {
                    print("photo library access granted")
                    on_success()
                }else{
                    print("photo library access rejected")
                    on_denied()
                }
            })
            break
        case .restricted:
            print("User do not have access to photo album.")
            on_denied()
            break
        case .denied:
            print("User has denied the permission.")
            on_denied()
            break
        }
    }
    
    // Find parents of element of certain class
    func find_parent<T>(child: AnyObject, search_class: T.Type) -> AnyObject?{
        
        var child = child as AnyObject?
        
        while(child != nil && child is T == false){
            child = child!.superview as AnyObject?
        }
        if (child as? UITableViewCell) == nil {
            return nil
        }else{
            return child!
        }
        
        /* Original working, but not in func
         var table_cell = sender.superview
         while(table_cell is UITableViewCell == false){
         table_cell = table_cell?.superview
         }
         if (table_cell as? UITableViewCell) == nil {
         return
         }
         let post_id = "\(table_cell!.tag)"
         */
    }
    
    /***************** INTERFACE *****************/
    
    func configure_avatar_post(element: UIView){
        element.layer.cornerRadius = element.frame.width / 2
        element.clipsToBounds = true
    }
    
    func style_image_round(element: UIView){
        element.layer.cornerRadius = element.frame.width / 2
        element.clipsToBounds = true
    }
    
    func style_border_radius(element: UIView, value: Int, clip_to_bounds: Bool = false, mask_to_bounds: Bool = false){
        element.layer.cornerRadius = CGFloat(value)
        if(clip_to_bounds){
            element.clipsToBounds = true
        }else{
            element.clipsToBounds = false
        }
        if(mask_to_bounds){
            element.layer.masksToBounds = true
        }else{
            element.layer.masksToBounds = true
        }
    }
    
    // Animations
    
    // Animation of scale up and then scale down
    func ani_pop(element: UIView){
        UIView.animate(withDuration: 0.15, animations: {
            element.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }, completion: { completed in
            UIView.animate(withDuration: 0.15, animations: {
                element.transform = CGAffineTransform.identity
            })
        })
    }
    
    
    // Animations END
        
    /*************** INTERFACE END ***************/
    
    /******************** API ********************/
    
    // Base function for api request
    func api_send_request(command: String, data: [String: Any], target_view: UIViewController) {
        let url = URL(string: self.api_base_command + command + ".php" )!
        var data = data
        data.updateValue("DBGTOKEN", forKey: "token")
        
        do{
            let json_data = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            //let json_string = String(data: json_data, encoding: .utf8)
            //print(json_data)
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "POST"
            request.httpBody = json_data
                //.data(using: .utf8)
            
            
            
            
            URLSession.shared.dataTask(with: request){(data, response, error) in
                if(error != nil){
                    print("API RESULT ERROR")
                    self.show_alert_ok(title: "ERROR", message: "Api returned error", target_view: target_view)
                    return
                    //return nil
                }
                
                do{
                    guard let data = data else{
                        print("API data WRONG")
                         self.show_alert_ok(title: "ERROR", message: "Api returned wrong data", target_view: target_view)
                        return
                    }
                    
                    let result_json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    print(result_json)
                    
                    
                }catch{
                    print("API DO ERROR")
                     self.show_alert_ok(title: "ERROR", message: "Api returned bad json", target_view: target_view)
                    return
                }
                
                
                }.resume()
            
        }catch{
            print("JSON DECODE ERROR")
        }
    }
    
    func api_send_request_2(command: String, data: [String: Any], target_view: UIViewController, on_complete: @escaping (_ result: NSDictionary) -> Void) {
        
        //print("api_send_request_2")
        
        let url = URL(string: self.api_base_command + command + ".php" )!
        var data = data
        data.updateValue("DBGTOKEN", forKey: "token")
        print("$_POST:", data)
        
        //print("AF START")
        let request = Alamofire.request(url, method: .post, parameters: data)
        request.validate()
        request.responseJSON{ (response)->Void in
            //print("AF RESPONSE:", response)
            switch response.result {
            case .success(let data as NSDictionary):
                //print(data)
                on_complete(data)
                break
                
            case .failure(let error):
                print(error)
                break
                
            default:
                print("AF JSON ERROR")
                break
            }
            
        }
        
        // This may be helpful later
        /*
        do{
            //let json_data = try JSONSerialization.data(withJSONObject: data, options: [])
            let json_data = try JSONSerialization.data(withJSONObject: data)
            let json_string = String(data: json_data, encoding: .utf8)!
            print("JSON_STRING: ", json_string)
            print("JSON_DATA: ", json_data)
            
            // is json valid?
            let valid = JSONSerialization.isValidJSONObject(data)
            print("IS_JSON_VALID:", valid)
            
            // revert json to dict
            //let tmp_dict = try JSONSerialization.jsonObject(with: json_data, options: [])
            //print("JSON->DICT", tmp_dict)
            
            // Json data from string
            let data_jstring = json_string.data(using: .utf8)!
            print("JSTRING:", data_jstring)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            //request.addValue("x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            //request.addValue("application/json", forHTTPHeaderField: "Accept")
            //request.addValue("", forHTTPHeaderField: <#T##String#>)
            request.httpBody = data_jstring//json_string.data(using: .utf8)
            
            URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
                DispatchQueue.main.async {
                    if(error != nil){
                        print("API RESULT ERROR")
                        self.show_alert_ok(title: "ERROR", message: "Api returned error", target_view: target_view)
                        return
                        //return nil
                    }
                    
                    do{
                        guard let data = data else{
                            print("API data WRONG")
                            self.show_alert_ok(title: "ERROR", message: "Api returned wrong data", target_view: target_view)
                            return
                        }
                        
                        let result_json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                        print(result_json)
                        on_complete(result_json!)
                        
                        
                    }catch{
                        print("API DO ERROR")
                        self.show_alert_ok(title: "ERROR", message: "Api returned bad json", target_view: target_view)
                        return
                    }
                }
            }).resume()
            
        }catch{
            print("JSON DECODE ERROR")
        }
        */
    }
    
    // API Upload request for single image
    func api_upload(command: String, image: UIImage, data: [String: Any], target_view: UIViewController, on_complete: @escaping (_ result: NSDictionary) -> Void){
        
        print("api_upload (single image)")
        let url = URL(string: self.api_base_command + command + ".php" )!
        
        var data = data
        data.updateValue("DBGTOKEN", forKey: "token")
        
        print("DATA FOR POST:", data)
        
        print("AF START")
        //let headers = [""]
        let request = Alamofire.upload(multipartFormData: {form_data in
            
            do{
                let json = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                print("UPLOAD SINGLE JSON DATA", json)
                form_data.append(json as Data, withName: "json")
                print("UPLOAD SINGLE FORM DATA", form_data)
                
            }catch{
                print("JSON SERIALIZATION FAILED")
                return
            }
            
            // 10.1
            //if let image_data = image.jpegData(compressionQuality: 0.7){
            // 9.2
            if let image_data = UIImageJPEGRepresentation(image, 0.7){
                form_data.append(image_data, withName: "file")
                print("UPLOAD SINGLE FORM DATA + IMAGE", form_data)
            }else{
                print("IMAGA DATA FAILED")
                return
            }
            
        }, usingThreshold: UInt64.init(),
           to: url,
           method: .post,
           headers: nil,
           encodingCompletion: {(result) in
            switch(result){
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: {(progress) in
                    print("DOWNLOAD PROGRESS", progress.fractionCompleted)
                })
                
                upload.responseJSON(completionHandler: {(response) in
                    
                    print("UPLOAD RESPONSE:", response)
                    
                    switch response.result{
                    case .success(let data as NSDictionary):
                        print("RAW RESPONSE DATA", data)
                        on_complete(data)
                        break
                        
                    case .failure(let error):
                        print("JSON ERROR:", error)
                        break
                        
                    default:
                        print("JSON ERROR DEFAULT")
                        break
                        
                    }
    
                })
                
                break
                
            case .failure(let encoding_error):
                print("ERROR:", encoding_error.localizedDescription)
                break
                
            }
        })
        
    }
    
    // Upload multiform with multiple images
    func api_upload(command: String, images: [String: UIImage], data: [String: Any], target_view: UIViewController, on_complete: @escaping (_ result: NSDictionary) -> Void){
        
        print("api_upload")
        let url = URL(string: self.api_base_command + command + ".php" )!
        
        var data = data
        data.updateValue("DBGTOKEN", forKey: "token")
        
        print("DATA FOR POST:", data)
        
        print("AF START")
        //let headers = [""]
        let request = Alamofire.upload(multipartFormData: {form_data in
            
            do{
                let json = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                print("UPLOAD DATA JSON", json)
                form_data.append(json as Data, withName: "json")
                print("UPLOAD FORM DATA:", form_data)
                
            }catch{
                print("JSON SERIALIZATION FAILED")
                return
            }
            
            for (key, image) in images{
                // 10.1
                //if let image_data = image.jpegData(compressionQuality: 0.7){
                // 9.2
                if let image_data = UIImageJPEGRepresentation(image, 0.7){
                    form_data.append(image_data, withName: "file\(key)")
                }else{
                    print("IMAGA DATA FAILED")
                    return
                }
            }
            
        }, usingThreshold: UInt64.init(),
           to: url,
           method: .post,
           headers: nil,
           encodingCompletion: {(result) in
            switch(result){
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: {(progress) in
                    print("DOWNLOAD PROGRESS", progress.fractionCompleted)
                })
                
                upload.responseJSON(completionHandler: {(response) in
                    
                    switch response.result{
                    case .success(let data as NSDictionary):
                        print("RAW RESPONSE DATA", data)
                        on_complete(data)
                        break
                        
                    case .failure(let error):
                        print("JSON ERROR:", error)
                        break
                        
                    default:
                        print("JSON ERROR DEFAULT")
                        break
                        
                    }
                    
                })
                
                break
                
            case .failure(let encoding_error):
                print("ERROR:", encoding_error.localizedDescription)
                break
                
            }
        })
        
    }
    
    // Test another upload
    func api_upload_v2(command: String, images: [String: UIImage], data: [String: Any], target_view: UIViewController, on_complete: @escaping (_ result: NSDictionary) -> Void){
        
        print("api_upload (v2)")
        let url = URL(string: self.api_base_command + command + ".php" )!
        
        var data = data
        data.updateValue("DBGTOKEN", forKey: "token")

        print("DATA FOR POST:", data)
        print("AF START")
        Alamofire.upload(
            multipartFormData: { MultipartFormData in
                //    multipartFormData.append(imageData, withName: "user", fileName: "user.jpg", mimeType: "image/jpeg")
                
                // Add data to form
                for (key, value) in data {
                    /*
                    if let cast = value as? String{
                        let value_string = cast
                    }else if let cast = value as? Int{
                        let value_string = String(cast)
                    }
                    */
                    let val_str = String(describing: value);
                    MultipartFormData.append(val_str.data(using: String.Encoding.utf8)!, withName: key)
                }
                
                // Add images to form
                var fileindex = 0
                for (key, image) in images{
                    print("IMAGE FOR FORM", image)
                    MultipartFormData.append(UIImageJPEGRepresentation(image, 1)!, withName: "\(key)", fileName: "\(key).jpeg", mimeType: "image/jpeg")
                    fileindex += 1
                }
                
                //MultipartFormData.append(UIImageJPEGRepresentation(UIImage(named: "1.png")!, 1)!, withName: "file2", fileName: "swift_file.jpeg", mimeType: "image/jpeg")
                print("FORM DATA:", MultipartFormData)
                
        }, to: url) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                print("REQUEST SUCCESS")
                
                upload.responseJSON { response in
                    print("UPLOAD RESPONSE", response)
                    on_complete(response.result.value as! NSDictionary)
                    //print(response.result.value)
                }
                
            case .failure(let encodingError):
                print("REQUEST FAIL", encodingError)
                break
            }
            
            
        }
        
    }
    
    // Base END
    
    
    
    ///////////////////////////////////
    
    
    
    // Send api request 'register new user'
    func api_register_user(email: String, password: String, first_name: String, last_name: String, birthday: String, gender: String, target_view: UIViewController, on_complete: @escaping (_ result:NSDictionary) -> Void){
        
        let data:[String:Any] = ["email":email as Any, "password":password as Any, "first_name":first_name as Any, "last_name":last_name as Any, "birthday":birthday as Any, "gender":gender as Any]
        
        self.api_send_request_2(command: "/register", data: data, target_view: target_view, on_complete: {result in
            print("ON COMPLETE")
            print(result)
            on_complete(result)
        })
    }
    
    func api_login_user(email: String, password: String, target_view: UIViewController, on_complete: @escaping (_ result: NSDictionary) -> Void){
        print("api_login_user start")
        let data:[String:Any] = ["email":email as Any, "password":password as Any]
        
        print("DATA: ", data)
        
        self.api_send_request_2(command: "/login", data: data, target_view: target_view, on_complete: { result in
            print("ON COMPLETE")
            print(result)
            on_complete(result)
        })
    }
    
    func api_search_user(current_user_id: String, search_value: String, target_view: UIViewController, on_complete: @escaping (_ result: NSDictionary) -> Void){
        
        print("api_search_user start")
        
        let search: [String: Any] = [
            "relation": "OR",
            "fields": [
                "1": [
                    "field": "first_name",
                    "value": search_value
                ],
                "2": [
                    "field": "last_name",
                    "value": search_value
                ]
            ]
        ]
        let data:[String:Any] = ["current_user_id":current_user_id, "search": search]
        
        print("$_POST", data)
        
        self.api_send_request_2(command: "/search_user", data: data, target_view: target_view, on_complete: { result in
            
            on_complete(result)
        })
        
    }
    
    func api_add_friend_request(current_user_id: String, target_user_id: String, target_view: UIViewController, on_complete: @escaping (_ result: NSDictionary) -> Void){
        
        let data:[String:Any] = ["current_user_id":current_user_id, "target_user_id": target_user_id]
        
        self.api_send_request_2(command: "/add_friend_request", data: data, target_view: target_view, on_complete: { result in
            
            on_complete(result)
        })
    }
    
    // Remove own sent friend request
    func api_delete_friend_request(current_user_id: String, target_user_id: String, target_view: UIViewController, on_complete: @escaping (_ result: NSDictionary) -> Void){
        
        let data:[String:Any] = ["current_user_id":current_user_id, "target_user_id": target_user_id]
        
        self.api_send_request_2(command: "/delete_friend_request", data: data, target_view: target_view, on_complete: { result in
            
            on_complete(result)
        })
    }
    
    func api_get_friends(user_id: String, offset: Int, limit: Int, target_view: UIViewController, on_complete: @escaping (_ result:NSDictionary) -> Void)
    {
        print("api_get_friend_requests START")
        let data:[String:Any] = ["user_id": user_id, "offset": offset, "limit": limit]
        
        self.api_send_request_2(command: "/get_friends", data: data, target_view: target_view, on_complete: {result in
            on_complete(result)
        })
    }
    
    func api_get_friend_requests(current_user_id: String, offset: Int, limit: Int, target_view: UIViewController, on_complete: @escaping (_ result:NSDictionary) -> Void)
    {
        print("api_get_friend_requests START")
        let data:[String:Any] = ["user_id": current_user_id, "offset": offset, "limit": limit]
        
        self.api_send_request_2(command: "/get_friend_requests", data: data, target_view: target_view, on_complete: {result in
            on_complete(result)
        })
    }
    
    func api_get_friend_recommended(current_user_id: String, offset: Int, limit: Int, target_view: UIViewController, on_complete: @escaping (_ result:NSDictionary) -> Void)
    {
        print("api_get_friend_recommended START")
        let data:[String:Any] = ["current_user_id": current_user_id, "offset": offset, "limit": limit]
        
        self.api_send_request_2(command: "/get_recommended_users", data: data, target_view: target_view, on_complete: {result in
            on_complete(result)
        })
    }
    
    func api_confirm_friend_request(current_user_id: String, friend_id: String, target_view: UIViewController, on_complete: @escaping (_ result:NSDictionary) -> Void)
    {
        print("api_confirm_friend_request START")
        let data:[String:Any] = ["current_user_id": current_user_id, "friend_id": friend_id]
        
        self.api_send_request_2(command: "/friend_accept", data: data, target_view: target_view, on_complete: {result in
            on_complete(result)
        })
    }
    
    func api_decline_friend_request(current_user_id: String, friend_id: String, target_view: UIViewController, on_complete: @escaping (_ result:NSDictionary) -> Void)
    {
        print("api_confirm_friend_request START")
        let data:[String:Any] = ["current_user_id": current_user_id, "friend_id": friend_id]
        
        self.api_send_request_2(command: "/friend_decline", data: data, target_view: target_view, on_complete: {result in
            on_complete(result)
        })
    }
    
    func api_delete_friend(current_user_id: String, friend_id: String, target_view: UIViewController, on_complete: @escaping (_ result:NSDictionary) -> Void)
    {
        print("api_delete_friend START")
        let data:[String:Any] = ["current_user_id": current_user_id, "friend_id": friend_id]
        
        self.api_send_request_2(command: "/friend_delete", data: data, target_view: target_view, on_complete: {result in
            on_complete(result)
        })
    }
    
    
    func api_add_follow(current_user_id: String, target_user_id: String, target_view: UIViewController, on_complete: @escaping (_ result: NSDictionary) -> Void){
        
        let data:[String:Any] = ["current_user_id":current_user_id, "target_user_id": target_user_id]
        
        self.api_send_request_2(command: "/follow", data: data, target_view: target_view, on_complete: { result in
            
            on_complete(result)
        })
    }
    
    func api_delete_follow(current_user_id: String, target_user_id: String, target_view: UIViewController, on_complete: @escaping (_ result: NSDictionary) -> Void){
        
        let data:[String:Any] = ["current_user_id":current_user_id, "target_user_id": target_user_id]
        
        self.api_send_request_2(command: "/unfollow", data: data, target_view: target_view, on_complete: { result in
            
            on_complete(result)
        })
    }
    
    func api_upload_image_of_type(user_id: Int, type: String, images: [String: UIImage], target_view: UIViewController, on_complete: @escaping (_ result:NSDictionary) -> Void){
        print("api_upload_image_of_type START")
        let data:[String:Any] = ["id": user_id, "type": type]
        self.api_upload_v2(command: "/upload_image", images: images, data: data, target_view: target_view, on_complete: {(result) in
            on_complete(result)
        })
    }
    
    func delete_image_of_type(user_id: String, type: String, target_view: UIViewController, on_complete: @escaping (_ result:NSDictionary) -> Void){
        let data:[String:Any] = ["id": user_id, "type": type]
        self.api_send_request_2(command: "/delete_image", data: data, target_view: target_view, on_complete: {result in
            on_complete(result)
        })
    }
    
    func api_update_biography(user_id: String, text: String, target_view: UIViewController, on_complete: @escaping (_ result:NSDictionary) -> Void){
        
        let data:[String:Any] = ["id": user_id, "text": text]
        
        self.api_send_request_2(command: "/update_biography", data: data, target_view: target_view, on_complete: {result in
            on_complete(result)
        })
        
    }
    
    // Send API request to create a post
    func api_create_post(user_id: String, text: String, image: UIImage?, target_view: UIViewController, on_complete: @escaping (_ result:NSDictionary) -> Void){
        print("api_create_post START")
        let data:[String:Any] = ["id": user_id, "text": text]
        if(image != nil){
            print("api_create_post->no image")
            let images = ["file0": image!]
            self.api_upload_v2(command: "/create_post", images: images, data: data, target_view: target_view, on_complete: {(result) in
                on_complete(result)
            })
        }else{
            print("api_create_post->with image")
            self.api_send_request_2(command: "/create_post", data: data, target_view: target_view, on_complete: {(result) in
                on_complete(result)
            })
        }
        
    }
    
    // API Get posts by user id
    func api_get_posts(user_id: String, limit: Int, offset: Int, target_view: UIViewController, on_complete: @escaping (_ result:NSDictionary) -> Void)
    {
        guard let current_user_id = current_user["user_id"] as? String else{
            self.show_alert_ok(title: "Error", message: "No current user", target_view: target_view)
            return
        }
        let data:[String:Any] = ["id": user_id, "current_user_id": current_user_id, "offset": offset, "limit": limit]
        
        self.api_send_request_2(command: "/get_posts", data: data, target_view: target_view, on_complete: {result in
            on_complete(result)
        })
    }
    
    // API Get posts by user id
    func api_get_feed_posts(user_id: String, limit: Int, offset: Int, target_view: UIViewController, on_complete: @escaping (_ result:NSDictionary) -> Void)
    {

        let data:[String:Any] = ["user_id": user_id, "offset": offset, "limit": limit]
        
        self.api_send_request_2(command: "/get_posts_for_feed", data: data, target_view: target_view, on_complete: {result in
            on_complete(result)
        })
    }
    
    // Send request to delete post
    func api_delete_post(current_user_id: String, post_id: String, target_view: UIViewController, on_complete: @escaping (_ result: NSDictionary) -> Void){
        
        let data:[String:Any] = ["current_user_id": current_user_id, "post_id": post_id]
        
        self.api_send_request_2(command: "/delete_post", data: data, target_view: target_view, on_complete: {result in
            on_complete(result)
        })
    }
    
    // Send API request to create a post
    func api_update_user_info(user_id: String, email: String, password: String = "", first_name: String, last_name: String, birthday: String, gender: String, allow_friends: String, allow_follow: String,  cover: UIImage?, is_cover_deleted: Bool, avatar: UIImage?, is_avatar_deleted: Bool, target_view: UIViewController, on_complete: @escaping (_ result:NSDictionary) -> Void)
    {
        print("api_update_user_info START")
        var data:[String:Any] = ["id": user_id, "email": email, "first_name": first_name, "last_name": last_name, "birthday": birthday, "gender": gender, "allow_friends": allow_friends, "allow_follow": allow_follow]
        if(password != ""){
            data["password"] = password
        }
        
        var images = [String: UIImage]()
        if(cover != nil){
            images["cover"] = cover!
        }
        if(avatar != nil){
            images["avatar"] = avatar!
        }
        data["is_cover_deleted"] = is_cover_deleted
        data["is_avatar_deleted"] = is_avatar_deleted
        
        api_upload_v2(command: "/update_profile", images: images, data: data, target_view: target_view, on_complete: {result in
            on_complete(result)
        })
        
    }
    
    func api_like(current_user_id: String, post_id: Int, user_id: String, action: String, target_view: UIViewController, on_complete: @escaping (_ result:NSDictionary) -> Void)
    {
        print("api_like START")
        let data:[String:Any] = ["current_user_id": current_user_id, "post_id": post_id, "user_id": user_id, "action": action]
        
        self.api_send_request_2(command: "/do_like", data: data, target_view: target_view, on_complete: {result in
            on_complete(result)
        })
    }
    
    func api_create_comment(current_user_id: String, post_id: Int, user_id: String, text: String, target_view: UIViewController, on_complete: @escaping (_ result:NSDictionary) -> Void)
    {
        print("api_create_comment START")
        let data:[String:Any] = ["current_user_id": current_user_id, "post_id": post_id, "user_id": user_id, "text": text]
        
        self.api_send_request_2(command: "/create_comment", data: data, target_view: target_view, on_complete: {result in
            on_complete(result)
        })
    }
    
    func api_delete_comment(current_user_id: String, comment_id: String, user_id: String, target_view: UIViewController, on_complete: @escaping (_ result:NSDictionary) -> Void){
    
        print("api_delete_comment START")
        let data:[String:Any] = ["current_user_id": current_user_id, "comment_id": comment_id]
        
        self.api_send_request_2(command: "/delete_comment", data: data, target_view: target_view, on_complete: {result in
            on_complete(result)
        })
        
    }
    
    // Get comment for post by post_id
    func api_get_posts_comments_by_post_id(current_user_id: String, post_id: Int, offset: Int, limit: Int, target_view: UIViewController, on_complete: @escaping (_ result:NSDictionary) -> Void){
        print("api_get_posts_comments_by_post_id START")
        let data:[String:Any] = ["user_id": current_user_id, "post_id": post_id, "offset": offset, "limit": limit, "orderby": "date_created", "order": "DESC"]
        
        self.api_send_request_2(command: "/get_comments_by_post", data: data, target_view: target_view, on_complete: {result in
            on_complete(result)
        })
    }
    
    // Add report
    func api_add_report(current_user_id: String, user_id: String, post_id: String, reason: String, target_view: UIViewController, on_complete: @escaping (_ result: NSDictionary) -> Void){
        
        let data:[String:Any] = ["current_user_id":current_user_id, "user_id": user_id, "post_id": post_id, "reason": reason]
        
        self.api_send_request_2(command: "/add_report", data: data, target_view: target_view, on_complete: { result in
            
            on_complete(result)
        })
    }
    
    func api_get_notifications(current_user_id: String, type: String, offset: Int, limit: Int, target_view: UIViewController, on_complete: @escaping (_ result: NSDictionary) -> Void){
        
        let data:[String:Any] = ["current_user_id":current_user_id, "type": type, "offset": offset, "limit": limit]
        
        self.api_send_request_2(command: "/get_notifications", data: data, target_view: target_view, on_complete: { result in
            
            on_complete(result)
        })
    }
    
    // MARK: - CHAT
    
    func api_chat_get(user_id: String, offset: Int, limit: Int, target_view: UIViewController, on_complete: @escaping (_ result:NSDictionary) -> Void)
    {
        print("api_get_friend_recommended START")
        let data:[String:Any] = ["user_id": user_id, "offset": offset, "limit": limit]
        
        self.api_send_request_2(command: "/chat/chat_get", data: data, target_view: target_view, on_complete: {result in
            on_complete(result)
        })
    }
    
    func api_chat_messages_get(chat_id: String, user_id: String, user2_id: String = "-1", offset: Int, limit: Int, order: String, last_id: String = "", target_view: UIViewController, on_complete: @escaping (_ result:NSDictionary) -> Void)
    {
        print("api_chat_messages_get START")
        let data:[String:Any] = ["chat_id": chat_id, "user_id": user_id, "user2_id": user2_id, "offset": offset, "limit": limit, "order": order, "last_id": last_id]
        
        self.api_send_request_2(command: "/chat/messages_get", data: data, target_view: target_view, on_complete: {result in
            on_complete(result)
        })
    }
    
    func api_chat_message_add(chat_id: String, user_id: String, type: String, content: String, target_view: UIViewController, on_complete: @escaping (_ result:NSDictionary) -> Void)
    {
        print("api_chat_message_add START")
        let data:[String:Any] = ["chat_id": chat_id, "user_id": user_id, "type": type, "content": content]
        
        self.api_send_request_2(command: "/chat/message_add", data: data, target_view: target_view, on_complete: {result in
            on_complete(result)
        })
    }
    
    // MARK: - 
    
    
    func api_update_notification(current_user_id: String, notification_id: String, viewed: String, target_view: UIViewController, on_complete: @escaping (_ result: NSDictionary) -> Void){
        
        let data:[String:Any] = ["current_user_id":current_user_id, "notification_id": notification_id, "viewed": viewed]
        
        self.api_send_request_2(command: "/update_notification", data: data, target_view: target_view, on_complete: { result in
            
            on_complete(result)
        })
    }
    
    /****************** API END ******************/
    /****************** VISUALS ******************/
    
    func add_border(target_view: UIView, width: CGFloat, color: CGColor){
        let border = CALayer()
        border.borderColor = color
        border.borderWidth = width
        border.frame = CGRect(x: 0, y: 0, width: target_view.frame.width, height: target_view.frame.height)
        target_view.layer.addSublayer(border)
    }
    
    /**************** VISUALS END ****************/
    
    /**************** IMAGE TOOLS ****************/
    func image_fit_to_size_if_bigger(image: UIImage, width: Int, height: Int){
        
    }
    /************** IMAGE TOOLS END **************/
    
}
