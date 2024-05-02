//
//  RecipesViewModel.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 12/04/2024.
//

import SwiftUI
import CoreData

class RecipesViewModel: ObservableObject {
    private var moc: NSManagedObjectContext
    @Published var chosenRecipe: Recipe?
    @Published var recipes: [Recipe] = []
    @Published var searchText = ""
    private var allRecipes: [Recipe] = []

    init(moc: NSManagedObjectContext) {
        self.moc = moc
        fetchRecipes()
    }
    
    func fetchRecipes() {
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        do {
            allRecipes = try moc.fetch(request)
            recipes = allRecipes
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func deleteRecipe(at offsets: IndexSet) {
        for index in offsets {
            let recipe = recipes[index]
            moc.delete(recipe)
        }
        
        do {
            try moc.save()
        } catch {
            print("Error saving context: \(error)")
        }
        
        fetchRecipes()
        searchRecipes()
    }
    
    func searchRecipes() {
        if searchText.isEmpty {
            recipes = allRecipes
        } else {
            recipes = allRecipes.filter { recipe in
                recipe.name?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
    }
}
