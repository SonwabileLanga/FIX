//
//  fixApp.swift
//  fix
//
//  Created by mac on 2025/08/31.
//

import SwiftUI

@main
struct fixApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
