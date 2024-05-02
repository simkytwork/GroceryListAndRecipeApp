//
//  SessionManager.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 13/04/2024.
//

import SwiftUI

class SessionManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var user: User?
    @Published var errorMessage: String?
    
    func login(email: String, password: String) async {
        do {
            let response = try await SupabaseManager.shared.client.auth.signIn(email: email, password: password)
            DispatchQueue.main.async {
                if response.user != nil {
                    self.user = User(email: email)
                    self.isLoggedIn = true
                    self.errorMessage = nil
                } else {
                    self.errorMessage = "No user data returned."
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "\(error.localizedDescription)"
            }
        }
    }

    func logout() async {
        do {
            try await SupabaseManager.shared.client.auth.signOut()
            DispatchQueue.main.async {
                self.user = nil
                self.isLoggedIn = false
            }
        } catch {
            DispatchQueue.main.async {
                print("Logout error: \(error.localizedDescription)")
            }
        }
    }

    func register(email: String, password: String) async {
        do {
            let response = try await SupabaseManager.shared.client.auth.signUp(email: email, password: password)
            DispatchQueue.main.async {
                self.user = User(email: email)
                self.isLoggedIn = response.user != nil
            }
        } catch {
            DispatchQueue.main.async {
                print("Registration error: \(error.localizedDescription)")
            }
        }
    }
}

struct User {
    var email: String
}
