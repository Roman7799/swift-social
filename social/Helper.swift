// TODO: Change regex for validation

import UIKit
import Alamofire


class Helper{
    var api_base_url: String
    var api_base_command: String
    
    init(){
        self.api_base_url = "http://swift-social.pria.digital"
        self.api_base_command = self.api_base_url + "/command"
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
    
    /****************** API END ******************/
    
}
