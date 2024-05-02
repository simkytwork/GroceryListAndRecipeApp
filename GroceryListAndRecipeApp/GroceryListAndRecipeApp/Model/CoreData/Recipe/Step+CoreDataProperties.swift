//
//  Step+CoreDataProperties.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 21/04/2024.
//
//

import Foundation
import CoreData


extension Step {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Step> {
        return NSFetchRequest<Step>(entityName: "Step")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var descr: String?
    public var wrappedDescription: String {
        descr ?? "Unknown description"
    }
    @NSManaged public var order: Int16
    @NSManaged public var recipe: Recipe?

}

extension Step : Identifiable {

}
