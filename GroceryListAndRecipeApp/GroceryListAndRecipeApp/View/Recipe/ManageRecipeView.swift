//
//  ManageRecipeView.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 12/04/2024.
//

import SwiftUI
import CoreData

struct ManageRecipeView: View {
    @Environment(\.presentationMode) var presentationMode
    private var moc: NSManagedObjectContext
    @StateObject private var manageRecipeViewModel: ManageRecipeViewModel
    @State private var showingPrepTimePicker = false
    @State private var showingCookTimePicker = false
    @State private var showingStepEditor = false
    @State private var showingIngredientEditor = false
    @FocusState private var focusedField: Field?

    enum Field {
        case note
        case servings
    }
    
    init(moc: NSManagedObjectContext, recipe: Recipe? = nil) {
        self.moc = moc
        _manageRecipeViewModel = StateObject(wrappedValue: ManageRecipeViewModel(moc: moc, recipe: recipe))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section() {
                    TextField("Recipe name", text: $manageRecipeViewModel.name)
                    TextField("Description", text: $manageRecipeViewModel.description)
                }
                
                Section(header: Text("Recipe Details")) {
                    HStack {
                        Text("Rating")
                        Spacer()
                        PickStarRatingView(rating: $manageRecipeViewModel.rating)
                    }
                    HStack {
                        Text("Servings")
                        Spacer()
                        TextField("Number of servings", text: Binding<String>(
                            get: {
                                manageRecipeViewModel.servings > 0 ? String(manageRecipeViewModel.servings) : ""
                            },
                            set: {
                                if let value = Int($0) {
                                    manageRecipeViewModel.servings = value
                                } else if $0.isEmpty {
                                    manageRecipeViewModel.servings = 0
                                }
                            }
                        ))
                        .focused($focusedField, equals: .servings)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                    }
                    HStack {
                        Text("Prep Time")
                        Spacer()
                        Button(action: {
                            print("Opening TimePicker with prepHours: \(manageRecipeViewModel.prepHours), prepMinutes: \(manageRecipeViewModel.prepMinutes)")
                            showingPrepTimePicker = true
                        }) {
                            HStack {
                                Text(manageRecipeViewModel.formattedPrepTime)
                                    .foregroundColor(.gray)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .sheet(isPresented: $showingPrepTimePicker) {
                            NavigationView {
                                    TimePickerView(hours: $manageRecipeViewModel.prepHours, minutes: $manageRecipeViewModel.prepMinutes)
                                        .navigationTitle("Prep Time")
                                        .navigationBarTitleDisplayMode(.inline)
                                        .onDisappear {
                                            focusedField = nil
                                        }
                                }
                        }
                    }
                    
                    HStack {
                        Text("Cook Time")
                        Spacer()
                        Button(action: {
                            print("Opening TimePicker with cookHours: \(manageRecipeViewModel.cookHours), cookMinutes: \(manageRecipeViewModel.cookMinutes)")
                            showingCookTimePicker = true
                        }) {
                            HStack {
                                Text(manageRecipeViewModel.formattedCookTime)
                                    .foregroundColor(.gray)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .sheet(isPresented: $showingCookTimePicker) {
                            NavigationView {
                                TimePickerView(hours: $manageRecipeViewModel.cookHours, minutes: $manageRecipeViewModel.cookMinutes)
                                    .navigationTitle("Cook Time")
                                    .navigationBarTitleDisplayMode(.inline)
                                    .onDisappear {
                                        focusedField = nil
                                    }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Note")
                        TextEditor(text: $manageRecipeViewModel.note)
                            .focused($focusedField, equals: .note)
                            .frame(minHeight: 30)
                    }
                }
                
                Section(header: Text("Steps")) {
                    ForEach(manageRecipeViewModel.recipeSteps, id: \.id) { step in
                        Text("\(step.order). \(step.wrappedDescription)")
                    }
                    .onDelete(perform: manageRecipeViewModel.deleteStep)
                    Button(action: {
                        showingStepEditor = true
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
                            Text("Add step")
                        }
                        .padding(6)
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(15)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding([.horizontal, .bottom], 16)
                    .sheet(isPresented: $showingStepEditor) {
                        StepEditorView(manageRecipeViewModel: manageRecipeViewModel)
                    }
                }
                
                Section(header: Text("Ingredients")) {
                    ForEach(manageRecipeViewModel.recipeIngredients, id: \.id) { ingredient in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                let itemText: Text = Text(ingredient.wrappedName).font(.headline) +
                                (ingredient.quantity != nil ? Text(" (\(ingredient.wrappedQuantity))").font(.subheadline) : Text(""))
                                
                                itemText
                            }
                            
                            if (ingredient.note != nil) {
                                Text(ingredient.wrappedNote)
                                    .font(.subheadline)
                                    .padding(.top, -10)
                            }
                        }
                    }
                    .onDelete(perform: manageRecipeViewModel.deleteIngredient)

                    Button(action: {
                        showingIngredientEditor = true
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
                            Text("Add ingredient")
                        }
                        .padding(6)
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(15)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding([.horizontal, .bottom], 16)
                    .sheet(isPresented: $showingIngredientEditor) {
                        IngredientEditorView(manageRecipeViewModel: manageRecipeViewModel)
                    }
                }
            }
            .navigationBarTitle(manageRecipeViewModel.isEditMode ? "Edit Recipe" : "New Recipe", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                manageRecipeViewModel.addRecipe()
                presentationMode.wrappedValue.dismiss()
            }
                .disabled(!manageRecipeViewModel.isInputValid))
        }
    }
}

struct PickStarRatingView: View {
    @Binding var rating: Int

    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .foregroundColor(star <= rating ? .yellow : .gray)
                    .onTapGesture {
                        if rating == star {
                            rating = 0
                        } else {
                            rating = star
                        }
                    }
            }
        }
    }
}

