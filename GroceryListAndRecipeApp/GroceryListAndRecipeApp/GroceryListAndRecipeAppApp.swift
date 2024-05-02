//
//  GroceryListAndRecipeAppApp.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 08/04/2024.
//

import SwiftUI

@main
struct GroceryListAndRecipeAppApp: App {
    @StateObject private var dataController = DataController()
    var sessionManager = SessionManager()

    var body: some Scene {
        WindowGroup {
            MainView(moc: dataController.container.viewContext)
                .environmentObject(sessionManager)
        }
    }
}
