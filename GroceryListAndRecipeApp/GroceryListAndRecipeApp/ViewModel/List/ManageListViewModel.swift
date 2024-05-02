//
//  AddListViewModel.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 08/04/2024.
//

import SwiftUI
import CoreData

class ManageListViewModel: ObservableObject {
    private var moc: NSManagedObjectContext
    private var list: CustomList?

    @Published private var listName: String = ""
    @Published private var listDescription: String = ""
    @Published private var listType: String = "Grocery List"
    @Published private var listTheme: String = "Blue"
    
    var isEditMode: Bool {
        return list != nil
    }
    
    init(moc: NSManagedObjectContext, list: CustomList? = nil) {
        self.moc = moc
        self.list = list
        if let list = list {
            listName = list.wrappedName
            listDescription = list.wrappedDescription
            listType = list.wrappedType
            listTheme = list.wrappedTheme
        }
    }
    
    var name: String {
        get { listName }
        set { listName = newValue }
    }
    
    var description: String {
        get { listDescription }
        set { listDescription = newValue }
    }
    
    var type: String {
        get { listType }
        set { listType = newValue }
    }
    
    var theme: String {
        get { listTheme }
        set { listTheme = newValue }
    }
    
    private func validateFields() -> Bool {
        guard !listName.isEmpty, !listType.isEmpty, !listTheme.isEmpty else {
            return false
        }
        return true
    }
    
    var isInputValid: Bool {
        !listName.isEmpty && !listType.isEmpty && !listTheme.isEmpty
    }
    
    func addList() {
        guard validateFields() else {
            print("Validation Failed: One or more required fields are empty.")
            return
        }
        
        if let list = list {
            list.name = listName
            list.descr = listDescription
            list.type = listType
            list.theme = listTheme
        } else {
            let newList = CustomList(context: moc)
            newList.id = UUID()
            newList.name = listName
            newList.descr = listDescription
            newList.type = listType
            newList.theme = listTheme
        }
        
        do {
            try moc.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
