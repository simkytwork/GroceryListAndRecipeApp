//
//  UserProfileView.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 13/04/2024.
//

import SwiftUI

struct UserProfileView: View {
    var user: User
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .center, spacing: 10) {
                    Text("Email: \(user.email)")
                        .foregroundColor(.secondary)
                }
                .padding()
                
                Button("Logout") {
                    Task {
                        await sessionManager.logout()
                    }
                }
                .foregroundColor(.white)
                .frame(width: 280, height: 44)
                .background(Color.red)
                .cornerRadius(22)
                .padding(.top, 20)
            }
            .navigationBarTitle("Profile", displayMode: .inline)
        }
    }
}
