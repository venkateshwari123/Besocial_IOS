//
//  PostsLocationCollectionViewCell.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 08/01/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import MapKit

class PostsLocationCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mapView: MKMapView!
    var lattitude: Double?
    var longitude: Double?
    
    override func awakeFromNib(){
        super.awakeFromNib()
    }
    
    func setMapViewData(lattitude: Double?, longitude: Double?){
        if let latt = lattitude, let longi = longitude{
            self.addAnnotationsAndMakeCenter(lattitude: latt, longitude: longi)
        }
    }
    
    private func addAnnotationsAndMakeCenter(lattitude: Double, longitude: Double){
        let CLLCoordType = CLLocationCoordinate2D(latitude: lattitude,
                                                  longitude: longitude);
        let anno = MKPointAnnotation();
        anno.coordinate = CLLCoordType;
        mapView.addAnnotation(anno);
        
        let regionRadius: CLLocationDistance = 200
        let coordinateRegion = MKCoordinateRegion.init(center: CLLCoordType,
                                                                  latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    //MARK:- Map view delegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil;
        }else{
            let pinIdent = "Pin";
            var pinView: MKPinAnnotationView;
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: pinIdent) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation;
                pinView = dequeuedView;
            }else{
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinIdent);
                
            }
            return pinView;
        }
    }
}
