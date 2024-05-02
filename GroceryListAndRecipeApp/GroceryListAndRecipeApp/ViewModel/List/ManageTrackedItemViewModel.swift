//
//  ManageTrackedItem.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 11/04/2024.
//

import SwiftUI
import CoreData

class ManageTrackedItemViewModel: ObservableObject {
    private var moc: NSManagedObjectContext
    @Published var name: String = ""
    @Published var note: String = ""
    @Published var category: String = ""
    @Published var quantity: String = ""
    @Published var categories: [String] = []

    var list: CustomList?
    var groceryItem: GroceryItem?
    var trackedItem: TrackedItem?
    
    init(moc: NSManagedObjectContext, groceryItem: GroceryItem? = nil, trackedItem: TrackedItem? = nil, list: CustomList? = nil) {
        self.moc = moc
        self.groceryItem = groceryItem
        self.trackedItem = trackedItem
        self.list = list
        
        if let trackedItem = trackedItem {
            name = trackedItem.wrappedName
            note = trackedItem.note != nil ? trackedItem.wrappedNote : ""
            category = trackedItem.wrappedCategory
            quantity = trackedItem.quantity != nil ? trackedItem.wrappedQuantity : ""
        } else if let groceryItem = groceryItem {
            name = groceryItem.name.replacingOccurrences(of: "Add '", with: "").replacingOccurrences(of: "'", with: "")
            category = groceryItem.category
        }
        loadCategories()
    }
    
    func loadCategories() {
        if let url = Bundle.main.url(forResource: "groceryItemCategories", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let jsonResult = try JSONDecoder().decode([String: [String]].self, from: data)
                categories = jsonResult["categories"] ?? []
            } catch {
                print("Error loading categories: \(error)")
            }
        }
    }
    
    func saveItem() {
        if let groceryItem = groceryItem {
            let newTrackedItem = TrackedItem(context: moc)
            newTrackedItem.id = UUID()
            newTrackedItem.isCrossedOut = false
            newTrackedItem.name = name
            newTrackedItem.note = note.isEmpty ? nil : note
            newTrackedItem.category = category
            newTrackedItem.quantity = quantity.isEmpty ? nil : quantity
            newTrackedItem.list = list
        } else if let trackedItem = trackedItem {
            trackedItem.name = name
            trackedItem.note = note.isEmpty ? nil : note
            trackedItem.category = category
            trackedItem.quantity = quantity.isEmpty ? nil : quantity
        }
        
        do {
            try moc.save()
        } catch {
            print("Failed to save item: \(error)")
        }
    }
}
