//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Peter Khotpanya on 11/8/16.
//  Copyright © 2016 Peter Khotpanya. All rights reserved.
//
// Pin a location and tap it to segue to PhotoAlbumViewController.

import UIKit
import MapKit

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap(mapView: mapView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
            pinView!.animatesDrop = true
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //TODO: store the coordinates for PhotoAlbumViewController
        
        performSegue(withIdentifier: "photoAlbumViewSegue", sender: nil)
    }

    func addPin(latitude: Double, longitude: Double){
        let lat = CLLocationDegrees(latitude)
        let long = CLLocationDegrees(longitude)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    func configureMap(mapView: MKMapView){
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isPitchEnabled = true
    }
    
    //MARK: Long press gesture recognizer
    @IBAction func longPressTriggered(_ sender: Any) {
        let longPressGesture = sender as? UILongPressGestureRecognizer
        switch (longPressGesture?.state)! as UIGestureRecognizerState {
        case UIGestureRecognizerState.began:
            let point = longPressGesture?.location(in: mapView)
            let coordinate = mapView.convert(point!, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        default:
            return
        }
        
    }

}
