//
//  RecipeViewModel.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 13/04/2024.
//

import SwiftUI
import CoreData

class RecipeViewModel: ObservableObject {
    private var moc: NSManagedObjectContext
    @Published var recipe: Recipe
    
    init(moc: NSManagedObjectContext, recipe: Recipe) {
        self.moc = moc
        self.recipe = recipe
    }
    
    var formattedPrepTime: String {
        let hours = Int(recipe.prepTime) / 60
        let minutes = Int(recipe.prepTime) % 60
        if (hours == 0 && minutes == 0) {
            return "Not set"
        } else {
            return "\(hours) h \(minutes) min"
        }
    }
    
    var formattedCookTime: String {
        let hours = Int(recipe.cookTime) / 60
        let minutes = Int(recipe.cookTime) % 60
        if (hours == 0 && minutes == 0) {
            return "Not set"
        } else {
            return "\(hours) h \(minutes) min"
        }
    }
    
    var intRating: Int {
        get { Int(recipe.rating) }
    }
}
