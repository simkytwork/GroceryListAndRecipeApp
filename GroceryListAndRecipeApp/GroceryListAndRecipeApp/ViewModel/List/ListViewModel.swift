//
//  ListViewModel.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 10/04/2024.
//

import SwiftUI
import CoreData

class ListViewModel: ObservableObject {
    private var moc: NSManagedObjectContext
    private var list: CustomList
    @Published var allGroceryItems: [GroceryItem] = []
    @Published var filteredGroceryItems: [GroceryItem] = []
    @Published var searchText = ""
    @Published var itemsGroupedByCategory = [String: [TrackedItem]]()
    @Published private var allTrackedItems = [TrackedItem]()
    @Published var showCrossedOutItems = true
    
    init(moc: NSManagedObjectContext, list: CustomList) {
        self.moc = moc
        self.list = list
        fetchTrackedItems()
        loadItems()
    }
    
    func getListName() -> String {
        return list.wrappedName
    }
    
    func getListItems() -> [TrackedItem] {
        return list.itemsArray
    }
    
    func getList() -> CustomList {
        return list
    }
    
    func getBackgroundColor() -> Color {
        switch list.theme {
        case "Blue":
            return Color(.systemBlue)
        case "Orange":
            return .orange
        case "Red":
            return .red
        case "Green":
            return .green
        case "Gray":
            return .gray
        default:
            return .gray
        }
    }
    
    func fetchTrackedItems() {
        let request: NSFetchRequest<TrackedItem> = TrackedItem.fetchRequest()
        
        var predicates = [NSPredicate(format: "list == %@", list)]
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TrackedItem.category, ascending: true)]

        do {
            let results = try moc.fetch(request)
            self.allTrackedItems = results
            self.itemsGroupedByCategory = Dictionary(grouping: results, by: { $0.wrappedCategory })

        } catch {
            print("Failed to fetch tracked items: \(error)")
        }
        
        if !showCrossedOutItems {
            predicates.append(NSPredicate(format: "isCrossedOut == NO"))
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            
            do {
                let results = try moc.fetch(request)
                self.itemsGroupedByCategory = Dictionary(grouping: results, by: { $0.wrappedCategory })
            } catch {
                print("Failed to fetch tracked items: \(error)")
            }
        }
        
        searchText = ""
        filteredGroceryItems = []
    }
    
    var isListEmpty: Bool {
        itemsGroupedByCategory.values.allSatisfy { $0.isEmpty }
    }
    
    func toggleCrossOut(for item: TrackedItem) {
        item.isCrossedOut.toggle()
        do {
            try moc.save()
        } catch {
            print("Failed to save context: \(error)")
        }
        objectWillChange.send()
        fetchTrackedItems()
    }
    
    func loadItems() {
        guard let url = Bundle.main.url(forResource: "groceryItems", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load groceryItems.json from bundle.")
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode([String: String].self, from: data)
            self.allGroceryItems = decoded.map { GroceryItem(name: $0.key, category: $0.value) }
        } catch {
            print("Failed to decode items: \(error)")
        }
    }
    
    func searchItems() {
        if searchText.isEmpty {
            filteredGroceryItems = []
        } else {
            filteredGroceryItems = allGroceryItems.filter { item in
                item.name.lowercased().contains(searchText.lowercased())
            }
            
            let displayItemName = "Add '\(searchText)'"
            if let existingItem = allGroceryItems.first(where: { $0.name.lowercased() == searchText.lowercased() }) {
                let newItem = GroceryItem(name: displayItemName, category: existingItem.category)
                filteredGroceryItems.insert(newItem, at: 0)
            } else {
                let newItem = GroceryItem(name: displayItemName, category: "Others")
                filteredGroceryItems.insert(newItem, at: 0)
            }
        }
    }
    
    func trackGroceryItem(_ item: GroceryItem) {
        let newItem = TrackedItem(context: moc)
        newItem.id = UUID()
        
        let actualItemName = item.name.replacingOccurrences(of: "Add '", with: "").replacingOccurrences(of: "'", with: "")
        newItem.name = actualItemName
        
        newItem.category = item.category
        newItem.list = list
        newItem.isCrossedOut = false
        
        list.addToItems(newItem)
        do {
            try moc.save()
        } catch {
            print("Failed to save context: \(error)")
        }
        searchText = ""
        filteredGroceryItems = []
        
        fetchTrackedItems()
    }
    
    func removeTrackedItem(at indices: IndexSet, from category: String) {
        guard let index = indices.first,
              var categoryItems = itemsGroupedByCategory[category] else { return }
        
        let itemToDelete = categoryItems[index]
        list.removeFromItems(itemToDelete)
        moc.delete(itemToDelete)
        
        categoryItems.remove(at: index)
        if categoryItems.isEmpty {
            itemsGroupedByCategory.removeValue(forKey: category)
        } else {
            itemsGroupedByCategory[category] = categoryItems
        }
        
        do {
            try moc.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    func removeCrossedOutItems() {
//        let allCategories = itemsGroupedByCategory.keys
//        for category in allCategories {
//            guard let items = itemsGroupedByCategory[category] else { continue }
            for item in allTrackedItems where item.isCrossedOut {
                list.removeFromItems(item)
                moc.delete(item)
            }
//        }
        
        do {
            try moc.save()
        } catch {
            print("Failed to save context after removing crossed out items: \(error)")
        }
        
        fetchTrackedItems()
    }
    
    func crossOutAllItems() {
//        let allCategories = itemsGroupedByCategory.keys
//        for category in allCategories {
//            guard let items = itemsGroupedByCategory[category] else { continue }
            for item in allTrackedItems {
                item.isCrossedOut = true
            }
//        }
        
        do {
            try moc.save()
        } catch {
            print("Failed to save context after crossing out all items: \(error)")
        }
        
        fetchTrackedItems()
    }
    
    func UncrossAllItems() {
//        let allCategories = itemsGroupedByCategory.keys
//        for category in allCategories {
//            guard let items = itemsGroupedByCategory[category] else { continue }
            for item in allTrackedItems {
                item.isCrossedOut = false
            }
//        }
        
        do {
            try moc.save()
        } catch {
            print("Failed to save context after uncrossing all items: \(error)")
        }
        
        fetchTrackedItems()
    }
    
    func removeAllItems() {
//        let allCategories = itemsGroupedByCategory.keys
//        for category in allCategories {
//            guard let items = itemsGroupedByCategory[category] else { continue }
            for item in allTrackedItems {
                list.removeFromItems(item)
                moc.delete(item)
            }
//        }
        
        do {
            try moc.save()
        } catch {
            print("Failed to save context after removing all items: \(error)")
        }
        
        fetchTrackedItems()
    }
}
