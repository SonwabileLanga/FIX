//
//  Persistence.swift
//  FixSmart
//
//  Created by mac on 2025/08/28.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample issues for preview
        let sampleCategories = ["Pothole", "Water Leak", "Streetlight", "Illegal Dumping", "Power Outage"]
        let sampleDescriptions = [
            "Large pothole on Main Street near the intersection",
            "Water leaking from broken pipe on Oak Avenue",
            "Streetlight not working on Pine Street",
            "Illegal dumping of construction waste",
            "Power outage affecting several homes"
        ]
        
        for i in 0..<5 {
            let newIssue = Issue(context: viewContext)
            newIssue.id = UUID()
            newIssue.trackingId = String((0..<8).map { _ in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()! })
            newIssue.category = sampleCategories[i]
            newIssue.descriptionText = sampleDescriptions[i]
            newIssue.latitude = -34.1833 + Double.random(in: -0.01...0.01)
            newIssue.longitude = 22.1333 + Double.random(in: -0.01...0.01)
            newIssue.status = ["Logged", "In Progress", "Resolved"].randomElement()
            newIssue.createdAt = Date().addingTimeInterval(-Double.random(in: 0...86400*7)) // Random time in last week
            newIssue.updatedAt = Date()
            
            // Create status updates
            let statusUpdate = StatusUpdate(context: viewContext)
            statusUpdate.id = UUID()
            statusUpdate.status = newIssue.status
            statusUpdate.message = "Issue \(newIssue.status?.lowercased() ?? "logged")"
            statusUpdate.createdAt = newIssue.createdAt
            statusUpdate.issue = newIssue
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "FixSmart")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
