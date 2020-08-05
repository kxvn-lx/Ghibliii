//
//  CoreDataEngine.swift
//  
//
//  Created by Kevin Laminto on 5/8/20.
//

import Foundation
import CoreData

public class CoreDataEngine {
    
    public static var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "Test")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    public static var context: NSManagedObjectContext = {
       return persistentContainer.viewContext
    }()
    public static let shared = CoreDataEngine()
    private init() { }
    
    public func saveContext() {
        let context = Self.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                fatalError(error.localizedDescription)
            }
        }
    }
}
