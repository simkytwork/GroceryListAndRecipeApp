//
//  LoginView.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 13/04/2024.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel
    @EnvironmentObject var sessionManager: SessionManager

    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init() {
        _viewModel = StateObject(wrappedValue: LoginViewModel())
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                Text("Login")
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

                Button("Login") {
                    Task {
                        await sessionManager.login(email: viewModel.email, password: viewModel.password)
                    }
                }
                .disabled(viewModel.loginDisabled)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(viewModel.loginDisabled ? Color(UIColor.systemGray4) : Color.green)
                .cornerRadius(10)
                .padding(.horizontal, 50)
                .alert("Login Error", isPresented: Binding<Bool>(
                    get: { self.sessionManager.errorMessage != nil },
                    set: { _ in self.sessionManager.errorMessage = nil }
                )) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(sessionManager.errorMessage ?? "Unknown error")
                }
                
                NavigationLink(destination: RegisterView()) {
                    Text("Don't have an account? Register")
                        .foregroundColor(.blue)
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
    }
}
