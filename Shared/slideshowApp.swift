import SwiftUI
import SwiftLogger

let logger: Logger = SimpleLogger(level: .debug)

@main
struct slideshowApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
