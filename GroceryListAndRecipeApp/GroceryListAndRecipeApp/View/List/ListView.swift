//
//  ListView.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 09/04/2024.
//

import SwiftUI
import CoreData

struct ListView: View {
    private var moc: NSManagedObjectContext
    @StateObject private var listViewModel: ListViewModel

    @State private var isSearchActive = false
    @State private var isSearchBarFocused = false
    @Binding var navColor: Color
    
    init(moc: NSManagedObjectContext, list: CustomList, navColor: Binding<Color>) {
        self.moc = moc
        _listViewModel = StateObject(wrappedValue: ListViewModel(moc: moc, list: list))
        self._navColor = navColor
    }
    
    var body: some View {
        NavigationStack {
            if isSearchActive {
                List(listViewModel.filteredGroceryItems, id: \.name) { item in
                    GroceryItemRow(
                        moc: moc,
                        item: item,
                        listViewModel: listViewModel,
                        onTrack: {
                            listViewModel.trackGroceryItem(item)
                        },
                        isSearchActive: $isSearchActive,
                        isSearchBarFocused: $isSearchBarFocused
                    )
                }
                .listStyle(PlainListStyle())
                .searchable(text: $listViewModel.searchText, isPresented: $isSearchBarFocused, placement: .navigationBarDrawer(displayMode: .always))
                .onChange(of: listViewModel.searchText) { newValue, oldValue in
                    listViewModel.searchItems()
                }
                .onChange(of: isSearchBarFocused) { newValue, oldValue in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
                        isSearchActive = oldValue
                    }
                }
            } else {
                
                HStack {
                    Spacer()

                    Button(action: {
                        isSearchActive = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                            self.isSearchBarFocused = true
                        }
                    }) {
                        HStack {
                            VStack {
                                Image(systemName: "plus")
                                    .imageScale(.large)
                                    .foregroundStyle(.white)
                                    .padding(3)
                            }
                            .background(Color.gray)
                            .clipShape(Circle())
                            Text("Add item")
                        }
                        .padding(4)
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(15)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(maxWidth: 150)
                    
                    Button(action: {
                        listViewModel.showCrossedOutItems.toggle()
                        listViewModel.fetchTrackedItems()
                    }) {
                        Image(systemName: listViewModel.showCrossedOutItems ? "eye" : "eye.slash")
                            .imageScale(.large)
                            .foregroundStyle(listViewModel.getBackgroundColor())
                            .padding(3)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
                
                Spacer()
                
                if listViewModel.isListEmpty {
                    Text("No items")
                        .font(.title)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    CategorizedListView(moc: moc, listViewModel: listViewModel)
                }
            }
        }
        .navigationTitle(listViewModel.getListName())
        .onAppear {
            setNavigationBarColor()
        }
        .onDisappear {
            resetNavigationBarColor()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        listViewModel.crossOutAllItems()
                    }) {
                        HStack {
                            Text("Cross out all items")
                            Image(systemName: "paintbrush")
                                .imageScale(.large)
                                .foregroundColor(.black)
                        }
                    }
                    Button(action: {
                        listViewModel.removeCrossedOutItems()
                    }) {
                        HStack {
                            Text("Remove crossed out items")
                            Image(systemName: "archivebox")
                                .imageScale(.large)
                                .foregroundColor(.black)
                        }
                    }
                    Button(action: {
                        listViewModel.UncrossAllItems()
                    }) {
                        HStack {
                            Text("Uncross all items")
                            Image(systemName: "pencil.slash")
                                .imageScale(.large)
                                .foregroundColor(.black)
                        }
                    }
                    Button(action: {
                        listViewModel.removeAllItems()
                    }) {
                        HStack {
                            Text("Remove all items")
                            Image(systemName: "trash")
                                .imageScale(.large)
                                .foregroundColor(.black)
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .imageScale(.large)
                        .foregroundColor(.black)
                }
            }
        }
    }

    private func setNavigationBarColor() {
        navColor = listViewModel.getBackgroundColor()
    }
    
    private func resetNavigationBarColor() {
        navColor = .primary
    }
}

