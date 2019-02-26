//
//  Config.swift
//  WA
//
//  Created by Alfonso Mestre on 2/22/19.
//  Copyright © 2019 Alfonso Mestre. All rights reserved.
//

import UIKit

class Config: NSObject {
    
    // MARK: - Singleton
    
    static let sharedInstance = Config()
    
    var config: NSDictionary?
    
    private override init() {
        
        let path = Bundle.main.path(forResource: "Config", ofType: "plist")!
        
        self.config = NSDictionary(contentsOfFile: path)?.object(forKey: "Config") as? NSDictionary
    }
    
    func servicesURL() -> String {
        return self.config?.object(forKey: "ServicesURL") as? String ?? ""
    }
    
    func apiKey() -> String {
        return self.config?.object(forKey: "APIKey") as? String ?? ""
    }
    
    func imagePath() -> String {
        return self.config?.object(forKey: "imagesURL") as? String ?? ""
    }
    
    
}
