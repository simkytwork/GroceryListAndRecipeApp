//
//  RecipesView.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 08/04/2024.
//

import SwiftUI
import CoreData

struct RecipesView: View {
    private var moc: NSManagedObjectContext
    @State private var showingManageRecipeView = false
    @StateObject private var recipesViewModel: RecipesViewModel
    
    init(moc: NSManagedObjectContext) {
        self.moc = moc
        _recipesViewModel = StateObject(wrappedValue: RecipesViewModel(moc: moc))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(recipesViewModel.recipes, id: \.id) { recipe in
                        ZStack {
                            NavigationLink(destination: RecipeView(moc: moc, recipe: recipe)) {
                                EmptyView()
                            }
                            .opacity(0.0)
                            .buttonStyle(PlainButtonStyle())
                            
                            VStack(alignment: .leading, spacing: 20) {
                                HStack {
                                    Text(recipe.wrappedName)
                                        .font(.title2)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        recipesViewModel.chosenRecipe = recipe
                                        showingManageRecipeView = true
                                    }) {
                                        Image(systemName: "ellipsis")
                                            .imageScale(.large)
                                            .foregroundColor(.black)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(10)
                                    .contentShape(Rectangle())
                                }
                                Text(recipe.wrappedDescription)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .listRowSeparator(.hidden)
                    }
                    .onDelete(perform: recipesViewModel.deleteRecipe)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 16)
                }
                .listStyle(PlainListStyle())
                
                Spacer()
                
                ManageRecipeViewButton(showingManageRecipeView: $showingManageRecipeView, moc: moc, recipesViewModel: recipesViewModel)
                    .searchable(text: $recipesViewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
                    .onChange(of: recipesViewModel.searchText) { newValue, oldValue in
                        recipesViewModel.searchRecipes()
                    }
            }
            .sheet(isPresented: $showingManageRecipeView, onDismiss: {
                recipesViewModel.fetchRecipes()
                recipesViewModel.searchRecipes()
            }) {
                ManageRecipeView(moc: moc, recipe: recipesViewModel.chosenRecipe)
            }
            .navigationBarTitle("My Recipes", displayMode: .inline)
        }
    }
}

struct ManageRecipeViewButton: View {
    @Binding var showingManageRecipeView: Bool
    var moc: NSManagedObjectContext
    @Environment(\.isSearching) var isSearching
    @ObservedObject var recipesViewModel: RecipesViewModel
    
    var body: some View {
        if !isSearching {
            Button(action: {
                recipesViewModel.chosenRecipe = nil
                showingManageRecipeView = true
            }) {
                HStack {
                    VStack {
                        Image(systemName: "plus")
                            .imageScale(.large)
                            .foregroundStyle(.white)
                            .padding(6)
                    }
                    .background(Color.gray)
                    .clipShape(Circle())
                    Text("New recipe")
                }
                .padding(6)
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(15)
            }
            .buttonStyle(PlainButtonStyle())
            .padding([.horizontal, .bottom], 16)
        }
    }
}
