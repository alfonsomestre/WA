//
//  WeatherResponse.swift
//  WA
//
//  Created by Alfonso Mestre on 2/24/19.
//  Copyright © 2019 Alfonso Mestre. All rights reserved.
//

import ObjectMapper

class ForecastResponse : Mappable {
    
    var weather: [Weather]?
    var message : String = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        weather <- map["list"]
        message <- map["message"]
    }
}
