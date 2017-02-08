//
//  CoreDataManager.swift
//  Gameplan
//
//  Created by Jason Jin on 1/20/17.
//  Copyright © 2017 Jason Jin. All rights reserved.
//

import CoreData
import UIKit

func getContext () -> NSManagedObjectContext {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    return appDelegate.persistentContainer.viewContext
}

func storeEventDetails(attribute: String, value: String) {
    let context = getContext()
    
    //retrieve the entity that we just created
    let entity =  NSEntityDescription.entity(forEntityName: "Event" + attribute.capitalized, in: context)
    
    let event = NSManagedObject(entity: entity!, insertInto: context)
    
    //set the entity values
    event.setValue(value, forKey: "\(attribute)")
    //save the object
    do {
        try context.save()
        print("saved event detail!")
    } catch let error as NSError  {
        print("Could not save \(error), \(error.userInfo)")
    } catch {
        
    }
}
func storeEventCoordinate(lat: Double, lng: Double) {
    let context = getContext()
    
    //retrieve the entity that we just created
    let entity =  NSEntityDescription.entity(forEntityName: "EventLatLng", in: context)
    
    let event = NSManagedObject(entity: entity!, insertInto: context)
    
    //set the entity values
    event.setValue(lat, forKey: "lat")
    event.setValue(lng, forKey: "lng")
    //save the object
    do {
        try context.save()
        print("saved coordinates!")
    } catch let error as NSError  {
        print("Could not save \(error), \(error.userInfo)")
    } catch {
        
    }
}

func fetchRecordsForEntity(entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> [NSManagedObject] {
    // Create Fetch Request
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
    
    // Helpers
    var result = [NSManagedObject]()
    
    do {
        // Execute Fetch Request
        let records = try managedObjectContext.fetch(fetchRequest)
        
        if let records = records as? [NSManagedObject] {
            print("records")
            result = records
        }
        
    } catch {
        print("Unable to fetch managed objects for entity \(entity).")
    }
    
    return result
}

func deletefuncRecords(entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) {
    // Create Fetch Request
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
    let moc = getContext()
    // Helpers
    var result = [NSManagedObject]()
    
    do {
        // Execute Fetch Request
        let records = try moc.fetch(fetchRequest)
        
        if let records = records as? [NSManagedObject] {
            for record in records {
                moc.delete(record)
            }
            try moc.save()
            print("deleted data!")
        }
    } catch {
        print("Unable to fetch managed objects for entity \(entity).")
    }
}
