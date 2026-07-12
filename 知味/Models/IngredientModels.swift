import Foundation
import SwiftUI

// MARK: - Ingredient Category (可伸缩)

struct IngredientCategory: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var icon: String            // SF Symbol
    var color: String           // hex
    var parentId: UUID?         // 支持子分类，nil = 顶层
    var isBuiltIn: Bool = true  // 内置 vs 用户自建
    var children: [IngredientCategory] = []
    var description: String?

    /// 扁平化所有子分类 ID（用于过滤）
    func allChildIds() -> [UUID] {
        [id] + children.flatMap { $0.allChildIds() }
    }
}

// MARK: - Ingredient

struct Ingredient: Identifiable, Codable {
    var id = UUID()
    var name: String
    var aliases: [String] = []           // 别名（土豆=马铃薯=洋芋）
    var categoryId: UUID
    var imageName: String?               // SF Symbol 或本地图片名
    var seasonMonths: [Int] = []         // 应季月份 1-12
    var storageDays: Int?                // 常温储存天数
    var storageTips: String?             // 储存建议
    var nutritionHighlights: [String] = [] // 营养亮点
    var cookingTips: [String] = []       // 烹饪贴士
    var substitutions: [Substitution] = [] // 替代品
    var isCommon: Bool = true            // 常见食材 or 冷门
    var difficulty: Int = 1              // 处理难度 1-5
    var unitPrice: Double?               // 参考单价
    var unit: String = "斤"              // 计价单位

    /// 当前是否应季
    var isInSeasonNow: Bool {
        let m = Calendar.current.component(.month, from: Date())
        return seasonMonths.isEmpty || seasonMonths.contains(m)
    }
}

// MARK: - Substitution

struct Substitution: Codable, Identifiable {
    var id = UUID()
    var ingredientName: String     // 替代食材名
    var ratio: String?             // 替换比例
    var note: String?              // 使用说明（味道差异等）
}

// MARK: - Shopping Item

struct ShoppingItem: Identifiable, Codable {
    var id = UUID()
    var ingredientName: String
    var amount: String?           // "2 斤" / "500g"
    var isChecked: Bool = false
    var addedAt: Date = Date()
}

// MARK: - User Note

struct IngredientNote: Identifiable, Codable {
    var id = UUID()
    var ingredientId: UUID
    var content: String
    var createdAt: Date = Date()
}

// MARK: - Collection (用户收藏/自定义合集)

struct IngredientCollection: Identifiable, Codable {
    var id = UUID()
    var name: String
    var ingredientIds: [UUID] = []
    var icon: String = "folder.fill"
}

// MARK: - Knowledge Entry (结构化百科)

struct KnowledgeEntry: Identifiable, Codable {
    var id = UUID()
    var ingredientId: UUID
    var section: KnowledgeSection
    var content: String
    var order: Int

    enum KnowledgeSection: String, Codable, CaseIterable {
        case overview       = "概述"
        case nutrition      = "营养"
        case selection      = "挑选技巧"
        case storage        = "储存方法"
        case preparation    = "处理技巧"
        case cooking        = "烹饪建议"
        case pairing        = "搭配推荐"
        case safety         = "食用禁忌"
        case trivia         = "趣味知识"
    }
}
