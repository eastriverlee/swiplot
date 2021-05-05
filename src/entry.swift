import Darwin
import SwiftUI

@main
struct Metal: App {
    var body: some Scene {
        WindowGroup {
            Content()
                .onDisappear { exit(0) }
        }
    }
}
