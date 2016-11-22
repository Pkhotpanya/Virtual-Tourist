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
    var photos = [Photo]()
    var page: Int = 1
    let maxCollectionSize = 21
    var inRemoveSelectedPicturesMode: Bool = false
    var hasSelectedItems: Bool{
        return (collectionView.indexPathsForSelectedItems?.count)! > 0
    }
    
    enum ButtonNames: String{
        case newCollection = "New Collection"
        case removeSelectedPictures = "Remove Selected Pictures"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap(mapView: mapView)
        configureCollection(collectionView: collectionView)
        presentPin(pin: pin!)
        loadPhotosForCollectionView(pin: pin!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        savePhotosToContext()
        
        NotificationCenter.default.removeObserver(self, name:
            NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    //MARK: Center toolbar button action
    @IBAction func centerToolbarButtonIsPressed(_ sender: Any) {
        if inRemoveSelectedPicturesMode {
            removeSelectedPictures()
        } else {
            getNewCollection()
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
    
    //MARK: Map view functions
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
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoAlbumCollectionViewCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        
        cell.photoAlbumImageView.image = nil
        cell.photoAlbumImageView.alpha = 1.0
        cell.activityIndicatorView.startAnimating()

        DispatchQueue.global(qos: .userInitiated).async {
            var image: UIImage? = nil
            if (self.photos[indexPath.item].imageData != nil) {
                image = UIImage(data: self.photos[indexPath.item].imageData as! Data)!
            } else {
                let urlString = self.photos[indexPath.item].url
                image = FlickrClient.shared.getPhotoImage(url: NSURL(string: urlString!)! as URL)
                
                let data = NSData(data: UIImageJPEGRepresentation(image!, 1.0)!)
                self.photos[indexPath.item].imageData = data
            }
          
            DispatchQueue.main.async {
                cell.photoAlbumImageView.image = image
                cell.activityIndicatorView.stopAnimating()
            }
        }

        return cell
    }
    
    //MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoAlbumCollectionViewCell
        UIView.animate(withDuration: 0.1, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations:{
            cell.photoAlbumImageView.alpha = 0.5
        }, completion: nil)
        
        centerToolbarButton.title = ButtonNames.removeSelectedPictures.rawValue
        inRemoveSelectedPicturesMode = true
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoAlbumCollectionViewCell
        UIView.animate(withDuration: 0.1, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations:{
            cell.photoAlbumImageView.alpha = 1.0
        }, completion: nil)
        
        if !hasSelectedItems {
            centerToolbarButton.title = ButtonNames.newCollection.rawValue
            inRemoveSelectedPicturesMode = false
        }
    }
    
    //MARK: Collection helper functions
    func configureCollection(collectionView: UICollectionView){
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
 
        let space: CGFloat = 3.0
        var dimension = (view.frame.size.width - (2 * space)) / 3.0
        if UIApplication.shared.statusBarOrientation.isLandscape {
            dimension = ((view.frame.size.width/2) - (2 * space)) / 3.0
        }
        collectionViewFlowLayout.minimumInteritemSpacing = space
        collectionViewFlowLayout.minimumLineSpacing = space
        collectionViewFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    func orientationChanged(_ notification: NSNotification){
        configureCollection(collectionView: collectionView)
    }
    
    func loadPhotosForCollectionView(pin: Pin){
        centerToolbarButton.isEnabled = false
        let stackPhoto = getPhotosFromStack(pin: pin)
        if stackPhoto.isEmpty {
            getPhotosFromFlickr(pin: pin, page: 1)
        } else {
            photos = stackPhoto
            collectionView.reloadData()
        }
        centerToolbarButton.isEnabled = true
    }
    
    //MARK: Toolbar button functions
    func getNewCollection(){
        deletePhotosFromStack(photos: photos)
        photos.removeAll()
        getPhotosFromFlickr(pin: pin!, page: page + 1)
    }
    
    func removeSelectedPictures(){
        if hasSelectedItems {
            var photosToDelete: [Photo] = []
            for indexpath in collectionView.indexPathsForSelectedItems!{
                photosToDelete.append(photos[indexpath.item])
            }
      
            deletePhotosFromSelf(photosToDelete: photosToDelete)
            deletePhotosFromStack(photos: photosToDelete)
            collectionView.deleteItems(at: collectionView.indexPathsForSelectedItems!)

            centerToolbarButton.title = ButtonNames.newCollection.rawValue
        }
    }
    
    func deletePhotosFromSelf(photosToDelete: [Photo]){
        for photo in photosToDelete{
            photos.remove(at:photos.index(of: photo)!)
        }
    }
    
    //MARK: FlickrClient photo function
    func getPhotosFromFlickr(pin: Pin, page: Int){
        FlickrClient.shared.getPhotos(latitude: pin.latitude, longitude: pin.longitude, perPage: maxCollectionSize, page: page, completion: {(results, errorMessage) in
            if results.isEmpty {
                let alert = UIAlertController(title: "Unable to retrieve images", message: "", preferredStyle: UIAlertControllerStyle.alert)
                let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                var photoItems = [Photo]()
                for photoDictionary in results{
                    let url = FlickrClient.shared.getPhotoURL(
                        id: photoDictionary["id"] as! String,
                        server: photoDictionary["server"] as! String,
                        farm: photoDictionary["farm"] as! NSNumber,
                        secret: photoDictionary["secret"] as! String)
                    
                    let context = self.getContext()
                    let photo = Photo(context: context)
                    photo.url = String(describing: url)
                    photo.pin = pin
                    
                    photoItems.append(photo)
                }
                
                DispatchQueue.main.async {
                    self.photos = photoItems
                    self.collectionView.reloadData()
                }
            }
        })
    }
    
    //MARK: Core data photo functions
    func getPhotosFromStack(pin: Pin) -> [Photo]{
        let stack = getStack()
        let photos = stack.getPhotosFromContext(pin: pin)
        return photos
    }
    
    func deletePhotosFromStack(photos: [Photo]){
        let stack = getStack()
        stack.deletePhotosFromContext(photos: photos)
    }
    
    func savePhotosToContext(){
        let stack = getStack()
        stack.saveContext()
    }
    
    func getStack() -> CoreDataStack{
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let stack = appDelegate?.coreDataStack
        return stack!
    }
    
    func getContext() -> NSManagedObjectContext{
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.coreDataStack.persistentContainer.viewContext
        return context!
    }

}

