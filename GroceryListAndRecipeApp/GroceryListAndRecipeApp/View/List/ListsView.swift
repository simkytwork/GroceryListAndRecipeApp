//
//  ContentView.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 08/04/2024.
//

import SwiftUI
import CoreData

struct ListsView: View {
    private var moc: NSManagedObjectContext
    @State private var showingManageListView = false
    @StateObject private var listsViewModel: ListsViewModel
    @State private var navColor = Color.primary
    
    init(moc: NSManagedObjectContext) {
        self.moc = moc
        _listsViewModel = StateObject(wrappedValue: ListsViewModel(moc: moc))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(listsViewModel.lists, id: \.id) { list in
                        ZStack {
                            NavigationLink(destination: ListView(moc: moc, list: list, navColor: $navColor)) {
                                EmptyView()
                            }
                            .opacity(0.0)
                            .buttonStyle(PlainButtonStyle())

                            VStack(alignment: .leading, spacing: 20) {
                                HStack {
                                    Text(list.wrappedName)
                                        .font(.title2)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        listsViewModel.chosenList = list
                                        showingManageListView = true
                                    }) {
                                        Image(systemName: "ellipsis")
                                            .imageScale(.large)
                                            .foregroundColor(.black)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(10)
                                    .contentShape(Rectangle())
                                }
                                Text(list.wrappedDescription)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(listsViewModel.getBackgroundColor(list: list).opacity(0.3), lineWidth: 3)
                            )
                        }
                        .listRowSeparator(.hidden)
                    }
                    .onDelete(perform: listsViewModel.deleteList)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 16)
                }
                .listStyle(PlainListStyle())
                
                Spacer()
                
                ManageListViewButton(showingManageListView: $showingManageListView, moc: moc, listsViewModel: listsViewModel)
                    .searchable(text: $listsViewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
                    .onChange(of: listsViewModel.searchText) { newValue, oldValue in
                        listsViewModel.searchLists()
                    }
            }
            .sheet(isPresented: $showingManageListView, onDismiss: {
                listsViewModel.fetchLists()
                listsViewModel.searchLists()
            }) {
                ManageListView(moc: moc, list: listsViewModel.chosenList)
            }
            .navigationBarTitle("My Lists", displayMode: .inline)
        }
        .accentColor(navColor)
    }
}

struct ManageListViewButton: View {
    @Binding var showingManageListView: Bool
    var moc: NSManagedObjectContext
    @Environment(\.isSearching) var isSearching
    @ObservedObject var listsViewModel: ListsViewModel

    var body: some View {
        if !isSearching {
            Button(action: {
                listsViewModel.chosenList = nil
                showingManageListView = true
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
                    Text("New list")
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
