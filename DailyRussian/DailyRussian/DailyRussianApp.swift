//
//  DailyRussianApp.swift
//  DailyRussian
//
//  Created by Nick Han on 2026/5/31.
//

import SwiftUI
import CoreData

@main
struct DailyRussianApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
