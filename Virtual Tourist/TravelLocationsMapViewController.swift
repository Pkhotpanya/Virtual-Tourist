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
import CoreData

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap(mapView: mapView)
        getAllPinsFromStack()
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
        performSegue(withIdentifier: "photoAlbumViewSegue", sender: view.annotation)
    }
    
    //MARK: Map support
    func populateMapView(pins: [Pin]){
        var annotations = [MKAnnotation]()
        for pin in pins {
            let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }

    func addAnnotationToMap(coordinate: CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    func configureMap(mapView: MKMapView){
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isPitchEnabled = true
    }
    
    //MARK: Map point function 
    @IBAction func longPressTriggered(_ sender: Any) {
        let longPressGesture = sender as? UILongPressGestureRecognizer
        switch (longPressGesture?.state)! as UIGestureRecognizerState {
        case UIGestureRecognizerState.began:
            let point = longPressGesture?.location(in: mapView)
            let coordinate = mapView.convert(point!, toCoordinateFrom: mapView)
            
            addAnnotationToMap(coordinate: coordinate)
            addNewPinToStack(coordinate: coordinate)
        default:
            return
        }
        
    }
    
    //MARK: Core Data - Pin support
    func getAllPinsFromStack(){
        let stack = getStack()
        let pins = stack.getAllPinsFromContext()
        populateMapView(pins: pins)
    }
    
    func addNewPinToStack(coordinate: CLLocationCoordinate2D){
        let stack = getStack()
        stack.addPinToContext(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    func getPinFromStack(coordinate: CLLocationCoordinate2D) -> Pin{
        let stack = getStack()
        let pins = stack.getPinFromContext(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return (pins.first)!
    }
    
    func getStack() -> CoreDataStack{
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let stack = appDelegate?.coreDataStack
        return stack!
    }
    
    //MARK: PhotoAlbumViewController segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoAlbumViewSegue" {
            let destinationViewController = segue.destination as? PhotoAlbumViewController
            let annotation = sender as? MKAnnotation
            let coordinate = annotation?.coordinate
            let pin = getPinFromStack(coordinate: coordinate!)
            destinationViewController?.pin = pin
        }
    }

}
