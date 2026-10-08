import SwiftUI
import Combine

@MainActor
final class KnowledgeViewModel: ObservableObject {
    @Published var categories: [IngredientCategory] = BuiltInKnowledge.categories
    @Published var ingredients: [Ingredient] = BuiltInKnowledge.ingredients
    @Published var entries: [KnowledgeEntry] = BuiltInKnowledge.entries
    @Published var shoppingList: [ShoppingItem] = []
    @Published var customIngredients: [Ingredient] = []     // 用户自建
    @Published var notes: [IngredientNote] = []
    @Published var collections: [IngredientCollection] = []
    @Published var searchText = ""
    @Published var selectedCategoryId: UUID?
    @Published var showInSeasonOnly = false
    @Published var selectedIngredient: Ingredient?

    private let storage = StorageService.shared
    private let classifier = IngredientClassifier()

    init() { loadUserData() }

    // MARK: - Filtering

    var filteredIngredients: [Ingredient] {
        let all = ingredients + customIngredients
        var result = all

        if let catId = selectedCategoryId {
            let cat = flattenedCategories.first { $0.id == catId }
            let ids = cat?.allChildIds() ?? [catId]
            result = result.filter { ids.contains($0.categoryId) }
        }

        if showInSeasonOnly {
            result = result.filter { $0.isInSeasonNow }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.aliases.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }

        return result.sorted { a, b in
            if a.isInSeasonNow != b.isInSeasonNow { return a.isInSeasonNow }
            return a.name < b.name
        }
    }

    var flattenedCategories: [IngredientCategory] {
        func flatten(_ cats: [IngredientCategory]) -> [IngredientCategory] {
            cats + cats.flatMap { flatten($0.children) }
        }
        return flatten(categories)
    }

    var topLevelCategories: [IngredientCategory] { categories }

    var currentSeasonMonth: Int {
        Calendar.current.component(.month, from: Date())
    }

    var seasonalIngredients: [Ingredient] {
        ingredients.filter { $0.seasonMonths.contains(currentSeasonMonth) }
    }

    var seasonLabel: String {
        let m = currentSeasonMonth
        switch m {
        case 3...5:  return "🌸 春季时令"
        case 6...8:  return "☀️ 夏季时令"
        case 9...11: return "🍂 秋季时令"
        default:     return "❄️ 冬季时令"
        }
    }

    // MARK: - Ingredient Detail

    func entriesForIngredient(_ id: UUID) -> [KnowledgeEntry] {
        entries.filter { $0.ingredientId == id }.sorted { $0.order < $1.order }
    }

    func notesForIngredient(_ id: UUID) -> [IngredientNote] {
        notes.filter { $0.ingredientId == id }.sorted { $0.createdAt > $1.createdAt }
    }

    func addNote(_ ingredientId: UUID, content: String) {
        let note = IngredientNote(ingredientId: ingredientId, content: content)
        notes.insert(note, at: 0)
        saveUserData()
    }

    // MARK: - Custom Ingredient

    func addCustomIngredient(_ ingredient: Ingredient) {
        customIngredients.append(ingredient)
        saveUserData()
    }

    // MARK: - Shopping List

    func addToShoppingList(_ name: String, amount: String?) {
        // Don't duplicate
        guard !shoppingList.contains(where: { $0.ingredientName == name && !$0.isChecked }) else { return }
        shoppingList.append(ShoppingItem(ingredientName: name, amount: amount))
        saveUserData()
    }

    func toggleShoppingItem(_ id: UUID) {
        guard let idx = shoppingList.firstIndex(where: { $0.id == id }) else { return }
        shoppingList[idx].isChecked.toggle()
        saveUserData()
    }

    func removeShoppingItem(_ id: UUID) {
        shoppingList.removeAll { $0.id == id }
        saveUserData()
    }

    var uncheckedShoppingItems: [ShoppingItem] { shoppingList.filter { !$0.isChecked } }
    var checkedShoppingItems: [ShoppingItem] { shoppingList.filter { $0.isChecked } }

    // MARK: - Collections

    func toggleInCollection(ingredientId: UUID, collectionId: UUID) {
        guard let idx = collections.firstIndex(where: { $0.id == collectionId }) else { return }
        if collections[idx].ingredientIds.contains(ingredientId) {
            collections[idx].ingredientIds.removeAll { $0 == ingredientId }
        } else {
            collections[idx].ingredientIds.append(ingredientId)
        }
        saveUserData()
    }

    func ingredientsInCollection(_ collection: IngredientCollection) -> [Ingredient] {
        let all = ingredients + customIngredients
        return all.filter { collection.ingredientIds.contains($0.id) }
    }

    func isInCollection(ingredientId: UUID, collectionId: UUID) -> Bool {
        collections.first { $0.id == collectionId }?.ingredientIds.contains(ingredientId) ?? false
    }

    // MARK: - Persistence

    private func loadUserData() {
        shoppingList = storage.loadShoppingList()
        customIngredients = storage.loadCustomIngredients()
        notes = storage.loadNotes()
        collections = storage.loadCollections()
    }

    private func saveUserData() {
        storage.saveShoppingList(shoppingList)
        storage.saveCustomIngredients(customIngredients)
        storage.saveNotes(notes)
        storage.saveCollections(collections)
    }
}

/// 简易食材识别器 — 通过名称匹配模拟图像识别
final class IngredientClassifier {
    func classify(text: String, against ingredients: [Ingredient]) -> [Ingredient] {
        let lower = text.lowercased()
        return ingredients.filter { ing in
            ([ing.name] + ing.aliases).contains(where: { lower.contains($0.lowercased()) })
        }
    }
}
