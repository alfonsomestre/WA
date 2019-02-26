//
//  APIHelper.swift
//  WA
//
//  Created by Alfonso Mestre on 2/24/19.
//  Copyright © 2019 Alfonso Mestre. All rights reserved.
//

import Foundation
import NotificationBannerSwift

class APIHelper{
    
    // MARK: - Singleton
    static let sharedInstance = APIHelper()
    
    lazy var errorBanner = NotificationBanner(title: "", style: .danger)
    
    func getCityQueryParameters(withCity city: String, withMetrics metrics : String) -> [URLQueryItem]{
        var queryItems : [URLQueryItem] = []
        
        if city != ""{
            if city == "Montevideo"{
                // WA For other city named Montevideo
                queryItems.append(URLQueryItem(name: "q", value: "\(city),uy"))
            }else{
                queryItems.append(URLQueryItem(name: "q", value: city))
            }
            
        }
        
        queryItems.append(URLQueryItem(name: "units", value: metrics))
        queryItems.append(URLQueryItem(name: "appId", value: Config.sharedInstance.apiKey()))
        
        return queryItems
    }
    
    func getCoordQueryParameters(withLat lat : Double,withLong long : Double, withMetrics metrics : String) -> [URLQueryItem]{
        
        var queryItems : [URLQueryItem] = []
        
        if lat != 0 && long != 0{
            queryItems.append(URLQueryItem(name: "lat", value: "\(lat)"))
            queryItems.append(URLQueryItem(name: "lon", value: "\(long)"))
        }
        
        queryItems.append(URLQueryItem(name: "units", value: metrics))
        queryItems.append(URLQueryItem(name: "appId", value: Config.sharedInstance.apiKey()))
        
        return queryItems
    }
    
    func showErrorMessage(with title : String){
        NotificationBannerQueue.default.removeAll()
        if !errorBanner.isDisplaying{
            errorBanner.titleLabel?.text = title
            errorBanner.duration = 20
            errorBanner.show()
        }
    }
}
