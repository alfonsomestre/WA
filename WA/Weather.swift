//
//  Weather.swift
//  WA
//
//  Created by Alfonso Mestre on 2/24/19.
//  Copyright © 2019 Alfonso Mestre. All rights reserved.
//

import Foundation
import ObjectMapper

class Weather : NSObject, Mappable{
    
    var maxTemp : Double = 0
    var minTemp : Double = 0
    var cityName : String = ""
    var weatherDesc : String = ""
    var currentTemp : Double = 0
    var imgIcon : String = ""
    var dt_txt : String = ""
    var dt : Double = 0
    var windSpeed : Double = 0
    var humidity : Double = 0
    var pressure : Double = 0
    var sunrise : Double = 0
    var sunset : Double = 0
    var message : String = ""

    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        
        maxTemp <- map["main.temp_max"]
        minTemp <- map["main.temp_min"]
        cityName <- map["name"]
        weatherDesc <- map["weather.0.description"]
        imgIcon <- map["weather.0.icon"]
        currentTemp <- map["main.temp"]
        dt_txt <- map["dt_txt"]
        dt <- map["dt"]
        windSpeed <- map["wind.speed"]
        humidity <- map["main.humidity"]
        sunrise <- map["sys.sunrise"]
        sunset <- map["sys.sunset"]
        pressure <- map["main.pressure"]
        message <- map["message"]
        
    }
}
