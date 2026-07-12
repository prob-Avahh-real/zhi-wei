import Foundation

final class StorageService {
    static let shared = StorageService()
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func saveShoppingList(_ items: [ShoppingItem]) { encode(items, key: "shopping_list") }
    func loadShoppingList() -> [ShoppingItem] { decode(key: "shopping_list") ?? [] }

    func saveCustomIngredients(_ items: [Ingredient]) { encode(items, key: "custom_ingredients") }
    func loadCustomIngredients() -> [Ingredient] { decode(key: "custom_ingredients") ?? [] }

    func saveNotes(_ items: [IngredientNote]) { encode(items, key: "notes") }
    func loadNotes() -> [IngredientNote] { decode(key: "notes") ?? [] }

    func saveCollections(_ items: [IngredientCollection]) { encode(items, key: "collections") }
    func loadCollections() -> [IngredientCollection] { decode(key: "collections") ?? [] }

    private func encode<T: Encodable>(_ value: T, key: String) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: "zhiwei_\(key)")
    }

    private func decode<T: Decodable>(key: String) -> T? {
        guard let data = defaults.data(forKey: "zhiwei_\(key)") else { return nil }
        return try? decoder.decode(T.self, from: data)
    }
}
