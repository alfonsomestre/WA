//
//  ViewController.swift
//  WA
//
//  Created by Alfonso Mestre on 2/24/19.
//  Copyright © 2019 Alfonso Mestre. All rights reserved.
//

import UIKit
import RxSwift
import CoreLocation
import SVProgressHUD

protocol PageControlDelegate: class {
    
    /**
     Called when the number of pages is updated.
     */
    func didUpdatePageCount(pageVC: PageViewController,
                                    didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     */
    func didUpdateIndex(pageVC: PageViewController,
                                    didUpdatePageIndex index: Int)
    
}

class WeatherVC: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var cityLabelOutlet: UILabel!
    @IBOutlet weak var descriptionLabelOutlet: UILabel!
    @IBOutlet weak var tempLabelOutlet: UILabel!
    @IBOutlet weak var todayLabelOutlet: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    
    // MARK: Properties
    
    //Rx dispose
    private let disposeBag = DisposeBag()
    
    var cityName : String = ""
    var showAlert : Bool = true
    
    var pageVC: PageViewController?
    var hourForecast : [Weather] = []
    var currentWeather : Weather?
    
    var lat : Double = 0
    var lon : Double = 0
    
    lazy var imageURL = Config.sharedInstance.imagePath()
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.configCollectionView()
        self.configureTableView()
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Activity indicator
        
        self.waiting()
        
        
        //Reuse
        self.clearVariables()
        
        // Current Location is the WA mark which is the gps VC
        if self.cityName != "currentLocation"{
            self.getCurrentWeatherForCity()
        }else{
            if lat == 0 && lon == 0{
              self.getLocation()
            }else{
               self.getWeatherByCoord(lat: self.lat, long: self.lon)
            }
        }
        
        
        
