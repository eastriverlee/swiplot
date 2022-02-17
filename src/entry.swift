import Darwin
import SwiftUI

@main
struct Metal: App {
    var body: some Scene {
        WindowGroup {
            Content()
            .environmentObject(global)
            .onDisappear { exit(0) }
        }
    }
}
