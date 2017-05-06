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
        
    }
    
    func request(url: String, callback: @escaping ([String:String]) -> Void) {
        NSLog("request by url and callback")
        var request: URLRequest?
        if let url = URL(string: url) {
            request = URLRequest(url: url)
            request?.httpMethod = "GET"
        }
        let session = URLSession.shared
        
        guard let req = request else {
            return
        }
        
        session.dataTask(with: req) { data, response, error in
            if error == nil {
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! NSDictionary
                    
                    let jsonDic = jsonToDic(json: json)
                    
                    callback(jsonDic)
                    
                } catch let error as NSError {
                    print(error)
                }
            } else {
                NSLog("Error while request")
            }
        }.resume()
    }
    
    func request(contentInfo: ContentInfo) {
        var request = URLRequest(url: URL(string: "http://lionbot.net/weather")!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, error in
            print(String(describing: data) + String(describing: response))
            if(error != nil){
                print("error")
            } else {
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! NSDictionary
                    
                    let jsonDic = jsonToDic(json: json)
                    
                    var weatherImageName: String!
                    var weatherName: String!
                    var currentTemperature: String!
                    var highestTemperature: String!
                    var lowestTemperature: String!
                    
                    if let code4hour = jsonDic["code4hour"],
                       let name4hour = jsonDic["name4hour"],
                       let temp4hour = jsonDic["temp4hour"],
                       let tmax1day = jsonDic["tmax1day"],
                       let tmin1day = jsonDic["tmin1day"] {
                        weatherImageName = code4hour
                        weatherName = name4hour
                        currentTemperature = temp4hour
                        highestTemperature = tmax1day
                        lowestTemperature = tmin1day
                    }
                    
                    contentInfo.subviews?[0].subviews?[0].image = UIImage(named: weatherImageName)
                    contentInfo.subviews?[0].subviews?[1].text = currentTemperature!.components(separatedBy: ".")[0] + "˚"
                    contentInfo.subviews?[0].subviews?[2].text = weatherName
                    
                    
                    DispatchQueue.main.async {
                        self.delegate?.addContent(contentInfo: contentInfo)
                    }
                    
                } catch let error as NSError {
                    print(error)
                }
            }
        }.resume()
    }
}



func jsonToDic(json: NSDictionary) -> [String:String] {
    var jsonDic: NSMutableDictionary = [:]
    
    func parseJson(_ json: NSDictionary) {
        for element in json {
            if json[element.key] is String? {
                jsonDic[element.key] = (json[element.key] as! String)
            }
            else if json[element.key] is NSNumber {
                jsonDic[element.key] = String(json[element.key] as! Double)
            }
            else if json[element.key] is [Any] {
                for i in (json[element.key] as! [Any]) {
                    parseJson(i as! NSDictionary)
                }
            }
            else if json[element.key] is [String:Any] {
                parseJson(json[element.key] as! NSDictionary)
            }
            else {
                print(String(describing: element))
            }
        }
    }
    parseJson(json)
    return jsonDic as! [String:String]
}
