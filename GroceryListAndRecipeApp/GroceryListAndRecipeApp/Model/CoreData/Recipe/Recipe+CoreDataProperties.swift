//
//  Recipe+CoreDataProperties.swift
//  GroceryListAndRecipeApp
//
//  Created by Simonas Kytra on 21/04/2024.
//
//

import Foundation
import CoreData


extension Recipe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipe> {
        return NSFetchRequest<Recipe>(entityName: "Recipe")
    }

    @NSManaged public var name: String?
    public var wrappedName: String {
        name ?? "Unknown name"
    }
    @NSManaged public var descr: String?
    public var wrappedDescription: String {
        descr ?? "Unknown description"
    }
    @NSManaged public var prepTime: Int16
    @NSManaged public var cookTime: Int16
    @NSManaged public var rating: Int16
    @NSManaged public var servings: Int16
    @NSManaged public var note: String?
    public var wrappedNote: String {
        note ?? "Unknown note"
    }
    @NSManaged public var id: UUID?
    @NSManaged public var steps: NSSet?
    public var stepsArray: [Step] {
        let set = steps as? Set<Step> ?? []
        return set.sorted {
            $0.id < $1.id
        }
    }
    @NSManaged public var ingredients: NSSet?
    public var ingredientsArray: [Ingredient] {
        let set = ingredients as? Set<Ingredient> ?? []
        return set.sorted {
            $0.id < $1.id
        }
    }
}

// MARK: Generated accessors for steps
extension Recipe {

    @objc(addStepsObject:)
    @NSManaged public func addToSteps(_ value: Step)

    @objc(removeStepsObject:)
    @NSManaged public func removeFromSteps(_ value: Step)

    @objc(addSteps:)
    @NSManaged public func addToSteps(_ values: NSSet)

    @objc(removeSteps:)
    @NSManaged public func removeFromSteps(_ values: NSSet)

}

// MARK: Generated accessors for ingredients
extension Recipe {

    @objc(addIngredientsObject:)
    @NSManaged public func addToIngredients(_ value: Ingredient)

    @objc(removeIngredientsObject:)
    @NSManaged public func removeFromIngredients(_ value: Ingredient)

    @objc(addIngredients:)
    @NSManaged public func addToIngredients(_ values: NSSet)

    @objc(removeIngredients:)
    @NSManaged public func removeFromIngredients(_ values: NSSet)

}

extension Recipe : Identifiable {

}
