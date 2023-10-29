@testable import OGUI
import XCTest

final class FoodParserTests: XCTestCase {
    func testComponents() throws {
        XCTAssertEqual(ParsedFood.foodComponents(forRecipe: "a, b"), ["a", "b"])
        XCTAssertEqual(ParsedFood.foodComponents(forRecipe: "a 10,2g, b"), ["a 10,2g", "b"])
        XCTAssertEqual(ParsedFood.foodComponents(forRecipe: "a,  b"), ["a", "b"])
        XCTAssertEqual(ParsedFood.foodComponents(forRecipe: " a,  b"), ["a", "b"])
        XCTAssertEqual(ParsedFood.foodComponents(forRecipe: "a (b, c), d"), ["a (b, c)", "d"])
    }

    func testParseFoodComponent() throws {
        XCTAssertEqual(ParsedFood.parse(foodComponent: "a (b, c)"), ParsedFood.FoodComponent(name: "a", carbs: "b, c", weightInGrams: nil))
        XCTAssertEqual(ParsedFood.parse(foodComponent: "a (b, c"), ParsedFood.FoodComponent(name: "a", carbs: "b, c", weightInGrams: nil))
        XCTAssertEqual(ParsedFood.parse(foodComponent: "a (b, c) d"), ParsedFood.FoodComponent(name: "a  d", carbs: "b, c", weightInGrams: nil))
        XCTAssertEqual(ParsedFood.parse(foodComponent: "a 42g (b)"), ParsedFood.FoodComponent(name: "a 42g", carbs: "b", weightInGrams: 42))
        XCTAssertEqual(ParsedFood.parse(foodComponent: "a 42G (b)"), ParsedFood.FoodComponent(name: "a 42G", carbs: "b", weightInGrams: 42))
        XCTAssertEqual(ParsedFood.parse(foodComponent: "a 42.5g (b)"), ParsedFood.FoodComponent(name: "a 42.5g", carbs: "b", weightInGrams: 42.5))
        XCTAssertEqual(ParsedFood.parse(foodComponent: "a 42,5g (b)"), ParsedFood.FoodComponent(name: "a 42,5g", carbs: "b", weightInGrams: 42.5))
    }

    func testParseCarbs() throws {
        XCTAssertEqual(ParsedFood.parseCarbs(carbs: "foo"), ParsedFood.FoodCarbs(carbs: nil, percentage: nil))
        XCTAssertEqual(ParsedFood.parseCarbs(carbs: "42G"), ParsedFood.FoodCarbs(carbs: 42, percentage: nil))
        XCTAssertEqual(ParsedFood.parseCarbs(carbs: "42g"), ParsedFood.FoodCarbs(carbs: 42, percentage: nil))
        XCTAssertEqual(ParsedFood.parseCarbs(carbs: "42.5g"), ParsedFood.FoodCarbs(carbs: 42.5, percentage: nil))
        XCTAssertEqual(ParsedFood.parseCarbs(carbs: "42,5g"), ParsedFood.FoodCarbs(carbs: 42.5, percentage: nil))
        XCTAssertEqual(ParsedFood.parseCarbs(carbs: "42%"), ParsedFood.FoodCarbs(carbs: nil, percentage: 0.42))
        XCTAssertEqual(ParsedFood.parseCarbs(carbs: "42.5%"), ParsedFood.FoodCarbs(carbs: nil, percentage: 0.425))
        XCTAssertEqual(ParsedFood.parseCarbs(carbs: "42,5%"), ParsedFood.FoodCarbs(carbs: nil, percentage: 0.425))

        XCTAssertEqual(ParsedFood.parseCarbs(carbs: "42g, 10g"), ParsedFood.FoodCarbs(carbs: 52, percentage: nil))
        XCTAssertEqual(ParsedFood.parseCarbs(carbs: "42%, 10%"), ParsedFood.FoodCarbs(carbs: nil, percentage: 0.42))
        XCTAssertEqual(ParsedFood.parseCarbs(carbs: "10%, 42%"), ParsedFood.FoodCarbs(carbs: nil, percentage: 0.42))
        XCTAssertEqual(ParsedFood.parseCarbs(carbs: "42g, 10%"), ParsedFood.FoodCarbs(carbs: 42, percentage: 0.10))
        XCTAssertEqual(ParsedFood.parseCarbs(carbs: "42%, 10g"), ParsedFood.FoodCarbs(carbs: 10, percentage: 0.42))
    }

    func testCalculateCarbs() throws {
        XCTAssertEqual(ParsedFood.calculateCarbs(carbs: "foo", weightInGrams: 100), nil)
        XCTAssertEqual(ParsedFood.calculateCarbs(carbs: "42%", weightInGrams: 100), 42)
        XCTAssertEqual(ParsedFood.calculateCarbs(carbs: "42%", weightInGrams: nil), nil)
        XCTAssertEqual(ParsedFood.calculateCarbs(carbs: "42g", weightInGrams: nil), 42)
        XCTAssertEqual(ParsedFood.calculateCarbs(carbs: "42g", weightInGrams: 50), 42)
        XCTAssertEqual(ParsedFood.calculateCarbs(carbs: "42g", weightInGrams: 60), 42)
    }

    func testParse() throws {
        XCTAssertEqual(ParsedFood.parse(recipe: "foo (42g)"), ParsedFood(carbs: 42))
        XCTAssertEqual(ParsedFood.parse(recipe: "foo (42g), bar (10g)"), ParsedFood(carbs: 52))
        XCTAssertEqual(ParsedFood.parse(recipe: "foo 50g (25%), bar (10g)"), ParsedFood(carbs: 22.5))
        XCTAssertEqual(ParsedFood.parse(recipe: "foo 50g (25%), bar 100g (10g)"), ParsedFood(carbs: 22.5))
        XCTAssertEqual(ParsedFood.parse(recipe: "foo 50g (25%), bar 200g (10g)"), ParsedFood(carbs: 22.5))
        XCTAssertEqual(ParsedFood.parse(recipe: "foo 50g (25%), bar 200g (10g), alice"), ParsedFood(carbs: 22.5))
        XCTAssertEqual(ParsedFood.parse(recipe: "foo 100g (50%)"), ParsedFood(carbs: 50))
        XCTAssertEqual(ParsedFood.parse(recipe: "foo 100g (50.5%)"), ParsedFood(carbs: 50.5))
        XCTAssertEqual(ParsedFood.parse(recipe: "foo 100.5g (50%)"), ParsedFood(carbs: 50.25))
        XCTAssertEqual(ParsedFood.parse(recipe: "foo 55.5g (99.1%)"), ParsedFood(carbs: 55.0005))
        XCTAssertEqual(ParsedFood.parse(recipe: "foo (10%, 22g)"), ParsedFood(carbs: 22))
        XCTAssertEqual(ParsedFood.parse(recipe: "foo 50g (10%, 22g)"), ParsedFood(carbs: 5))
    }
}
