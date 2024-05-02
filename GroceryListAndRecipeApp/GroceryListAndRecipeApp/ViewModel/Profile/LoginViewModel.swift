//
//  LoginViewModel.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 13/04/2024.
//

import SwiftUI
import Combine

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published var loginDisabled: Bool = true
    
    private var cancellables: Set<AnyCancellable> = []

    init() {
        validateForm()
    }
    
    private func validateForm() {
        Publishers.CombineLatest($email, $password)
            .map { email, password in
                return email.isEmpty || password.count < 6
            }
            .assign(to: \.loginDisabled, on: self)
            .store(in: &cancellables)
    }
    
    func login() {
        print("Logging in user with email: \(email)")
    }
}
