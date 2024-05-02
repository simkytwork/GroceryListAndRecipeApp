//
//  MainView.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 08/04/2024.
//

import SwiftUI
import CoreData

struct MainView: View {
    private var moc: NSManagedObjectContext
    @EnvironmentObject var sessionManager: SessionManager

    init(moc: NSManagedObjectContext) {
        self.moc = moc
        UITabBar.appearance().backgroundColor = UIColor.systemGray6
    }
    
    var body: some View {
        TabView {
            ListsView(moc: moc)
                .tabItem {
                    Label("Lists", systemImage: "list.dash")
                }
            
            RecipesView(moc: moc)
                .tabItem {
                    Label("Recipes", systemImage: "folder")
                }
            
            Group {
                if sessionManager.isLoggedIn {
                    UserProfileView(user: sessionManager.user!)
                } else {
                    LoginView()
                }
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle")
            }
        }
    }
}
