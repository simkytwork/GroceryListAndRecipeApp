//
//  RecipeView.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 13/04/2024.
//

import SwiftUI
import CoreData

struct RecipeView: View {
    private var moc: NSManagedObjectContext
    @StateObject private var recipeViewModel: RecipeViewModel
    @State private var selectedSection: String = "Ingredients"

    init(moc: NSManagedObjectContext, recipe: Recipe) {
        self.moc = moc
        _recipeViewModel = StateObject(wrappedValue: RecipeViewModel(moc: moc, recipe: recipe))
    }
    
    var body: some View {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("\(recipeViewModel.recipe.wrappedName)")
                        .font(.title)
                    Text("\(recipeViewModel.recipe.wrappedDescription)")
                }
                .padding(.leading, 30)

                Divider()

                Form {
                    Section(header: Text("Recipe Details")) {
                        HStack {
                            Text("Rating")
                            Spacer()
                            StarRatingView(rating: recipeViewModel.intRating)
                        }
                        
                        HStack {
                            Text("Servings")
                            Spacer()
                            if (recipeViewModel.recipe.servings == 0) {
                                Text("Not set")
                            } else {
                                Text("\(recipeViewModel.recipe.servings)")
                            }
                        }
                        
                        HStack {
                            Text("Prep Time")
                            Spacer()
                            Text(recipeViewModel.formattedPrepTime)
                        }
                        
                        HStack {
                            Text("Cook Time")
                            Spacer()
                            Text(recipeViewModel.formattedCookTime)
                        }
                        
                        if (recipeViewModel.recipe.note != nil) {
                            VStack(alignment: .leading) {
                                Text("Note")
                                Text(recipeViewModel.recipe.wrappedNote)
                            }
                        }
                    }
                    
                    Picker("Select", selection: $selectedSection) {
                        Text("Ingredients").tag("Ingredients")
                        Text("Steps").tag("Steps")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Section() {
                        if selectedSection == "Ingredients" {
                            if recipeViewModel.recipe.ingredientsArray.isEmpty {
                                Text("No ingredients were added")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else {
                                ForEach(recipeViewModel.recipe.ingredientsArray, id: \.id) { ingredient in
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack {
                                            let itemText: Text = Text(ingredient.wrappedName).font(.headline) +
                                            (ingredient.quantity != nil ? Text(" (\(ingredient.wrappedQuantity))").font(.subheadline) : Text(""))
                                            
                                            itemText.padding(.top, 5)
                                        }
                                        
                                        if (ingredient.note != nil) {
                                            Text(ingredient.wrappedNote)
                                                .font(.subheadline)
                                                .padding(.top, -10)
                                        }
                                    }
                                }
                            }
                        } else {
                            if recipeViewModel.recipe.stepsArray.isEmpty {
                                Text("No steps were added")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else {
                                ForEach(recipeViewModel.recipe.stepsArray, id: \.id) { step in
                                    Text("\(step.order). \(step.wrappedDescription)")
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationBarTitle("Recipe", displayMode: .inline)
            }
        }
}

struct StarRatingView: View {
    var rating: Int

    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .foregroundColor(star <= rating ? .yellow : .gray)
            }
        }
    }
}
