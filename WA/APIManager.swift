//
//  APIManager.swift
//  WA
//
//  Created by Alfonso Mestre on 2/24/19.
//  Copyright © 2019 Alfonso Mestre. All rights reserved.
//

import Alamofire
import AlamofireObjectMapper
import RxSwift

class APIManager{
    
    // MARK: - Singleton
    static let sharedInstance = APIManager()
    
    lazy var servicesURL = Config.sharedInstance.servicesURL()
    
    let errorMsg = NSLocalizedString("Error de conexión con los servicios. Intente de nuevo más tarde.", comment: "")
    
    
    
    func getCurrentWeather(withQueryItems queryItems: [URLQueryItem])-> Observable<Weather> {
        
        var urlParameters = URLComponents(string : self.servicesURL + Endpoints.currentWeather)!
        urlParameters.queryItems = queryItems

        return Observable.create({
            
            (observer) -> Disposable in
            
            let request = Alamofire.request(urlParameters.url!, method: .get, parameters: nil,
                                            encoding: JSONEncoding.default,
                                            headers: nil).responseObject { (response: DataResponse<Weather>) in
                                                
                                                switch response.result {
                                                case .success(_):
                                                    if let responseValue = response.result.value {
                                                        //switch responseValue.result {
                                                        //case true:
                                                        if responseValue.cityName != ""{
                                                            observer.onNext(responseValue)
                                                            break
                                                        }else{
                                                            APIHelper.sharedInstance.showErrorMessage(with: responseValue.message)
                                                            
                                                        }
                                                    }
                                                case .failure(_):
                                                    if let error = response.error{
                                                        APIHelper.sharedInstance.showErrorMessage(with: error.localizedDescription)
                                                    }
                                                    observer.onError(NSError(domain: self.errorMsg, code: -1, userInfo: nil))
                                                    break
                                                }
            }
            
            return Disposables.create{
                request.cancel()
            }
            
        })
        
    }
    
    func getForecast(withQueryItems queryItems: [URLQueryItem])-> Observable<[Weather]> {
        
        var urlParameters = URLComponents(string : self.servicesURL + Endpoints.forecast)!
        urlParameters.queryItems = queryItems
        
        return Observable.create({
            
            (observer) -> Disposable in
            
            let request = Alamofire.request(urlParameters.url!, method: .get, parameters: nil,
                                            encoding: JSONEncoding.default,
                                            headers: nil).responseObject { (response: DataResponse<ForecastResponse>) in
                                                
                                                switch response.result {
                                                case .success(_):
                                                    if let responseValue = response.result.value {
                                                        //switch responseValue.result {
                                                        //case true:
                                                        if let forecast = responseValue.weather{
                                                            observer.onNext(forecast)
                                                            break
                                                        }else{
                                                            APIHelper.sharedInstance.showErrorMessage(with: responseValue.message)
                                                            
                                                        }
                                                    }
                                                case .failure(_):
                                                    if let error = response.error{
                                                        APIHelper.sharedInstance.showErrorMessage(with: error.localizedDescription)
                                                    }
                                                    observer.onError(NSError(domain: self.errorMsg, code: -1, userInfo: nil))
                                                    break
                                                }
            }
            
            return Disposables.create{
                request.cancel()
            }
            
        })
        
    }
    
}
