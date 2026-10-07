import SwiftUI

@main
public struct KikiApp: App {
    public init() {
        KikiResources.registerFonts()
    }

    public var body: some SwiftUI.Scene {
        WindowGroup {
            AppRootView()
        }
    }
}
