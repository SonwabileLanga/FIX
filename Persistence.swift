//
//  Persistence.swift
//  fix
//
//  Created by mac on 2025/08/31.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample math problems for preview
        let sampleProblems = [
            ("Solve for x: 2x + 5 = 13", "x = 4\n\nStep-by-step solution:\n1. Subtract 5 from both sides: 2x = 8\n2. Divide both sides by 2: x = 4", "Algebra", "Medium"),
            ("Find the area of a circle with radius 5", "Area = πr² = π(5)² = 25π ≈ 78.54", "Geometry", "Easy"),
            ("What is the derivative of x²?", "d/dx(x²) = 2x\n\nUsing the power rule: d/dx(xⁿ) = nxⁿ⁻¹", "Calculus", "Medium")
        ]
        
        for (problemText, solution, subject, difficulty) in sampleProblems {
            let newProblem = MathProblemEntity(context: viewContext)
            newProblem.id = UUID()
            newProblem.problemText = problemText
            newProblem.solution = solution
            newProblem.subject = subject
            newProblem.difficulty = difficulty
            newProblem.timestamp = Date()
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
        container = NSPersistentCloudKitContainer(name: "fix")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

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
    }
}
