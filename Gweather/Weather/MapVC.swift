//
//  mapVC.swift
//  WeatherApp
//
//  Created by Mohsin Qureshi on 01/03/2022.
//

import UIKit
import MapKit
import Alamofire

class MapVC: UIViewController, UIGestureRecognizerDelegate,UISearchBarDelegate,MKMapViewDelegate {
    
    
    //MARK: - Outlets
    @IBOutlet weak var weatherMap: MKMapView!
    @IBOutlet weak var countryLbl: UILabel!
    @IBOutlet weak var windSpeedLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var currentTempLbl: UILabel!
    @IBOutlet weak var minMaxTempLbl: UILabel!
    @IBOutlet weak var feelsLikeLbl: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var weatherUpdateView: UIView!
    @IBOutlet weak var weatherUpdateViewSecound: UIView!
    @IBOutlet weak var mapView: UIView!
    
    
    //MARK: - Variables
    let annotation = MKPointAnnotation()
    var data = [WeatherData]()
    var imageData = [WeatherData]()
    var latitude = CLLocationDegrees()
    var longitude = CLLocationDegrees()
    
    
    lazy var viewModell: ViewModel = {
        let viewModel = ViewModel()
        viewModel.delegate = self
        return viewModel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weatherMap.layer.cornerRadius = 10.5
        mapView.dropShadow(color: .black, opacity: 0.13, offSet: CGSize(width: -3, height: -3), radius: 20, scale: true)
        weatherUpdateViewSecound.layer.cornerRadius = 10.5
        weatherUpdateView.dropShadow(color: .black, opacity: 0.15, offSet: CGSize(width: -3, height: -3), radius: 35, scale: true)
        weatherUpdateViewSecound.layer.borderColor = UIColor.lightGray.cgColor
        weatherUpdateViewSecound.layer.borderWidth = 0.5
        
        countryLbl.isHidden = true
        windSpeedLbl.isHidden = true
        descriptionLbl.isHidden = true
        currentTempLbl.isHidden = true
        minMaxTempLbl.isHidden = true
        currentTempLbl.isHidden = true
        feelsLikeLbl.isHidden = true
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Activity Indicator
        
        // hide search bar
        searchBar.resignFirstResponder()
        dismiss(animated: true)
        
        //create search request
        let searchreq = MKLocalSearch.Request()
        
        searchreq.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchreq)
        activeSearch.start {( response, error) in
            if response == nil{
                
            }else{
                
                self.latitude = (response?.boundingRegion.center.latitude)!
                self.longitude = (response?.boundingRegion.center.longitude)!
                
                
                /// Notation on Map
                let centerCoordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
                self.annotation.coordinate = centerCoordinate
                //self.annotation.title = "\(searchBar.text ?? "Nothing") - \(self.latitude) - \(self.longitude)"
                self.weatherMap.addAnnotation(self.annotation)
                
                // Zoom on search
                let cordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.latitude, self.longitude)
                let spann = MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)
                let region = MKCoordinateRegion(center: cordinate,span: spann)
                self.weatherMap.setRegion(region, animated: true)
                self.viewModell.weatherApiData(latitude: self.latitude, longitude: self.longitude)
            }
        }
    }
    
    @IBAction func searchAction(_ sender: UIButton){
        let searchbarcontroller = UISearchController(searchResultsController: nil)
        searchbarcontroller.searchBar.delegate = self
        present(searchbarcontroller, animated: true)
    }
}

// API Calling
extension MapVC: weatherDelegate{
    
    func ApiData(com: ([WeatherData])) {
        self.data = com
        let temp = String(format: "%.2f", ((data[0].main?.temp ?? 22.2) - 273.15))
        let minTemp = String(format: "%.2f", ((data[0].main?.tempMin ?? 22.2) - 273.15))
        let maxTemp = String(format: "%.2f", ((data[0].main?.tempMax ?? 22.2) - 273.15))
        let feelLikeTemp = String(format: "%.2f", ((data[0].main?.feelsLike ?? 20.0) - 273.15))
        windSpeedLbl.text = "\(data[0].wind?.speed ?? 22.2)/km"
        descriptionLbl.text = data[0].weather?[0].description
        currentTempLbl.text = "\(temp)°"
        minMaxTempLbl.text = "\(minTemp)° \(maxTemp)°"
        feelsLikeLbl.text = "Feels like \(feelLikeTemp)°"
        countryLbl.addLabelToNav(title: "\(data[0].name ?? "") \(data[0].sys?.country ?? "")")
        navigationItem.titleView = countryLbl
        countryLbl.isHidden = false
        windSpeedLbl.isHidden = false
        descriptionLbl.isHidden = false
        currentTempLbl.isHidden = false
        minMaxTempLbl.isHidden = false
        currentTempLbl.isHidden = false
        feelsLikeLbl.isHidden = false
        DispatchQueue.main.async {
            self.weatherIcon.loadFrom(URLAddress: "https://openweathermap.org/img/wn/\(self.data[0].weather?[0].icon ?? "")@2x.png")
        }
    }
}

//Load Image from URL
extension UIImageView {
    func loadFrom(URLAddress: String) {
        guard let url = URL(string: URLAddress) else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            if let imageData = try? Data(contentsOf: url) {
                if let loadedImage = UIImage(data: imageData) {
                    self?.image = loadedImage
                }
            }
        }
    }
}


extension UIView {
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}


extension UILabel{
    
    func addLabelToNav(title: String){
        self.textAlignment = .center
        self.adjustsFontSizeToFitWidth = true
        self.text = title
    }
}
