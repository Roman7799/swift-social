// TODO: Change regex for validation

import UIKit
import Alamofire


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
    
    /***************** INTERFACE *****************/
    
    func configure_avatar_post(element: UIView){
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
        
        
        print(api_send_request_2)
        let url = URL(string: self.api_base_command + command + ".php" )!
        var data = data
        data.updateValue("DBGTOKEN", forKey: "token")
        print("DATA FOR POST:", data)
        
        print("AF START")
        let request = Alamofire.request(url, method: .post, parameters: data)
        request.validate()
        request.responseJSON{ (response)->Void in
            print("AF RESPONSE:", response)
            switch response.result {
            case .success(let data as NSDictionary):
                print(data)
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
    
    func api_upload(command: String, image: UIImage, data: [String: Any], target_view: UIViewController, on_complete: @escaping (_ result: NSDictionary) -> Void){
        
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
                form_data.append(json as Data, withName: "json")
                
            }catch{
                print("JSON SERIALIZATION FAILED")
                return
            }
            
            if let image_data = image.jpegData(compressionQuality: 0.7){
                form_data.append(image_data, withName: "file")
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
                form_data.append(json as Data, withName: "json")
                
            }catch{
                print("JSON SERIALIZATION FAILED")
                return
            }
            
            for (key, image) in images{
                if let image_data = image.jpegData(compressionQuality: 0.7){
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
    
    func api_upload_image_of_type(user_id: Int, type: String, image: UIImage, target_view: UIViewController, on_complete: @escaping (_ result:NSDictionary) -> Void){
        print("api_upload_image_of_type START")
        let data:[String:Any] = ["id": user_id, "type": type]
        self.api_upload(command: "/upload_image", image: image, data: data, target_view: target_view, on_complete: {(result) in
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
            self.api_upload(command: "/create_post", image: image!, data: data, target_view: target_view, on_complete: {(result) in
                on_complete(result)
            })
        }else{
            self.api_send_request_2(command: "/create_post", data: data, target_view: target_view, on_complete: {(result) in
                on_complete(result)
            })
        }
        
    }
    
    // API Get posts by user id
    func api_get_posts(user_id: String, limit: Int, offset: Int, target_view: UIViewController, on_complete: @escaping (_ result:NSDictionary) -> Void)
    {
        let data:[String:Any] = ["id": user_id, "offset": offset, "limit": limit]
        
        self.api_send_request_2(command: "/get_posts", data: data, target_view: target_view, on_complete: {result in
            on_complete(result)
        })
    }
    
    // Send API request to create a post
    func api_update_user_info(user_id: String, password: String = "", first_name: String, last_name: String, birthday: String, gender: String, cover: UIImage?, is_cover_deleted: Bool, avatar: UIImage?, is_avatar_deleted: Bool, target_view: UIViewController, on_complete: @escaping (_ result:NSDictionary) -> Void)
    {
        print("api_create_post START")
        var data:[String:Any] = ["id": user_id, "first_name": first_name, "last_name": last_name, "birthday": birthday, "gender": gender]
        if(password != ""){
            data["password"] = password
        }
        
        var images = [String: UIImage]()
        if(cover == nil){
            images["cover"] = cover!
        }
        if(avatar == nil){
            images["avatar"] = avatar!
        }
        data["is_cover_deleted"] = is_cover_deleted
        data["is_avatar_deleted"] = is_avatar_deleted
        
        api_upload(command: "/update_profile", images: images, data: data, target_view: target_view, on_complete: {result in
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
    
    func api_get_posts_comments_by_post_id(post_id: Int, offset: Int, limit: Int, target_view: UIViewController, on_complete: @escaping (_ result:NSDictionary) -> Void){
        print("api_get_posts_comments_by_post_id START")
        let data:[String:Any] = ["post_id": post_id, "offset": offset, "limit": limit]
        
        self.api_send_request_2(command: "/get_comments_by_post", data: data, target_view: target_view, on_complete: {result in
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
