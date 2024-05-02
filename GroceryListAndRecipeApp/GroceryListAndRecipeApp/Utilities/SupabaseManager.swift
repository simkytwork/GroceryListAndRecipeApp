//
//  SupabaseManager.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 14/04/2024.
//

import Supabase
import SwiftUI

class SupabaseManager {
    static let shared = SupabaseManager()
    var client: SupabaseClient

    private init() {
        let supabaseUrlString = "https://iexsrruzgtpjwafigtdw.supabase.co"
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlleHNycnV6Z3RwandhZmlndGR3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTM3OTIxNDAsImV4cCI6MjAyOTM2ODE0MH0.eqJlYMSt04km1QPEhP0PJrDTaY407Q4HzXnmzQvqbEQ"
        
        guard let supabaseUrl = URL(string: supabaseUrlString) else {
            fatalError("Invalid URL: \(supabaseUrlString)")
        }

        client = SupabaseClient(supabaseURL: supabaseUrl, supabaseKey: supabaseKey)
    }
}