struct TimePickerView: View {
    @Binding var hours: Int
    @Binding var minutes: Int

    var body: some View {
        VStack {
            HStack {
                Picker("Hours", selection: $hours) {
                    ForEach(0..<49, id: \.self) { hour in
                        Text("\(hour) \(hour == 1 ? "hour" : "hours")").tag(hour)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 150, height: 200, alignment: .center)
                .clipped()
                .compositingGroup()
                .padding(.leading, 20)
                
                Picker("Minutes", selection: $minutes) {
                    ForEach(0..<60, id: \.self) { minute in
                        Text("\(minute) \(minute == 1 ? "minute" : "minutes")").tag(minute)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 150, height: 200, alignment: .center)
                .clipped()
                .compositingGroup()
                .padding(.trailing, 20)
            }
            .background(Color(UIColor.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 5)
            
            Spacer()
        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

struct StepEditorView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var manageRecipeViewModel: ManageRecipeViewModel
    @State private var stepDescription = ""

    var body: some View {
        NavigationView {
            TextEditor(text: $stepDescription)
                .padding()
                .navigationBarTitle("Add Step", displayMode: .inline)
                .navigationBarItems(leading: Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                }, trailing: Button("Add") {
                    manageRecipeViewModel.addStep(description: stepDescription)
                    dismiss()
                }.disabled(stepDescription.isEmpty))
        }
    }
}

struct IngredientEditorView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var manageRecipeViewModel: ManageRecipeViewModel
    @State private var name = ""
    @State private var quantity = ""
    @State private var note = ""

    var body: some View {
        NavigationView {
            Form {
                HStack {
                    Text("Ingredient name")
                    Spacer()
                    TextField("Not set", text: $name)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Quantity")
                    Spacer()
                    TextField("Quantity", text: $quantity)
                        .multilineTextAlignment(.trailing)
                }
                VStack(alignment: .leading) {
                    Text("Note")
                    TextEditor(text: $note)
                        .frame(height: 100)
                }
//                HStack {
//                    Text("Note")
//                    Spacer()
//                    TextField("Note", text: $note)
//                        .multilineTextAlignment(.trailing)
//                }
            }
            .navigationBarTitle("Add Ingredient", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            }, trailing: Button("Add") {
                manageRecipeViewModel.addIngredient(name: name, quantity: quantity, note: note)
                dismiss()
            }.disabled(name.isEmpty || quantity.isEmpty))
        }
    }
}
