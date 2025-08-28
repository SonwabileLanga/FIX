//
//  FixSmartApp.swift
//  FixSmart
//
//  Created by mac on 2025/08/28.
//

import SwiftUI

@main
struct FixMosselBayApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
