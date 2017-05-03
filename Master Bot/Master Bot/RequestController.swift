//
//  RequestController.swift
//  Master Bot
//
//  Created by Sang Chul Lee on 2017. 5. 4..
//  Copyright © 2017년 SC_production. All rights reserved.
//

import Foundation
import UIKit

protocol RequestControllerDelegate {
    func addContent(contentInfo: ContentInfo)
}

class RequestController {
    
    var url: URL?
    var delegate: ContentsController?
    
    init() {
        NSLog("request controller!!")
    }
    
    func request(contentInfo: ContentInfo) {
        var contentInfo = contentInfo
        NSLog("REQUEST!!!")
        var request = URLRequest(url: URL(string: "http://lionbot.net/weather")!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, error in
            print(String(describing: data) + String(describing: response))
            if(error != nil){
                print("error")
            }else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String:Any]
                    
                    print(String(describing: ((((json["weather"] as! [String:Any])["forecast3days"] as! [Any])[0] as! [String:Any])["fcst3hour"] as! [String:[String:String]])["sky"]?["code4hour"]))
                    print(String(describing: ((((json["weather"] as! [String:Any])["forecast3days"] as! [Any])[0] as! [String:Any])["fcst3hour"] as! [String:[String:String]])["temperature"]?["temp4hour"]))
                    print(String(describing: (((((json["weather"] as! [String:Any])["forecast3days"] as! [Any])[0] as! [String:Any])["fcstdaily"] as! [String:[String:String]])["temperature"]?["tmax1day"])))
                    print(String(describing: ((((json["weather"] as! [String:Any])["forecast3days"] as! [Any])[0] as! [String:Any])["fcstdaily"] as! [String:[String:String]])["temperature"]?["tmin1day"]))
                    
                    var weather: String = (((((json["weather"] as! [String:Any])["forecast3days"] as! [Any])[0] as! [String:Any])["fcst3hour"] as! [String:[String:String]])["sky"]?["code4hour"])!
                    weather.remove(at: weather.startIndex)
                    var weatherImageName: String = weather.substring(from: weather.characters.index(of: "S")!).lowercased()
                    NSLog(weatherImageName)
                    let currentTemperature = ((((json["weather"] as! [String:Any])["forecast3days"] as! [Any])[0] as! [String:Any])["fcst3hour"] as! [String:[String:String]])["temperature"]?["temp4hour"]!
                    
                    let highestTemperature = ((((json["weather"] as! [String:Any])["forecast3days"] as! [Any])[0] as! [String:Any])["fcstdaily"] as! [String:[String:String]])["temperature"]?["tmax1day"]!
                    
                    let lowestTemperature = ((((json["weather"] as! [String:Any])["forecast3days"] as! [Any])[0] as! [String:Any])["fcstdaily"] as! [String:[String:String]])["temperature"]?["tmin1day"]!
                    
                    contentInfo.subviews?[0].subviews?[0].image = UIImage(named: weatherImageName)
                    contentInfo.subviews?[0].subviews?[1].text = currentTemperature! + "도"
                    DispatchQueue.main.async {
                        self.delegate?.addContent(contentInfo: contentInfo)
                    }
                    
                    
                }catch let error as NSError{
                    print(error)
                }
            }
        }.resume()
    }
}
