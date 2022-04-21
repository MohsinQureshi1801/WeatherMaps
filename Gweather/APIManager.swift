//
//  APIManager.swift
//  IdeationApp
//
//  Created by Mohsin Qureshi on 07/09/2021.
//

import Foundation
import Alamofire
import SVProgressHUD

struct APIPath {
    static let BaseURL1 = "https://api.openweathermap.org/data/2.5/weather?"
}

//new commit
//MARK: - API Method Names
enum APIEndPointName: String
{
    case weather = ""
}


class APIManager {
    
    static func fetchApiGetData<T: Decodable>(APIMethodName : String, showLoader: Bool, server: Int, Params: String, completion: @escaping (T?, String?) -> ()) {
        
        var  url =  ""
        if server == 1{
            url = "\(APIPath.BaseURL1)\(APIMethodName)\(Params)"
        }
        if showLoader{
            APIManager.showLoader()
        }
        
        Alamofire.request(url).responseJSON
        { response in
            APIManager.hideLoader()
            debugPrint("debugPrint",response)
            if let status = response.response?.statusCode {
                switch(status){
                case 200:
                    if response.result.value != nil {
                        do {
                            let obj = try JSONDecoder().decode(T.self, from: response.data!)
                            completion(obj, nil)
                        }catch{
                            completion(nil, "No Responce...")
                        }
                        
                    }else {
                        completion(nil, nil)
                        print("***====*** No JSON Data")
                    }
                case 401:
                    completion(nil, nil)
                    print("401: Session Expied")
                default:
                    completion(nil, nil)
                    print("-=-=-=-= Error: in API Path")
                }
                
            } else {
                completion(nil, nil)
                print("=-=-=-=-=-Error:  No Response from API / no internet connection ")
            }
        }
    }//end generic function
    
    
    //MARK: - Form Data API Method
    static func FormDataPostAPI<T: Decodable>(APIMethodName : String,server: Int, DictParam : [String: String], completion: @escaping (T?, String) -> ()) {
        
        var  url =  ""
        if server == 1{
            url = "\(APIPath.BaseURL1)\(APIMethodName)"
        }
        
        
        print("-=-=-=-parameters -=-=-=")
        print(DictParam)
        print(url)
        
        Alamofire.upload(
            multipartFormData: { MultipartFormData in
                for (key, value) in DictParam {
                    MultipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
            }, to: url) { (response) in
                
                print("-=-=-=-  Debug Print Result -=-=-=")
                debugPrint("MY_RESPONSE",response)
                
                switch response {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        
                        debugPrint(response)
                        
                        if let status = response.response?.statusCode {
                            switch(status){
                            case 200:
                                
                                if response.result.value != nil {
                                    do {
                                        let obj = try JSONDecoder().decode(T.self, from: response.data!)
                                        completion(obj, "")
                                    }catch{
                                        
                                        print("*** === *** Error: While Paesing JSON")
                                        completion(nil, "")
                                    }
                                    
                                }else {
                                    completion(nil, "")
                                    print("***====*** No JSON Data")
                                }
                                
                                
                            default:
                                completion(nil,"")
                                print("***====*** Error:  No Response from API / no internet connection ")
                            }
                        }
                    }
                    
                case .failure(_):
                    completion(nil,"")
                }
            }
    }
    // MARK: - Show Loader
     static func showLoader() {
       
          DispatchQueue.main.async(execute: {() -> Void in
              //SVProgressHUD.setForegroundColor(UIColor(red:255/255.0, green:255.0/255.0, blue:255.0/255.0, alpha: 1))
               SVProgressHUD.setForegroundColor(#colorLiteral(red: 0.07843137255, green: 0.5019607843, blue: 0.7568627451, alpha: 1))
              SVProgressHUD.setRingThickness(5.0)
          
              SVProgressHUD.setBackgroundColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 0.66796875))
              SVProgressHUD.setRingThickness(3)
              SVProgressHUD.setBackgroundLayerColor(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 0.5772420805))
              //SVProgressHUD.st = SVProgressHUDStyleCustom
              SVProgressHUD.setRingNoTextRadius(5.0)
           
           SVProgressHUD.setOffsetFromCenter(UIOffset(horizontal: UIScreen.main.bounds.width / 2 , vertical: UIScreen.main.bounds.height / 2))
              SVProgressHUD.show(withStatus: "Loading...")
           
           
          })
      }
   
   
   
      // MARK: - Hide Loader
     static func hideLoader() {
          DispatchQueue.main.async(execute: {() -> Void in
              SVProgressHUD.dismiss()
          })
      }
}



