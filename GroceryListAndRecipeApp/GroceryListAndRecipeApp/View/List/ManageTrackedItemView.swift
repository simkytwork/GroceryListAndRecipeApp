//
//  ManageTrackedItemView.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 19/04/2024.
//

import SwiftUI
import CoreData

struct ManageTrackedItemView: View {
    private var moc: NSManagedObjectContext
    @StateObject private var manageTrackedItemViewModel: ManageTrackedItemViewModel
    @Environment(\.presentationMode) var presentationMode
    var dismissAction: () -> Void
    
    @State private var showingCategoryMenu = false
    private var navColor: Color
    
    init(moc: NSManagedObjectContext, groceryItem: GroceryItem? = nil, trackedItem: TrackedItem? = nil, list: CustomList? = nil, navColor: Color, dismissAction: @escaping () -> Void) {
        self.moc = moc
        self.dismissAction = dismissAction
        _manageTrackedItemViewModel = StateObject(wrappedValue: ManageTrackedItemViewModel(moc: moc, groceryItem: groceryItem, trackedItem: trackedItem, list: list))
        self.navColor = navColor
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Main Information")) {
                    TextField("Name", text: $manageTrackedItemViewModel.name)
                    TextField("Add note", text: $manageTrackedItemViewModel.note)
                }
                
                Section(header: Text("Details")) {
                    HStack {
                        Text("Category")
                        Spacer()
                        Menu {
                            ForEach(manageTrackedItemViewModel.categories, id: \.self) { category in
                                Button(category, action: { manageTrackedItemViewModel.category = category })
                            }
                        } label: {
                            Text(manageTrackedItemViewModel.category.isEmpty ? "Select Category" : manageTrackedItemViewModel.category)
                            Image(systemName: "chevron.right")
                        }
                    }
                    
                    HStack {
                        Text("Quantity")
                        Spacer()
                        TextField("Not set", text: $manageTrackedItemViewModel.quantity)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationBarTitle(manageTrackedItemViewModel.trackedItem != nil ? "Edit Item" : "Add Item", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .navigationBarItems(trailing: Button(manageTrackedItemViewModel.trackedItem != nil ? "Save" : "Add") {
                manageTrackedItemViewModel.saveItem()
                dismissAction()
                presentationMode.wrappedValue.dismiss()
            })
        }
        .accentColor(navColor)
    }
}
