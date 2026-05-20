//
//  StandWiseApp.swift
//  StandWise
//
//  Created by Sendi Setiawan on 19/05/26.
//

import SwiftData
import SwiftUI

@main
struct StandWiseApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            User.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
