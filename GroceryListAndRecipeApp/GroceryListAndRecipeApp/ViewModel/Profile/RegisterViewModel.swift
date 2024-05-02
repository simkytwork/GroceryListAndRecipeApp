//
//  RegisterViewModel.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 13/04/2024.
//

import SwiftUI
import Combine

class RegisterViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    @Published var isRegistrationValid: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []

    init() {
        validateForm()
    }
    
    private func validateForm() {
        Publishers.CombineLatest3($email, $password, $confirmPassword)
            .map { email, password, confirmPassword in
                !email.isEmpty &&
                password.count >= 6 &&
                password == confirmPassword
            }
            .assign(to: \.isRegistrationValid, on: self)
            .store(in: &cancellables)
    }
}
