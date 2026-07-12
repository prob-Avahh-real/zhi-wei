import XCTest
@testable import ZhiWei

final class ZhiWeiTests: XCTestCase {

    func testIngredientCategory() {
        let category = IngredientCategory(name: "蔬菜", icon: "leaf.fill", color: "#00FF00")
        XCTAssertEqual(category.name, "蔬菜")
        XCTAssertEqual(category.icon, "leaf.fill")
        XCTAssertTrue(category.isBuiltIn)
    }

    func testIngredientCategoryHierarchy() {
        let child = IngredientCategory(name: "叶菜", icon: "leaf", color: "#00AA00", parentId: UUID())
        let parent = IngredientCategory(name: "蔬菜", icon: "leaf.fill", color: "#00FF00", children: [child])
        let ids = parent.allChildIds()
        XCTAssertEqual(ids.count, 2)
        XCTAssertEqual(ids[0], parent.id)
        XCTAssertEqual(ids[1], child.id)
    }

    func testIngredient() {
        let categoryId = UUID()
        let ingredient = Ingredient(
            name: "土豆",
            aliases: ["马铃薯", "洋芋"],
            categoryId: categoryId,
            seasonMonths: [1, 2, 3, 9, 10, 11, 12],
            storageDays: 90,
            nutritionHighlights: ["维生素C", "钾"],
            cookingTips: ["适合炖煮", "适合油炸"],
            difficulty: 1,
            unitPrice: 2.5,
            unit: "斤"
        )
        XCTAssertEqual(ingredient.name, "土豆")
        XCTAssertEqual(ingredient.aliases.count, 2)
        XCTAssertEqual(ingredient.difficulty, 1)
        XCTAssertEqual(ingredient.unitPrice, 2.5)
    }

    func testIngredientSeasons() {
        let ingredient = Ingredient(
            name: "西瓜",
            categoryId: UUID(),
            seasonMonths: [6, 7, 8]
        )
        // Should not crash regardless of current month
        XCTAssertFalse(ingredient.seasonMonths.isEmpty)
    }

    func testIngredientCategoryCodable() throws {
        let category = IngredientCategory(name: "水果", icon: "applelogo", color: "#FF0000")
        let data = try JSONEncoder().encode(category)
        let decoded = try JSONDecoder().decode(IngredientCategory.self, from: data)
        XCTAssertEqual(decoded.name, "水果")
        XCTAssertEqual(decoded.icon, "applelogo")
    }

    func testIngredientCodable() throws {
        let ingredient = Ingredient(name: "鸡蛋", categoryId: UUID())
        let data = try JSONEncoder().encode(ingredient)
        let decoded = try JSONDecoder().decode(Ingredient.self, from: data)
        XCTAssertEqual(decoded.name, "鸡蛋")
    }

    func testSubstitution() {
        let sub = Substitution(name: "白糖", usage: "替代冰糖", ratio: "1:1")
        XCTAssertEqual(sub.name, "白糖")
        XCTAssertEqual(sub.ratio, "1:1")
    }
}