struct CategorizedListView: View {
    var moc: NSManagedObjectContext
    @ObservedObject var listViewModel: ListViewModel

    var body: some View {
        List {
            ForEach(Array(listViewModel.itemsGroupedByCategory.keys.sorted()), id: \.self) { category in
                Section(header: CenteredHeader(text: category).background(listViewModel.getBackgroundColor())) {
                    ForEach(listViewModel.itemsGroupedByCategory[category] ?? [], id: \.id) { item in
                        VStack(alignment: .leading, spacing: 5) {
                            ItemView(moc: moc,
                                     listViewModel: listViewModel,
                                     item: item)
                            RowSeparator()
                        }
                    }
                    .onDelete { indices in
                        listViewModel.removeTrackedItem(at: indices, from: category)
                    }
                }
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(PlainListStyle())
        .environment(\.defaultMinListRowHeight, 10)
    }
}

struct ItemView: View {
    var moc: NSManagedObjectContext
    @ObservedObject var listViewModel: ListViewModel
    var item: TrackedItem
    @State private var showingDetails = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    let itemText: Text = Text(item.wrappedName).font(.headline) +
                    (item.quantity != nil ? Text(" (\(item.wrappedQuantity))").font(.subheadline) : Text(""))
                    
                    itemText
                        .strikethrough(item.isCrossedOut, color: .red)
                }
                
                if (item.note != nil) {
                    Text(item.wrappedNote)
                        .font(.subheadline)
                        .padding(.top, -10)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: {
                showingDetails = true
            }) {
                Image(systemName: "pencil")
                    .foregroundColor(listViewModel.getBackgroundColor())
                    .frame(width: 60, height: 30)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .background(Color.gray.opacity(0.1))
            .cornerRadius(5)
            .sheet(isPresented: $showingDetails, onDismiss: {
            }) {
                ManageTrackedItemView(moc: moc, trackedItem: item, list: listViewModel.getList(), navColor: listViewModel.getBackgroundColor(), dismissAction: {
                    listViewModel.fetchTrackedItems()
                })
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            listViewModel.toggleCrossOut(for: item)
        }
    }
}

struct GroceryItemRow: View {
    var moc: NSManagedObjectContext
    var item: GroceryItem
    @ObservedObject var listViewModel: ListViewModel
    var onTrack: () -> Void
    @Binding var isSearchActive: Bool
    @Binding var isSearchBarFocused: Bool
    @State private var showingDetails = false
    
    var body: some View {
        HStack {
            Text(item.name)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
                        
            Button(action: {
                showingDetails = true
            }) {
                Image(systemName: "pencil")
                    .foregroundColor(listViewModel.getBackgroundColor())
                    .frame(width: 60, height: 30)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .background(Color.gray.opacity(0.1))
            .cornerRadius(5)
            .sheet(isPresented: $showingDetails, onDismiss: {
            }) {
                ManageTrackedItemView(moc: moc, groceryItem: item, list: listViewModel.getList(), navColor: listViewModel.getBackgroundColor(), dismissAction: {
                    listViewModel.fetchTrackedItems()
                    isSearchActive = false
                    isSearchBarFocused = false
                })
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTrack()
            isSearchActive = false
            isSearchBarFocused = false
        }
    }
}

struct CenteredHeader: View {
    var text: String

    var body: some View {
        HStack {
            Spacer()
            Text(text)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .center)
            Spacer()
        }
//        .background(Color(UIColor.systemGroupedBackground))
        .listRowInsets(EdgeInsets())
    }
}

struct RowSeparator: View {
    var body: some View {
        Rectangle()
            .frame(height: 0.1)
            .foregroundColor(Color(.lightGray))
    }
}
