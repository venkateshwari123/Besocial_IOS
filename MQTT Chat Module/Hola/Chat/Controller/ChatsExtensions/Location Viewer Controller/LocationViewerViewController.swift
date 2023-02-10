//
//  LocationViewerViewController.swift
//  MQTT Chat Module
//
//  Created by Sachin Nautiyal on 15/02/2018.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import MapKit

class LocationViewerViewController: UIViewController {
    
    struct Constants {
        static let annotationViewIdentifier = "mapAnnotation"
    }
    
    
    
    @IBOutlet weak var mapViewOutlet: MKMapView!
    @IBOutlet weak var segmentControlOutlet: UISegmentedControl!
    var currentLatLong : String!
    var zoomed = false
    var locationManager: CLLocationManager!
    var location : CLLocationCoordinate2D!
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentControlOutlet.setTitle("Map".localized, forSegmentAt: 0)
        segmentControlOutlet.setTitle("Hybrid".localized, forSegmentAt: 1)
        segmentControlOutlet.setTitle("Satelite".localized, forSegmentAt: 2)

    }
    
    private func drawLatLong(fromString latLongString : String) {
        if let latStr = latLongString.slice(from: "(", to: ","), let longStr = latLongString.slice(from: ",", to: ")") {
            
            if let latDecimal = Double(latStr), let log = Double(longStr) {
                self.location = CLLocationCoordinate2D(latitude: latDecimal, longitude: log)
                if let address = self.getLocationName(fromString: latLongString) {
                    self.title = address
                self.createGeoLocationFromAddress(address, locationCoordinates: location, mapView: self.mapViewOutlet)
                }
                let coordinateRegion = MKCoordinateRegion.init(center: location, latitudinalMeters: 1000.0 * 1.0, longitudinalMeters: 1000.0 * 1.0)
                self.mapViewOutlet.setRegion(coordinateRegion, animated: true)
            }
        }
    }
    
    private func getLocationName(fromString latLongString : String) -> String? {
        if let locationName = latLongString.slice(from: "@@", to: "@@") {
            return locationName
        }
        return nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.drawLatLong(fromString: currentLatLong)
    }
    
    //MARK:- Buttons Actions
    @IBAction func segmentControlAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: // For Standerd view
            self.mapViewOutlet.mapType = .standard
            
        case 1: // For Hybrid view
            self.mapViewOutlet.mapType = .hybrid
            
        case 2: // For Satelite view
            self.mapViewOutlet.mapType = .satellite
            
        default:
            break
        }
    }
    
    @IBAction func searchButtonAction(_ sender: UIBarButtonItem) { // Zooming to current location
        let regionRadius: CLLocationDistance = 1000.0
        if zoomed {
            let coordinateRegion = MKCoordinateRegion.init(center: location, latitudinalMeters: regionRadius * 1.0, longitudinalMeters: regionRadius * 1.0)
            self.mapViewOutlet.setRegion(coordinateRegion, animated: true)
            zoomed = false
        } else {
            let coordinateRegion = MKCoordinateRegion.init(center: location, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
            self.mapViewOutlet.setRegion(coordinateRegion, animated: true)
            zoomed = true
        }
    }
    
    @IBAction func openMapAction(_ sender: UIBarButtonItem) {
        // Open and show coordinate
        var optionsArray = [AppConstants.MapsConstant.maps]
        if (UIApplication.shared.canOpenURL(URL(string:"https://maps.google.com")!)) {
            optionsArray.append(AppConstants.MapsConstant.googleMaps)
        }
        self.addPopUpOptions(withOptionsArray: optionsArray)
    }
    
    func openMaps() {
        let url = "http://maps.apple.com/maps?saddr=\(location.latitude),\(location.longitude)"
        UIApplication.shared.open(URL(string : url)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
    
    func openGoogleMaps() {
        UIApplication.shared.open(URL(string:
            "https://maps.google.com/?q=@\(location.latitude),\(location.longitude)")!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
    
    private func addPopUpOptions(withOptionsArray optionsArray : [String] ) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for optionValue in optionsArray {
            let action = UIAlertAction(title: optionValue, style: .default, handler: { (action) in
                if action.title == AppConstants.MapsConstant.maps {
                    self.openMaps()
                        controller.dismiss(animated: true, completion: nil)
                } else if action.title == AppConstants.MapsConstant.googleMaps {
                    self.openGoogleMaps()
                        controller.dismiss(animated: true, completion: nil)
                } else {
                    // have to handle for Other Options here.
                }
            })
            controller.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler:nil)
        controller.addAction(cancelAction)
        self.present(controller, animated: true, completion: nil)
    }
}

extension LocationViewerViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView : MKAnnotationView!
        if let annotationview = mapViewOutlet.dequeueReusableAnnotationView(withIdentifier: Constants.annotationViewIdentifier) {
            annotationView = annotationview
        } else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: Constants.annotationViewIdentifier)
        }
        annotationView.annotation = annotation
        annotationView.image = #imageLiteral(resourceName: "mapPinIcon")
        return annotationView
    }
    
    
        func createGeoLocationFromAddress(_ address: String, locationCoordinates : CLLocationCoordinate2D,  mapView: MKMapView) {
            // Instantiate annotation
            let annotation = MKPointAnnotation()
            // Annotation coordinate
            annotation.coordinate = locationCoordinates
            annotation.title = address
            mapView.addAnnotation(annotation)
            mapView.showsPointsOfInterest = true
        }
    
    //    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    //        let circleView = MKCircleRenderer(overlay: overlay)
    //        circleView.fillColor = UIColor.blue.withAlphaComponent(0.4)
    //        return circleView
    //
    //    }
}

//extension LocationViewerViewController : CLLocationManagerDelegate {

//    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
//        let location = locations.last as! CLLocation
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//
//        self.mapViewOutlet.setRegion(region, animated: true)
//    }
//}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
