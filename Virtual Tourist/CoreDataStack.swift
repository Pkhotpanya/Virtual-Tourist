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
        saveContext()
    }
    
    func getPinFromContext(latitude: Double, longitude: Double) -> [Pin]{
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "latitude = %@ AND longitude = %@", argumentArray: [latitude, longitude])
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
    
    func deletePhotosFromContext(photos: [Photo]){
        let context = persistentContainer.viewContext
        for photo in photos{
            context.delete(photo)
        }
        saveContext()
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
