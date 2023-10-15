//
//  BreadcrumbsApp.swift
//  Breadcrumbs
//
//  Created by Marin Todorov on 10/14/23.
//

import SwiftUI

@main
struct BreadcrumbsApp: App {
    @StateObject var model = CrumbModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
        .windowToolbarStyle(.unifiedCompact)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
    }
}
