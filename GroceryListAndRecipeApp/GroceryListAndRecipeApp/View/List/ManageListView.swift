//
//  AddListView.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 08/04/2024.
//

import SwiftUI
import CoreData

struct ManageListView: View {
    @Environment(\.presentationMode) var presentationMode
    private var moc: NSManagedObjectContext
    @StateObject private var manageListViewModel: ManageListViewModel
    
    init(moc: NSManagedObjectContext, list: CustomList? = nil) {
        self.moc = moc
        _manageListViewModel = StateObject(wrappedValue: ManageListViewModel(moc: moc, list: list))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("List Details")) {
                    TextField("List Name", text: $manageListViewModel.name)
                    TextField("Description", text: $manageListViewModel.description)
                }
                
                Section(header: Text("List Settings")) {
                    HStack {
                        Text("Type")
                        Spacer()
                        Menu {
                            Button("Grocery List", action: { manageListViewModel.type = "Grocery List" })
//                            Button("Basic List", action: { manageListViewModel.type = "Basic List" })
                        } label: {
                            Text("\(manageListViewModel.type)")
                            Image(systemName: "chevron.right")
                        }
                        .disabled(manageListViewModel.isEditMode)
                    }
                    
                    HStack {
                        Text("Theme")
                        Spacer()
                        Menu {
                            Button("Blue", action: { manageListViewModel.theme = "Blue" })
                            Button("Orange", action: { manageListViewModel.theme = "Orange" })
                            Button("Red", action: { manageListViewModel.theme = "Red" })
                            Button("Green", action: { manageListViewModel.theme = "Green" })
                            Button("Gray", action: { manageListViewModel.theme = "Gray" })
                        } label: {
                            Text("\(manageListViewModel.theme)")
                            Image(systemName: "chevron.right")
                        }
                    }
                }
            }
            .navigationBarTitle(manageListViewModel.isEditMode ? "Edit List" : "New List", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .navigationBarItems(trailing: Button("Save") {
                manageListViewModel.addList();
                presentationMode.wrappedValue.dismiss()
            }
            .disabled(!manageListViewModel.isInputValid))
        }
    }
}