        self.pageVC?.pageControlDelegate = self
        
    }
    
    func clearVariables(){
        self.cityLabelOutlet.text = ""
        self.descriptionLabelOutlet.text = ""
        self.tempLabelOutlet.text = ""
        self.hourForecast = []
        self.currentWeather = nil
        
        self.collectionView.reloadData()
        self.tableView.reloadData()
    }
    
    func config(cityName : String){
        // Config properties
        self.cityName = cityName
        
    }
    
    func getLocation(){
        // Request location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
        }
    }
    
    // MARK: Config
    
    func configCollectionView(){
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ForecastCollectionViewCell", bundle: bundle)
        collectionView.register(nib, forCellWithReuseIdentifier: ForecastCollectionViewCell.identifier)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        
    }
    
    func configureTableView(){
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "InfoTableViewCell", bundle: bundle)
        self.tableView.register(nib, forCellReuseIdentifier: InfoTableViewCell.identifier)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    // Services
    func getCurrentWeatherForCity(){
        
        let request = APIManager.sharedInstance.getCurrentWeather(withQueryItems : APIHelper.sharedInstance.getCityQueryParameters(withCity: self.cityName, withMetrics: "metric"))
        request.subscribe({
            event in
            switch event{
            case .next(let weather):
                
                self.configureMainView(weather: weather)
                
            case .error(_):
                print("ERROR")
            case .completed:
                print("COMPLETED")
            }
        })
        .disposed(by: disposeBag)
        
        let forecast = APIManager.sharedInstance.getForecast(withQueryItems : APIHelper.sharedInstance.getCityQueryParameters(withCity: self.cityName, withMetrics: "metric"))
        forecast.subscribe({
            event in
            switch event{
            case .next(let forecast):
                
                self.hourForecast = Array(forecast[0...8])
                self.collectionView.reloadData()
                self.hideWaiting()
            case .error(_):
                print("ERROR")
            case .completed:
                print("COMPLETED")
            }
        })
            .disposed(by: disposeBag)

        
    }
    
    // Services
    func getWeatherByCoord(lat:Double, long : Double){
        
        self.waiting()
        let request = APIManager.sharedInstance.getCurrentWeather(withQueryItems : APIHelper.sharedInstance.getCoordQueryParameters(withLat: lat, withLong: long, withMetrics: "metric"))
        request.subscribe({
            event in
            switch event{
            case .next(let weather):
                
                self.configureMainView(weather: weather)
                
            case .error(_):
                self.hideWaiting()
                print("ERROR")
            case .completed:
                self.hideWaiting()
                print("COMPLETED")
            }
        })
        .disposed(by: disposeBag)
        
        let forecast = APIManager.sharedInstance.getForecast(withQueryItems : APIHelper.sharedInstance.getCoordQueryParameters(withLat: lat, withLong: long, withMetrics: "metric"))
        forecast.subscribe({
            event in
            switch event{
            case .next(let forecast):
                
                self.hourForecast = Array(forecast[0...8])
                self.collectionView.reloadData()
                self.hideWaiting()
            case .error(_):
                self.hideWaiting()
                print("ERROR")
            case .completed:
                self.hideWaiting()
                print("COMPLETED")
            }
        })
        .disposed(by: disposeBag)
    }
    
    
    // Set data
    func configureMainView(weather : Weather){
        self.cityLabelOutlet.text = weather.cityName
        self.descriptionLabelOutlet.text = weather.weatherDesc
        self.tempLabelOutlet.text = "\(weather.currentTemp)"
        
        let date = Date(timeIntervalSince1970: weather.dt)
        self.todayLabelOutlet.text = date.dayOfWeek()
        
        self.currentWeather = weather
        
        self.tableView.reloadData()
    }
    
    // Show AI and blur
    func waiting(){
        self.blurEffectView.isHidden = false
        SVProgressHUD.show(withStatus: "Waiting for the server")
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.clear)
    }
    
    // Hide AI and blur
    func hideWaiting(){
        self.blurEffectView.isHidden = true
        DispatchQueue.global(qos: .userInitiated).async {
            // Bounce back to the main thread to update the UI
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
        }
    }
    
    // Show alert when get location fails
    func showConfigAlert(){
        let alert = UIAlertController(title: "Activate location settings for Weather", message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Go to settings", style: .default, handler: { _ in
            self.navigateToSettings()
        }))
        
        alert.addAction(UIAlertAction(title: "No, thanks", style: .cancel, handler: { _ in
            
            if let pageVC = self.pageVC{
                pageVC.removeFirstVC()
            }
            self.showAlert = false
            self.hideWaiting()
        }))
        
        self.present(alert, animated: true)
    }
    
    // Navigate to App settings
    func navigateToSettings(){
        if let url = URL(string:UIApplicationOpenSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

// MARK: - PageControlDelegate
extension WeatherVC : PageControlDelegate{
    
    func didUpdatePageCount(pageVC: PageViewController, didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func didUpdateIndex(pageVC: PageViewController, didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
    
}

// MARK: - Collection view data source & delegate & FlowLayout
extension WeatherVC : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.hourForecast.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: ForecastCollectionViewCell.identifier, for: indexPath) as! ForecastCollectionViewCell
        let weather = self.hourForecast[indexPath.row]
        cell.tempLabelOutlet.text = "\(weather.currentTemp) "
        cell.iconImageView.kf.setImage(with: URL(string : self.imageURL+"\(weather.imgIcon).png"))
       
        cell.timeLabelOutlet.text = String(weather.dt_txt.suffix(8).prefix(2))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
        return CGSize(width: 56, height: 114)
        
    }
    
    
}

// MARK: - Table view data source & delegate
extension WeatherVC : UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InfoTableViewCell.identifier, for: indexPath) as! InfoTableViewCell
        if let weather = self.currentWeather{
            switch indexPath.row {
            case 0:
                cell.fieldNameLabelOutlet.text = "MIN TEMP"
                cell.fieldValueNameLabelOutlet.text = "\(weather.minTemp) "
            case 1:
                cell.fieldNameLabelOutlet.text = "MAX TEMP"
                cell.fieldValueNameLabelOutlet.text = "\(weather.maxTemp) "
            case 2:
                cell.fieldNameLabelOutlet.text = "WIND"
                cell.fieldValueNameLabelOutlet.text = "\(weather.windSpeed) m/s"
            case 3:
                cell.fieldNameLabelOutlet.text = "HUMIDITY"
                cell.fieldValueNameLabelOutlet.text = "\(weather.humidity) %"
            case 4:
                cell.fieldNameLabelOutlet.text = "PRESSURE"
                cell.fieldValueNameLabelOutlet.text = "\(weather.pressure) hPa"
            case 5:
                cell.fieldNameLabelOutlet.text = "SUNRISE"
                let date = Date(timeIntervalSince1970: weather.sunrise)
                cell.fieldValueNameLabelOutlet.text = "\(date.currentTime())"
            case 6:
                cell.fieldNameLabelOutlet.text = "SUNSET"
                let date = Date(timeIntervalSince1970: weather.sunset)
                cell.fieldValueNameLabelOutlet.text = "\(date.currentTime())"
                
            default:
                break
            }
        }
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}


// MARK: - CLLocationManagerDelegate
extension WeatherVC : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.showAlert = false
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        //if self.cityName == "currentLocation"{
        self.getWeatherByCoord(lat: locValue.latitude, long: locValue.longitude)
        self.lat = locValue.latitude
        self.lon = locValue.longitude
        //}
        self.locationManager.stopUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Show alert only the first time
        if showAlert && self.cityName == "currentLocation"{
            self.showConfigAlert()
        }
        self.showAlert = false
    }
}
