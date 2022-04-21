//
//  ViewModel.swift
//  Gweather
//
//  Created by Mohsin Qureshi on 19/04/2022.
//

import Alamofire
import MapKit

protocol weatherDelegate{
    func ApiData(com: ([WeatherData]))
}


class ViewModel {
    
    var delegate: weatherDelegate?
    func weatherApiData(latitude: CLLocationDegrees,longitude: CLLocationDegrees){
        let apid = "b5802ce387de00e426ebc26278650651"
        let params = [
            "lat":"\(latitude)",
            "lon":"\(longitude)",
            "appid":"\(apid)"
        ]
        var urlParams = ""
        urlParams = params.compactMap({ (key, value) -> String in
            return "\(key)=\(value)"
        }).joined(separator: "&")
        
        APIManager.fetchApiGetData(APIMethodName: APIEndPointName.weather.rawValue, showLoader: true, server: 1, Params: urlParams) { (res: WeatherData?, err : String?) in
            
            guard let data = res else { return }
            self.delegate?.ApiData(com: [data])
        }
    }
}
