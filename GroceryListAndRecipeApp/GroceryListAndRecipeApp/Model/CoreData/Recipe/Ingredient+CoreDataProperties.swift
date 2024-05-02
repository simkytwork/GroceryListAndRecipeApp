//
//  Ingredient+CoreDataProperties.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 21/04/2024.
//
//

import Foundation
import CoreData


extension Ingredient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ingredient> {
        return NSFetchRequest<Ingredient>(entityName: "Ingredient")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    public var wrappedName: String {
        name ?? "Unknown name"
    }
    @NSManaged public var quantity: String?
    public var wrappedQuantity: String {
        quantity ?? "Unknown quantity"
    }
    @NSManaged public var note: String?
    public var wrappedNote: String {
        note ?? "Unknown note"
    }
    @NSManaged public var recipe: Recipe?

}

extension Ingredient : Identifiable {

}
