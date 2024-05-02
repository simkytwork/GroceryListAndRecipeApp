//
//  RegisterView.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 13/04/2024.
//

import SwiftUI

struct RegisterView: View {
    @StateObject var viewModel: RegisterViewModel
    @EnvironmentObject var sessionManager: SessionManager
    
    init() {
        _viewModel = StateObject(wrappedValue: RegisterViewModel())
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                Text("Register")
                    .font(.largeTitle)
                    .bold()
                
                TextField("Email", text: $viewModel.email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 50)
                
                SecureField("Password", text: $viewModel.password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 50)
                
                SecureField("Confirm Password", text: $viewModel.confirmPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 50)
                
                Button("Register") {
                    Task {
                        await sessionManager.register(email: viewModel.email, password: viewModel.password)
                    }
                }
                .disabled(!viewModel.isRegistrationValid)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(viewModel.isRegistrationValid ? Color.green : Color(UIColor.systemGray4))
                .cornerRadius(10)
                .padding(.horizontal, 50)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
    }
}
