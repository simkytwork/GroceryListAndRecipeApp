//
//  CustomList+CoreDataProperties.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 10/04/2024.
//
//

import Foundation
import CoreData


extension CustomList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CustomList> {
        return NSFetchRequest<CustomList>(entityName: "CustomList")
    }

    @NSManaged public var name: String?
    public var wrappedName: String {
        name ?? "Unknown name"
    }
    @NSManaged public var descr: String?
    public var wrappedDescription: String {
        descr ?? "Unknown description"
    }
    @NSManaged public var type: String?
    public var wrappedType: String {
        type ?? "Unknown type"
    }
    @NSManaged public var theme: String?
    public var wrappedTheme: String {
        theme ?? "Unknown theme"
    }
    @NSManaged public var id: UUID?
    @NSManaged public var items: NSSet?
    public var itemsArray: [TrackedItem] {
        let set = items as? Set<TrackedItem> ?? []
        return set.sorted {
            $0.id < $1.id
        }
    }
}

// MARK: Generated accessors for items
extension CustomList {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: TrackedItem)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: TrackedItem)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}

extension CustomList : Identifiable {

}
