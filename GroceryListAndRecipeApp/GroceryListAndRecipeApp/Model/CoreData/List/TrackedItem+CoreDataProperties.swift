//
//  TrackedItem+CoreDataProperties.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 17/04/2024.
//
//

import Foundation
import CoreData


extension TrackedItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackedItem> {
        return NSFetchRequest<TrackedItem>(entityName: "TrackedItem")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var quantity: String?
    public var wrappedQuantity: String {
        quantity ?? "Unknown quantity"
    }
    @NSManaged public var category: String?
    public var wrappedCategory: String {
        category ?? "Unknown category"
    }
    @NSManaged public var name: String?
    public var wrappedName: String {
        name ?? "Unknown name"
    }
    @NSManaged public var note: String?
    public var wrappedNote: String {
        note ?? "Unknown note"
    }
    @NSManaged public var isCrossedOut: Bool
    @NSManaged public var list: CustomList?

}

extension TrackedItem : Identifiable {

}
