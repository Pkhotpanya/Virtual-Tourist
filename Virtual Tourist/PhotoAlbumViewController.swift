//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Peter Khotpanya on 11/7/16.
//  Copyright © 2016 Peter Khotpanya. All rights reserved.
//
// Show photos from Flickr of chosen pin coordinate

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var centerToolbarButton: UIBarButtonItem!
    var pin: Pin?
    
    enum ButtonNames: String{
        case newCollection = "New Collection"
        case removeSelectedPictures = "Remove Selected Pictures"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap(mapView: mapView)
        configureCollection(collectionView: collectionView)
        presentPin(pin: pin!)
    }
    
    //MARK: Center toolbar button action
    @IBAction func centerToolbarButtonIsPressed(_ sender: Any) {
        if centerToolbarButton.title == ButtonNames.newCollection.rawValue {
            getNewCollection()
        } else if centerToolbarButton.title == ButtonNames.removeSelectedPictures.rawValue {
            removeSelectedPictures()
        }
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
    
    //MARK: Map support
    func presentPin(pin: Pin){
        let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate

        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(annotation)
    }
    
    func configureMap(mapView: MKMapView){
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isPitchEnabled = false
    }
    
    //MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Configure the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoAlbumCollectionViewCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        
        //TODO: show photo from data source
        cell.photoAlbumImageView.image = image
        cell.activityIndicatorView.startAnimating()
        return cell
    }
    
    //MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.1, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations:{
            cell?.backgroundColor = UIColor.lightGray
        }, completion: nil)
        
        centerToolbarButton.title = ButtonNames.removeSelectedPictures.rawValue
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.1, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations:{
            cell?.backgroundColor = UIColor(red: 1/255.0, green: 179/255.0, blue: 228/255.0, alpha: 1.0)
        }, completion: nil)
        
        if !hasSelectedItems() {
            centerToolbarButton.title = ButtonNames.newCollection.rawValue
        }
    }
    
    //MARK: Colletion support
    func configureCollection(collectionView: UICollectionView){
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        
        // FlowLayout
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        //Note: This is a sample implementation. You will need to tinker with it to find a layout that works in both landscape and portrait. Hint: consider using view.frame.size.height in addition to view.frame.size.width.
        collectionViewFlowLayout.minimumInteritemSpacing = space
        collectionViewFlowLayout.minimumLineSpacing = space
        collectionViewFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    //MARK: Toolbar support
    func getNewCollection(){
        //TODO: get new collection
        //Show activity indicator until image is loaded
        
        //Set data source to 0
        
        //get new items
        
        //Refresh the collection view
        collectionView.reloadData()
    }
    
    func removeSelectedPictures(){
        //TODO: remove selected pictures
        
        //Remove selected pictures
        if hasSelectedItems() {
            //Show activity indicatore intil image is loaded
            
            //delete the selection from the data source
            //Ex. removeAtIndex(indexpath.item)
            
            //Delete from collection
            collectionView.deleteItems(at: collectionView.indexPathsForSelectedItems!)
            
            //Fetch with number given by the selection count
        
            //update the data source
            
            //update collection view
            collectionView.insertItems(at: collectionView.indexPathsForSelectedItems!)
            
            //Change the button name new collection
            centerToolbarButton.title = ButtonNames.newCollection.rawValue
        }
    }
    
    func hasSelectedItems() -> Bool{
        return (collectionView.indexPathsForSelectedItems?.count)! > 0
    }
    
    //MARK: Core data - photo support
    
    
    //TODO: Delete test function
    var image: UIImage?
    func testGettingPhoto(){
        FlickrClient.shared.getPhotos(lat: 34.0522, lon: 118.2437, perPage: 1, page: 2, completion: {(results, errorMessage) in
            let firstPhoto = results[0]
            self.image = FlickrClient.shared.getPhotoImage(
                id: firstPhoto[FlickrClient.PhotoElement.id.rawValue] as! String,
                server: firstPhoto[FlickrClient.PhotoElement.server.rawValue] as! String,
                farm: firstPhoto[FlickrClient.PhotoElement.farm.rawValue] as! NSNumber,
                secret: firstPhoto[FlickrClient.PhotoElement.secret.rawValue] as! String)
        })
    }
    
}

