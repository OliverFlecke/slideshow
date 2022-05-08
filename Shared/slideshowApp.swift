//
//  slideshowApp.swift
//  Shared
//
//  Created by Oliver Fleckenstein on 08/05/2022.
//

import SwiftUI

@main
struct slideshowApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
