import Foundation

public struct ParsedFood: Equatable {
    public let carbs: Double?

    public struct FoodComponent: Equatable {
        let name: String
        let carbs: String?
        let weightInGrams: Double?
    }

    public struct FoodCarbs: Equatable {
        let carbs: Double?
        let percentage: Double?
    }

    public static func foodComponents(forRecipe recipe: String) -> [String] {
        // split the recipe by commas, but preserve commas within parenthesis
        // e.g. "a, b" returns ["a", " b"]
        // but "a (b, c), d" returns ["a (b, c)", " d"]

        // swiftlint:disable:next force_try
        let regexp = try! NSRegularExpression(pattern: ",(?!([0-9]|[^(]*\\)))", options: [])
        let components = regexp.stringByReplacingMatches(in: recipe, options: [], range: NSRange(location: 0, length: recipe.count), withTemplate: "\n").components(separatedBy: "\n")
        // let components = recipe.components(separatedBy: ",(?![^(]*\\))", options: .regularExpression)
        return components.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    public static func parse(foodComponent: String) -> FoodComponent {
        // extract the part within the parenthesis, if any
        // e.g. "a (b, c)" returns "b, c"
        // but "a" returns nil
        // swiftlint:disable:next force_try
        let regexpParenthesis = try! NSRegularExpression(pattern: "\\(([^)]+)\\)?", options: [])
        let matches = regexpParenthesis.matches(in: foodComponent, options: [], range: NSRange(location: 0, length: foodComponent.count))
        let carbs: String?
        if matches.count > 0 {
            let range = matches[0].range(at: 1)
            carbs = String(foodComponent[Range(range, in: foodComponent)!])
        } else {
            carbs = nil
        }

        // name is foodComponent without the parenthesis
        let name = regexpParenthesis.stringByReplacingMatches(in: foodComponent, options: [], range: NSRange(location: 0, length: foodComponent.count), withTemplate: "").trimmingCharacters(in: .whitespacesAndNewlines)

        // do we match carbs in name?
        // swiftlint:disable:next force_try
        let regexpCarbsInGrams = try! NSRegularExpression(pattern: "(\\d+(?:[.,]\\d+)?)[gG]", options: [])
        let matchesCarbsInGrams = regexpCarbsInGrams.matches(in: name, options: [], range: NSRange(location: 0, length: name.count))
        let weightInGrams: Double?
        if matchesCarbsInGrams.count > 0 {
            let range = matchesCarbsInGrams[0].range(at: 1)
            weightInGrams = Double(String(name[Range(range, in: name)!]).replacingOccurrences(of: ",", with: "."))
        } else {
            weightInGrams = nil
        }

        return FoodComponent(name: name, carbs: carbs, weightInGrams: weightInGrams)
    }

    public static func parseCarbs(carbs: String) -> FoodCarbs {
        // split the carbs by commas not followed by a number
        // swiftlint:disable:next force_try
        let regexpSeparator = try! NSRegularExpression(pattern: ",(?![0-9])", options: [])
        let components = regexpSeparator.stringByReplacingMatches(in: carbs, options: [], range: NSRange(location: 0, length: carbs.count), withTemplate: "\n").components(separatedBy: "\n")

        // do we have any component that is a weight?
        // swiftlint:disable:next force_try
        let regexpWeight = try! NSRegularExpression(pattern: "(\\d+(?:[.,]\\d+)?)[gG]", options: [])
        let weights: [Double] = components.map { component in
            let matchesWeight = regexpWeight.matches(in: component, options: [], range: NSRange(location: 0, length: component.count))
            if matchesWeight.count > 0 {
                let range = matchesWeight[0].range(at: 1)
                return Double(String(component[Range(range, in: component)!]).replacingOccurrences(of: ",", with: "."))
            } else {
                return nil
            }
        }.filter { $0 != nil }.map { $0! }
        let weight: Double? = weights.isEmpty ? nil : weights.reduce(0, +)

        // do we have any component that is a percentage?
        // swiftlint:disable:next force_try
        let regexpPercentage = try! NSRegularExpression(pattern: "(\\d+(?:[,.]\\d+)?)%", options: [])
        let percentages: [Double] = components.map { component in
            let matchesPercentage = regexpPercentage.matches(in: component, options: [], range: NSRange(location: 0, length: component.count))
            if matchesPercentage.count > 0 {
                let range = matchesPercentage[0].range(at: 1)
                return Double(String(component[Range(range, in: component)!]).replacingOccurrences(of: ",", with: "."))
            } else {
                return nil
            }
        }.filter { $0 != nil }.map { $0! }

        if percentages.count > 0 {
            let percentage = percentages.max()!
            return FoodCarbs(carbs: weight, percentage: percentage / 100.0)
        }
        if weights.count > 0 {
            return FoodCarbs(carbs: weight, percentage: nil)
        }

        return FoodCarbs(carbs: nil, percentage: nil)
    }

    static func calculateCarbs(carbs: String, weightInGrams: Double?) -> Double? {
        let foodCarbs = ParsedFood.parseCarbs(carbs: carbs)
        if let percentage = foodCarbs.percentage, let weightInGrams {
            return weightInGrams * percentage
        } else if let carbs = foodCarbs.carbs {
            return carbs
        } else {
            return nil
        }
    }

    public static func parse(recipe: String) -> ParsedFood {
        let foodComponents = ParsedFood.foodComponents(forRecipe: recipe)
        var carbs: Double?

        for foodComponent in foodComponents {
            let parsedFoodComponent = ParsedFood.parse(foodComponent: foodComponent)
            if let foodCarbs = parsedFoodComponent.carbs {
                let thisCarbs = ParsedFood.calculateCarbs(carbs: foodCarbs, weightInGrams: parsedFoodComponent.weightInGrams)
                if let thisCarbs {
                    carbs = carbs == nil ? thisCarbs : carbs! + thisCarbs
                }
            }
        }

        return ParsedFood(carbs: carbs)
    }
}
