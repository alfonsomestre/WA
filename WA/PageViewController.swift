//
//  PageViewController.swift
//  WA
//
//  Created by Alfonso Mestre on 2/24/19.
//  Copyright © 2019 Alfonso Mestre. All rights reserved.
//

import UIKit
import CoreLocation

class PageViewController: UIPageViewController {

    var orderedViewControllers: [UIViewController] = []
    var pageControlDelegate : PageControlDelegate?
    let locationManager = CLLocationManager()
    var currIndex : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = Colors.backgroundColor
        //DataSource and Delegate for UIPageController
        dataSource = self
        delegate = self
        
        self.createVCs()
        self.setNeedsStatusBarAppearanceUpdate()
    }

    

    // Change status bar color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func newCityViewController(cityName: String) -> UIViewController {
        // Instanciate and set cityName and compose for WeatherVC
        let vc = UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "WeatherVC") as! WeatherVC
        vc.config(cityName: cityName)
        vc.pageVC = self
        return vc
    }

    
    private func notifyDelegateOfNewIndex() {
        // Call delegate to notify that we have a new index
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.firstIndex(of: firstViewController) {
            //Update Page count on WeatherVC
            self.currIndex = index
            pageControlDelegate?.didUpdatePageCount(pageVC: self, didUpdatePageCount: orderedViewControllers.count)
            pageControlDelegate?.didUpdateIndex(pageVC: self, didUpdatePageIndex: index)
        }
    }
    
    func createVCs(){
        // One VC per city and one extra for current location
        self.orderedViewControllers.append(self.newCityViewController(cityName: Cities.currentLocation))
        
        self.orderedViewControllers.append(self.newCityViewController(cityName: Cities.montevideo))
        self.orderedViewControllers.append(self.newCityViewController(cityName: Cities.london))
        self.orderedViewControllers.append(self.newCityViewController(cityName: Cities.bsas))
        self.orderedViewControllers.append(self.newCityViewController(cityName: Cities.saoPaulo))
        self.orderedViewControllers.append(self.newCityViewController(cityName: Cities.munich))
        
        //Set visible VC
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion:  { (finished) -> Void in
                                // Setting the view controller programmatically does not fire
                                // any delegate methods, so we have to manually notify the
                                // 'tutorialDelegate' of the new index.
                                self.notifyDelegateOfNewIndex()
            })
        }
        
        //Update Page count on WeatherVC
        pageControlDelegate?.didUpdatePageCount(pageVC: self, didUpdatePageCount: orderedViewControllers.count)
    }
    
    func removeFirstVC(){
        // Remove WeatherVC that has the current location if exists and navigate to ti
        let vcs = orderedViewControllers.filter({
            vc in
            if let vc = vc as? WeatherVC{
                if vc.cityName == Cities.currentLocation{
                    return true
                }
                return false
            }
            return false
        })
        if vcs.count >= 1{
            if let index = orderedViewControllers.firstIndex(of: vcs.first!){
                self.orderedViewControllers.remove(at: index)
                if let firstViewController = orderedViewControllers.first {
                    setViewControllers([firstViewController],
                                       direction: .reverse,
                                       animated: true,
                                       completion:  { (finished) -> Void in
                                        // Setting the view controller programmatically does not fire
                                        // any delegate methods, so we have to manually notify the
                                        // 'tutorialDelegate' of the new index.
                                        self.notifyDelegateOfNewIndex()
                    })
                }
            }
            
        }
        
    }
    
    func addFirstVC(){
        // Add WeatherVC that has the current location if dont exists and navigate to ti
        
        let vcs = orderedViewControllers.filter({
            vc in
            if let vc = vc as? WeatherVC{
                if vc.cityName == Cities.currentLocation{
                    return true
                }
                return false
            }
            return false
        })
        if vcs.count == 0{
            orderedViewControllers = [self.newCityViewController(cityName: Cities.currentLocation)] + orderedViewControllers
            
            if let firstViewController = orderedViewControllers.first {
                setViewControllers([firstViewController],
                                   direction: .reverse,
                                   animated: true,
                                   completion:  { (finished) -> Void in
                                    // Setting the view controller programmatically does not fire
                                    // any delegate methods, so we have to manually notify the
                                    // 'tutorialDelegate' of the new index.
                                    self.notifyDelegateOfNewIndex()
                })
            }
            
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension PageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?{
        // Calculate the index for prev VC and return it
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of : viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?{
         // Calculate the index for next VC and return it
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of : viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        //When finish transition notifies than we have a new index
        notifyDelegateOfNewIndex()
    }
    
}
