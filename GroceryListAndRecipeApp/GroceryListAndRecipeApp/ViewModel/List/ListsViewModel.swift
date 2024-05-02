//
//  listsViewModel.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 09/04/2024.
//

import SwiftUI
import CoreData

class ListsViewModel: ObservableObject {
    private var moc: NSManagedObjectContext
    @Published var chosenList: CustomList?
    @Published var lists: [CustomList] = []
    @Published var searchText = ""
    private var allLists: [CustomList] = []

    init(moc: NSManagedObjectContext) {
        self.moc = moc
        fetchLists()
    }
    
    func getBackgroundColor(list: CustomList) -> Color {
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
    
    func fetchLists() {
        let request: NSFetchRequest<CustomList> = CustomList.fetchRequest()
        do {
            allLists = try moc.fetch(request)
            lists = allLists
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func deleteList(at offsets: IndexSet) {
        for index in offsets {
            let list = lists[index]
            moc.delete(list)
        }
        
        do {
            try moc.save()
        } catch {
            print("Error saving context: \(error)")
        }
        
        fetchLists()
        searchLists()
    }
    
    func searchLists() {
        if searchText.isEmpty {
            lists = allLists
        } else {
            lists = allLists.filter { list in
                list.name?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
    }
}
