import Foundation

public struct ParsedFood: Equatable {
    public let carbs: Double?

    public struct FoodComponent: Equatable {
        public let name: String
        public let carbs: String?
        public let weightInGrams: Double?

        public init(name: String, carbs: String?, weightInGrams: Double?) {
            self.name = name
            self.carbs = carbs
            self.weightInGrams = weightInGrams
        }
    }

    public struct FoodCarbs: Equatable {
        public let carbs: Double?
        public let percentage: Double?

        public init(carbs: Double?, percentage: Double?) {
            self.carbs = carbs
            self.percentage = percentage
        }
    }

    // Compiled once and shared: NSRegularExpression is immutable and
    // thread-safe, and profiling a client app showed NSRegularExpression.init
    // hot on the main thread because every parse call rebuilt its regexes
    // (parse(recipe:) alone compiled 1 + 2 per component + 3 per carbs run).

    // split the recipe by commas, but preserve commas within parenthesis
    // swiftlint:disable:next force_try
    private static let componentSeparatorRegex = try! NSRegularExpression(pattern: ",(?!([0-9]|[^(]*\\)))", options: [])
    // the part within the parenthesis, if any
    // swiftlint:disable:next force_try
    private static let parenthesisRegex = try! NSRegularExpression(pattern: "\\(([^)]+)\\)?", options: [])
    // a weight like "42g" or "42.5G"
    // swiftlint:disable:next force_try
    private static let weightRegex = try! NSRegularExpression(pattern: "(\\d+(?:[.,]\\d+)?)[gG]", options: [])
    // split the carbs by commas not followed by a number
    // swiftlint:disable:next force_try
    private static let carbsSeparatorRegex = try! NSRegularExpression(pattern: ",(?![0-9])", options: [])
    // a percentage like "50%" or "12,5%"
    // swiftlint:disable:next force_try
    private static let percentageRegex = try! NSRegularExpression(pattern: "(\\d+(?:[,.]\\d+)?)%", options: [])

    public static func foodComponents(forRecipe recipe: String) -> [String] {
        // split the recipe by commas, but preserve commas within parenthesis
        // e.g. "a, b" returns ["a", " b"]
        // but "a (b, c), d" returns ["a (b, c)", " d"]

        let components = componentSeparatorRegex.stringByReplacingMatches(in: recipe, options: [], range: NSRange(location: 0, length: recipe.count), withTemplate: "\n").components(separatedBy: "\n")
        // let components = recipe.components(separatedBy: ",(?![^(]*\\))", options: .regularExpression)
        return components.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    public static func parse(foodComponent: String) -> FoodComponent {
        // extract the part within the parenthesis, if any
        // e.g. "a (b, c)" returns "b, c"
        // but "a" returns nil
        let matches = parenthesisRegex.matches(in: foodComponent, options: [], range: NSRange(location: 0, length: foodComponent.count))
        let carbs: String?
        if matches.count > 0 {
            let range = matches[0].range(at: 1)
            carbs = String(foodComponent[Range(range, in: foodComponent)!])
        } else {
            carbs = nil
        }

        // name is foodComponent without the parenthesis
        let name = parenthesisRegex.stringByReplacingMatches(in: foodComponent, options: [], range: NSRange(location: 0, length: foodComponent.count), withTemplate: "").trimmingCharacters(in: .whitespacesAndNewlines)

        // do we match carbs in name?
        let matchesCarbsInGrams = weightRegex.matches(in: name, options: [], range: NSRange(location: 0, length: name.count))
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
        let components = carbsSeparatorRegex.stringByReplacingMatches(in: carbs, options: [], range: NSRange(location: 0, length: carbs.count), withTemplate: "\n").components(separatedBy: "\n")

        // do we have any component that is a weight?
        let weights: [Double] = components.map { component in
            let matchesWeight = weightRegex.matches(in: component, options: [], range: NSRange(location: 0, length: component.count))
            if matchesWeight.count > 0 {
                let range = matchesWeight[0].range(at: 1)
                return Double(String(component[Range(range, in: component)!]).replacingOccurrences(of: ",", with: "."))
            } else {
                return nil
            }
        }.filter { $0 != nil }.map { $0! }
        let weight: Double? = weights.isEmpty ? nil : weights.reduce(0, +)

        // do we have any component that is a percentage?
        let percentages: [Double] = components.map { component in
            let matchesPercentage = percentageRegex.matches(in: component, options: [], range: NSRange(location: 0, length: component.count))
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
