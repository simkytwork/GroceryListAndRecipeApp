//
//  ManageRecipeViewModel.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 12/04/2024.
//

import SwiftUI
import CoreData

class ManageRecipeViewModel: ObservableObject {
    private var moc: NSManagedObjectContext
    private var recipe: Recipe?

    @Published private var recipeName: String = ""
    @Published private var recipeDescription: String = ""
    @Published private var recipeRating: Int = 0
    @Published private var recipePrepHours: Int = 0
    @Published private var recipePrepMinutes: Int = 0
    @Published private var recipeCookHours: Int = 0
    @Published private var recipeCookMinutes: Int = 0
    @Published private var recipeNote: String = ""
    @Published private var recipeServings: Int = 0
    @Published var recipeSteps: [Step] = []
    @Published var recipeIngredients: [Ingredient] = []

    var isEditMode: Bool {
        return recipe != nil
    }
    
    init(moc: NSManagedObjectContext, recipe: Recipe? = nil) {
        self.moc = moc
        self.recipe = recipe
        if let recipe = recipe {
            recipeName = recipe.wrappedName
            recipeDescription = recipe.descr == nil ? "" : recipe.wrappedDescription
            recipeRating = Int(recipe.rating)
            recipePrepHours = Int(recipe.prepTime) / 60
            print(recipePrepHours)
            recipePrepMinutes = Int(recipe.prepTime) % 60
            print(recipePrepMinutes)
            recipeCookHours = Int(recipe.cookTime) / 60
            print(recipeCookHours)
            recipeCookMinutes = Int(recipe.cookTime) % 60
            print(recipeCookMinutes)
            recipeNote = recipe.note == nil ? "" : recipe.wrappedNote
            recipeServings = Int(recipe.servings)
            recipeSteps = recipe.stepsArray
            recipeIngredients = recipe.ingredientsArray
        }
    }
    
    var name: String {
            get { recipeName }
            set { recipeName = newValue }
        }
    
    var description: String {
        get { recipeDescription }
        set { recipeDescription = newValue }
    }
    
    var rating: Int {
        get { recipeRating }
        set { recipeRating = newValue }
    }
    
    var prepHours: Int {
        get { recipePrepHours }
        set { recipePrepHours = newValue }
    }
    
    var prepMinutes: Int {
        get { recipePrepMinutes }
        set { recipePrepMinutes = newValue }
    }
    
    var cookHours: Int {
        get { recipeCookHours }
        set { recipeCookHours = newValue }
    }
    
    var cookMinutes: Int {
        get { recipeCookMinutes }
        set { recipeCookMinutes = newValue }
    }
    
    var formattedPrepTime: String {
        "\(prepHours) h \(prepMinutes) min"
    }
    
    var formattedCookTime: String {
        "\(cookHours) h \(cookMinutes) min"
    }
    
    var note: String {
        get { recipeNote }
        set { recipeNote = newValue }
    }
    
    var servings: Int {
        get { recipeServings }
        set { recipeServings = newValue }
    }
    
    private func validateFields() -> Bool {
        guard !recipeName.isEmpty else {
            return false
        }
        return true
    }
    
    var isInputValid: Bool {
        !recipeName.isEmpty
    }
    
    func addStep(description: String) {
        let newStep = Step(context: moc)
        newStep.id = UUID()
        newStep.descr = description
        newStep.order = Int16(recipeSteps.count + 1)
//        newStep.recipe = recipe
        recipeSteps.append(newStep)
//        do {
//            try moc.save()
//        } catch {
//            print("Error saving context: \(error)")
//        }
    }

    func deleteStep(at offsets: IndexSet) {
        for index in offsets {
            let step = recipeSteps[index]
            moc.delete(step)
            recipeSteps.remove(at: index)
        }
        
        updateStepOrders()
    }
    
    private func updateStepOrders() {
        for (index, step) in recipeSteps.enumerated() {
            step.order = Int16(index + 1)
        }
    }
    
    func addIngredient(name: String, quantity: String, note: String) {
        let newIngredient = Ingredient(context: moc)
        newIngredient.id = UUID()
        newIngredient.name = name
        newIngredient.quantity = quantity.isEmpty ? nil : quantity
        newIngredient.note = note.isEmpty ? nil : note
        //            newIngredient.recipe = recipe
        recipeIngredients.append(newIngredient)
    }
    
    func deleteIngredient(at offsets: IndexSet) {
        for index in offsets {
            let ingredient = recipeIngredients[index]
            moc.delete(ingredient)
            recipeIngredients.remove(at: index)
        }
    }
    
    func addRecipe() {
        guard validateFields() else {
            print("Validation Failed: One or more required fields are empty.")
            return
        }
        
        let totalPrepMinutes = recipePrepHours * 60 + recipePrepMinutes
        let totalCookMinutes = recipeCookHours * 60 + recipeCookMinutes

        let recipeToSave: Recipe
        if let existingRecipe = recipe {
            existingRecipe.name = recipeName
            existingRecipe.descr = recipeDescription
            existingRecipe.note = recipeNote.isEmpty ? nil : recipeNote
            existingRecipe.rating = Int16(recipeRating)
            existingRecipe.prepTime = Int16(totalPrepMinutes)
            existingRecipe.cookTime = Int16(totalCookMinutes)
            existingRecipe.servings = Int16(recipeServings)
            recipeToSave = existingRecipe
        } else {
            let newRecipe = Recipe(context: moc)
            newRecipe.id = UUID()
            newRecipe.name = recipeName
            newRecipe.descr = recipeDescription
            newRecipe.note = recipeNote.isEmpty ? nil : recipeNote
            newRecipe.rating = Int16(recipeRating)
            newRecipe.prepTime = Int16(totalPrepMinutes)
            newRecipe.cookTime = Int16(totalCookMinutes)
            newRecipe.servings = Int16(recipeServings)
            recipeToSave = newRecipe
        }
        
        for step in recipeSteps {
            step.recipe = recipeToSave
            if recipeToSave.steps?.contains(step) == false {
                recipeToSave.addToSteps(step)
            }
        }

        for ingredient in recipeIngredients {
            ingredient.recipe = recipeToSave
            if recipeToSave.ingredients?.contains(ingredient) == false {
                recipeToSave.addToIngredients(ingredient)
            }
        }

        do {
            try moc.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}

