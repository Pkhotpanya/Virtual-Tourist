//
//  CoreDataStack.swift
//  Virtual Tourist
//
//  Created by Peter Khotpanya on 11/15/16.
//  Copyright © 2016 Peter Khotpanya. All rights reserved.
//

import CoreData
import UIKit

class CoreDataStack {
    
    //MARK: Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Virtual_Tourist")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    //MARK: Pin support
    func addPinToContext(latitude: Double, longitude: Double){
        let context = persistentContainer.viewContext
        let pin = Pin(context: context)
        pin.latitude = latitude
        pin.longitude = longitude
    }
    
    func getPinFromContext(latitude: Double, longitude: Double) -> [Pin]{
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()
        request.predicate = NSPredicate(format: "latitude == %@, longitude == %@", latitude, longitude)
        do {
            let searchResults = try context.fetch(request)
            return searchResults
        } catch {
            print("Error with request: \(error)")
        }
        return []
    }
    
    func getAllPinsFromContext() -> [Pin]{
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()
        do {
            let searchResults = try context.fetch(request)
            return searchResults
        } catch {
            print("Error with request: \(error)")
        }
        return []
    }
    
    //MARK: Photo support
    func addPhotoToContext(image: UIImage, url: String, pin: Pin){
        let context = persistentContainer.viewContext
        let photo = Photo(context: context)
        photo.image = NSData(data: UIImageJPEGRepresentation(image, 1.0)!)
        photo.url = url
        photo.pin = pin
    }
    
    func getPhotosFromContext(pin: Pin) -> [Photo]{
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.predicate = NSPredicate(format: "pin == %@", pin)
        do {
            let searchResults = try context.fetch(request)
            return searchResults
        } catch {
            print("Error with request: \(error)")
        }
        return []
    }
    
    //MARK: Save function
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
