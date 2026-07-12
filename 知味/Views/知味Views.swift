import SwiftUI

// MARK: - Color Palette

extension Color {
    static let zsGreen   = Color(red: 0.20, green: 0.78, blue: 0.35)
    static let zsOrange  = Color(red: 1.00, green: 0.58, blue: 0.00)
    static let zsRed     = Color(red: 1.00, green: 0.23, blue: 0.19)
    static let zsBlue    = Color(red: 0.00, green: 0.48, blue: 1.00)
    static let zsPurple  = Color(red: 0.69, green: 0.32, blue: 0.87)
    static let zsBrown   = Color(red: 0.56, green: 0.43, blue: 0.24)
    static let zsBg      = Color(red: 0.96, green: 0.96, blue: 0.94)
    static let zsCard    = Color.white
    static let zsText    = Color(red: 0.13, green: 0.13, blue: 0.13)
    static let zsMuted   = Color(red: 0.55, green: 0.55, blue: 0.58)
}

// MARK: - App Entry

@main
struct 知味App: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

struct ContentView: View {
    @StateObject private var vm = KnowledgeViewModel()

    var body: some View {
        TabView {
            NavigationStack { HomeView(vm: vm) }
                .tabItem { Label("发现", systemImage: "leaf.fill") }

            NavigationStack { BrowseView(vm: vm) }
                .tabItem { Label("百科", systemImage: "books.vertical.fill") }

            NavigationStack { ShoppingListView(vm: vm) }
                .tabItem { Label("清单", systemImage: "cart.fill") }

            NavigationStack { ProfileView(vm: vm) }
                .tabItem { Label("我的", systemImage: "person.fill") }
        }
        .tint(.zsGreen)
    }
}

// MARK: - Home View

struct HomeView: View {
    @ObservedObject var vm: KnowledgeViewModel
    @State private var showIdentify = false

    var body: some View {
        ZStack {
            Color.zsBg.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    // Search + Identify
                    searchSection

                    // Seasonal banner
                    seasonalBanner

                    // Category cloud
                    categorySection

                    // Quick browse
                    quickBrowseSection

                    Spacer().frame(height: 60)
                }
                .padding(.horizontal, 16)
            }
        }
        .navigationTitle("知味")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showIdentify) {
            IdentifyView(vm: vm)
        }
    }

    private var searchSection: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("搜索食材、别名…", text: $vm.searchText)
            }
            .padding(12).background(.white).clipShape(RoundedRectangle(cornerRadius: 12))

            Button { showIdentify = true } label: {
                Image(systemName: "camera.viewfinder")
                    .font(.title3).foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.zsGreen).clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var seasonalBanner: some View {
        let items = vm.seasonalIngredients
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(vm.seasonLabel).font(.headline)
                Spacer()
                Text("\(items.count) 种当季").font(.caption).foregroundStyle(.secondary)
            }
            if items.isEmpty {
                Text("暂无应季数据").font(.caption).foregroundStyle(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(items.prefix(10)) { ingredient in
                            NavigationLink(destination: IngredientDetailView(vm: vm, ingredient: ingredient)) {
                                VStack(spacing: 6) {
                                    Image(systemName: ingredient.imageName ?? "circle.fill")
                                        .font(.title2).foregroundStyle(.zsGreen)
                                        .frame(width: 44, height: 44)
                                        .background(.zsGreen.opacity(0.1))
                                        .clipShape(Circle())
                                    Text(ingredient.name).font(.caption2).foregroundStyle(.primary)
                                }
                                .frame(width: 60)
                            }
                        }
                    }
                }
            }
        }
        .padding(16).background(.white).clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("食材分类").font(.headline)
            LazyVGrid(columns: [.init(.adaptive(minimum: 80), spacing: 10)], spacing: 10) {
                ForEach(vm.topLevelCategories) { cat in
                    Button {
                        vm.selectedCategoryId = cat.id
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: cat.icon).font(.title3)
                                .foregroundStyle(Color(hex: cat.color))
                            Text(cat.name).font(.caption2).foregroundStyle(.primary)
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                        .background(.white).clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
    }

    private var quickBrowseSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("时令精选").font(.headline)
            ForEach(vm.seasonalIngredients.prefix(5)) { ing in
                NavigationLink(destination: IngredientDetailView(vm: vm, ingredient: ing)) {
                    HStack(spacing: 12) {
                        Image(systemName: ing.imageName ?? "circle.fill")
                            .foregroundStyle(.zsGreen).frame(width: 24)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(ing.name).font(.subheadline).fontWeight(.medium).foregroundStyle(.primary)
                            Text("当季 · \(ing.nutritionHighlights.prefix(2).joined(separator: " · "))")
                                .font(.caption).foregroundStyle(.secondary).lineLimit(1)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(12).background(.white).clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}

// MARK: - Browse View

struct BrowseView: View {
    @ObservedObject var vm: KnowledgeViewModel

    var body: some View {
        ZStack {
            Color.zsBg.ignoresSafeArea()
            VStack(spacing: 0) {
                // Filter bar
                HStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip("全部", isActive: vm.selectedCategoryId == nil) {
                                vm.selectedCategoryId = nil
                            }
                            ForEach(vm.topLevelCategories) { cat in
                                FilterChip(cat.name, isActive: vm.selectedCategoryId == cat.id) {
                                    vm.selectedCategoryId = cat.id
                                }
                            }
                        }
                    }
                    Spacer()
                    Button {
                        vm.showInSeasonOnly.toggle()
                    } label: {
                        Image(systemName: vm.showInSeasonOnly ? "leaf.fill" : "leaf")
                            .foregroundStyle(vm.showInSeasonOnly ? .zsGreen : .secondary)
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 10)

                // List
                List {
                    ForEach(vm.filteredIngredients) { ingredient in
                        NavigationLink(destination: IngredientDetailView(vm: vm, ingredient: ingredient)) {
                            HStack(spacing: 12) {
                                Image(systemName: ingredient.imageName ?? "circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(
                                        (vm.flattenedCategories.first { $0.id == ingredient.categoryId })
                                            .map { Color(hex: $0.color) } ?? .zsGreen
                                    )
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 4) {
                                        Text(ingredient.name).font(.subheadline).fontWeight(.medium)
                                        if ingredient.isInSeasonNow {
                                            Text("当季").font(.caption2).foregroundStyle(.zsGreen).padding(.horizontal, 4).padding(.vertical, 1)
                                                .background(.zsGreen.opacity(0.1)).clipShape(Capsule())
                                        }
                                    }
                                    if let p = ingredient.unitPrice {
                                        Text("参考 ¥\(String(format: "%.1f", p))/\(ingredient.unit)").font(.caption).foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .swipeActions(edge: .trailing) {
                            Button {
                                vm.addToShoppingList(ingredient.name, amount: nil)
                            } label: {
                                Label("加购", systemImage: "cart.badge.plus")
                            }
                            .tint(.zsGreen)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("食材百科")
        .searchable(text: $vm.searchText, prompt: "搜索食材、别名…")
    }
}

struct FilterChip: View {
    let text: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text).font(.caption)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(isActive ? Color.zsGreen : Color.white)
                .foregroundStyle(isActive ? .white : .primary)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(isActive ? 0.1 : 0.02), radius: 4, y: 1)
        }
    }
}

// MARK: - Ingredient Detail View

struct IngredientDetailView: View {
    @ObservedObject var vm: KnowledgeViewModel
    let ingredient: Ingredient
    @State private var newNote = ""
    @State private var showNoteField = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                headerSection

                // Quick info
                quickInfoBar

                // Nutrition
                if !ingredient.nutritionHighlights.isEmpty { nutritionSection }

                // Storage
                if ingredient.storageTips != nil { storageSection }

                // Cooking tips
                if !ingredient.cookingTips.isEmpty { cookingSection }

                // Substitutions
                if !ingredient.substitutions.isEmpty { substitutionSection }

                // Knowledge entries
                let ents = vm.entriesForIngredient(ingredient.id)
                if !ents.isEmpty { knowledgeSection(ents) }

                // Notes
                notesSection

                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 16)
        }
        .background(Color.zsBg)
        .navigationTitle(ingredient.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    vm.addToShoppingList(ingredient.name, amount: nil)
                } label: {
                    Image(systemName: "cart.badge.plus").foregroundStyle(.zsGreen)
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: ingredient.imageName ?? "circle.fill")
                .font(.system(size: 56)).foregroundStyle(.zsGreen)
                .frame(width: 100, height: 100)
                .background(.zsGreen.opacity(0.1)).clipShape(Circle())

            Text(ingredient.name).font(.largeTitle).fontWeight(.bold)
            if !ingredient.aliases.isEmpty {
                Text("又名：\(ingredient.aliases.joined(separator: "、"))")
                    .font(.subheadline).foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                Label(ingredient.isInSeasonNow ? "当季" : "四季", systemImage: ingredient.isInSeasonNow ? "leaf.fill" : "calendar")
                    .font(.caption).foregroundStyle(ingredient.isInSeasonNow ? .zsGreen : .secondary)
                Label("\(ingredient.storageDays ?? 0)天", systemImage: "clock")
                    .font(.caption).foregroundStyle(.secondary)
                if let price = ingredient.unitPrice {
                    Label("¥\(String(format: "%.1f", price))", systemImage: "yensign.circle")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .padding(.top, 20)
    }

    private var quickInfoBar: some View {
        HStack(spacing: 0) {
            quickStat("难度", "\(ingredient.difficulty)/5")
            Divider().frame(height: 30)
            quickStat("储存", "\(ingredient.storageDays ?? 0)天")
            Divider().frame(height: 30)
            quickStat("单位", ingredient.unit)
        }
        .padding(12).background(.white).clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func quickStat(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.subheadline).fontWeight(.bold)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var nutritionSection: some View {
        sectionCard("营养亮点", icon: "bolt.heart.fill", color: .zsOrange) {
            WrapView(items: ingredient.nutritionHighlights) { item in
                Text(item).font(.caption).foregroundStyle(.zsOrange)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(.zsOrange.opacity(0.1)).clipShape(Capsule())
            }
        }
    }

    private var storageSection: some View {
        sectionCard("储存方法", icon: "archivebox.fill", color: .zsBrown) {
            Text(ingredient.storageTips ?? "").font(.subheadline).foregroundStyle(.primary)
        }
    }

    private var cookingSection: some View {
        sectionCard("烹饪贴士", icon: "flame.fill", color: .zsRed) {
            ForEach(ingredient.cookingTips, id: \.self) { tip in
                HStack(alignment: .top, spacing: 8) {
                    Text("•").foregroundStyle(.zsRed)
                    Text(tip).font(.subheadline)
                }
            }
        }
    }

    private var substitutionSection: some View {
        sectionCard("替代方案", icon: "arrow.trianglehead.swap", color: .zsPurple) {
            ForEach(ingredient.substitutions) { sub in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(sub.ingredientName).font(.subheadline).fontWeight(.medium)
                        if let ratio = sub.ratio { Text("替换比例: \(ratio)").font(.caption).foregroundStyle(.secondary) }
                        if let note = sub.note { Text(note).font(.caption).foregroundStyle(.secondary) }
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func knowledgeSection(_ ents: [KnowledgeEntry]) -> some View {
        let sections = KnowledgeEntry.KnowledgeSection.allCases.filter { s in ents.contains { $0.section == s } }
        return ForEach(sections, id: \.self) { section in
            let items = ents.filter { $0.section == section }
            sectionCard(section.rawValue, icon: "book.pages.fill", color: .zsBlue) {
                ForEach(items) { entry in
                    Text(entry.content).font(.subheadline).foregroundStyle(.primary)
                }
            }
        }
    }

    private var notesSection: some View {
        let notes = vm.notesForIngredient(ingredient.id)
        return sectionCard("我的笔记", icon: "note.text", color: .zsMuted) {
            if showNoteField {
                HStack {
                    TextField("添加笔记…", text: $newNote)
                    Button("保存") {
                        guard !newNote.isEmpty else { return }
                        vm.addNote(ingredient.id, content: newNote)
                        newNote = ""
                        showNoteField = false
                    }
                    .font(.caption).fontWeight(.medium)
                }
            } else {
                Button("+ 添加笔记") { showNoteField = true }.font(.caption).foregroundStyle(.zsGreen)
            }
            ForEach(notes) { note in
                VStack(alignment: .leading, spacing: 2) {
                    Text(note.content).font(.subheadline)
                    Text(note.createdAt.formatted(date: .abbreviated, time: .shortened)).font(.caption2).foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
    }

    @ViewBuilder
    private func sectionCard<Content: View>(_ title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon).foregroundStyle(color)
                Text(title).font(.headline)
            }
            content()
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(.white).clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Wrap View

struct WrapView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let content: (Data.Element) -> Content

    @State private var totalHeight: CGFloat = .zero

    var body: some View {
        GeometryReader { geo in
            self.generateContent(in: geo)
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var height: CGFloat = 0

        return ZStack(alignment: .topLeading) {
            ForEach(Array(items), id: \.self) { item in
                content(item)
                    .alignmentGuide(.leading) { d in
                        if abs(width - d.width) > g.size.width { width = 0; height -= d.height }
                        let result = width
                        if item == Array(items).last { width = 0 } else { width -= d.width }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if item == Array(items).last { height = 0 }
                        return result
                    }
            }
        }
        .background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { geo -> Color in
            DispatchQueue.main.async { binding.wrappedValue = geo.size.height }
            return Color.clear
        }
    }
}

// MARK: - Shopping List View

struct ShoppingListView: View {
    @ObservedObject var vm: KnowledgeViewModel

    var body: some View {
        List {
            if vm.shoppingList.isEmpty {
                ContentUnavailableView("清单空空", systemImage: "cart", description: Text("在食材详情页点击购物车图标添加"))
            }

            if !vm.uncheckedShoppingItems.isEmpty {
                Section("待购买 (\(vm.uncheckedShoppingItems.count))") {
                    ForEach(vm.uncheckedShoppingItems) { item in
                        shoppingRow(item)
                    }
                }
            }

            if !vm.checkedShoppingItems.isEmpty {
                Section("已购买 (\(vm.checkedShoppingItems.count))") {
                    ForEach(vm.checkedShoppingItems) { item in
                        shoppingRow(item)
                    }
                }
            }
        }
        .navigationTitle("采购清单")
        .toolbar {
            if !vm.shoppingList.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("清空已完成") {
                        vm.checkedShoppingItems.forEach { vm.removeShoppingItem($0.id) }
                    }
                }
            }
        }
    }

    private func shoppingRow(_ item: ShoppingItem) -> some View {
        HStack(spacing: 12) {
            Button { vm.toggleShoppingItem(item.id) } label: {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.title3).foregroundStyle(item.isChecked ? .zsGreen : .secondary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(item.ingredientName)
                    .font(.subheadline)
                    .strikethrough(item.isChecked)
                    .foregroundStyle(item.isChecked ? .secondary : .primary)
                if let amount = item.amount {
                    Text(amount).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .swipeActions(edge: .trailing) { Button("删除") { vm.removeShoppingItem(item.id) }.tint(.red) }
    }
}

// MARK: - Identify View

struct IdentifyView: View {
    @ObservedObject var vm: KnowledgeViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var inputText = ""
    @State private var results: [Ingredient] = []
    @State private var hasSearched = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("📸 食材识别").font(.title2).fontWeight(.bold).padding(.top, 20)
                Text("输入食材名称或描述，我来帮你识别\n（相机识别功能将在后续版本上线）")
                    .font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)

                HStack {
                    TextField("例如：圆圆的、红色的、做菜用的…", text: $inputText)
                        .font(.body)
                    Button {
                        hasSearched = true
                        results = vm.filteredIngredients.filter {
                            $0.name.localizedCaseInsensitiveContains(inputText) ||
                            $0.aliases.contains { $0.localizedCaseInsensitiveContains(inputText) } ||
                            $0.cookingTips.contains { $0.localizedCaseInsensitiveContains(inputText) }
                        }
                    } label: {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .font(.title2).foregroundStyle(.zsGreen)
                    }
                    .disabled(inputText.isEmpty)
                }
                .padding(12).background(.white).clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)

                if hasSearched {
                    List(results) { ing in
                        NavigationLink(destination: IngredientDetailView(vm: vm, ingredient: ing)) {
                            Label(ing.name, systemImage: "leaf.fill").foregroundStyle(.zsGreen)
                        }
                    }
                    .listStyle(.plain)
                }

                Spacer()
            }
            .background(Color.zsBg)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("关闭") { dismiss() } } }
        }
    }
}

// MARK: - Profile View

struct ProfileView: View {
    @ObservedObject var vm: KnowledgeViewModel
    @State private var showAddIngredient = false
    @State private var showAddCollection = false
    @State private var collectionName = ""

    var body: some View {
        List {
            Section("我的收藏夹") {
                if vm.collections.isEmpty {
                    Text("还没有收藏夹，长按食材可收藏").font(.caption).foregroundStyle(.secondary)
                }
                ForEach(vm.collections) { col in
                    NavigationLink(destination: CollectionDetailView(vm: vm, collection: col)) {
                        Label("\(col.name) (\(col.ingredientIds.count))", systemImage: col.icon)
                    }
                }
                HStack {
                    Image(systemName: "plus.circle.fill").foregroundStyle(.zsGreen)
                    TextField("新建收藏夹", text: $collectionName)
                        .onSubmit {
                            guard !collectionName.isEmpty else { return }
                            vm.collections.append(IngredientCollection(name: collectionName))
                            collectionName = ""
                        }
                }
            }

            Section("自定义食材 (\(vm.customIngredients.count))") {
                Button { showAddIngredient = true } label: {
                    Label("添加自定义食材", systemImage: "plus.circle.fill").foregroundStyle(.zsGreen)
                }
                ForEach(vm.customIngredients) { ing in
                    NavigationLink(destination: IngredientDetailView(vm: vm, ingredient: ing)) {
                        Text(ing.name)
                    }
                }
            }

            Section("数据统计") {
                LabeledContent("内置食材", value: "\(vm.ingredients.count) 种")
                LabeledContent("自定义食材", value: "\(vm.customIngredients.count) 种")
                LabeledContent("采购清单", value: "\(vm.uncheckedShoppingItems.count) 项待买")
                LabeledContent("笔记", value: "\(vm.notes.count) 条")
            }
        }
        .navigationTitle("我的")
        .sheet(isPresented: $showAddIngredient) { AddIngredientView(vm: vm) }
    }
}

// MARK: - Collection Detail

struct CollectionDetailView: View {
    @ObservedObject var vm: KnowledgeViewModel
    let collection: IngredientCollection

    var body: some View {
        List(vm.ingredientsInCollection(collection)) { ing in
            NavigationLink(destination: IngredientDetailView(vm: vm, ingredient: ing)) {
                Text(ing.name)
            }
        }
        .navigationTitle(collection.name)
    }
}

// MARK: - Add Ingredient

struct AddIngredientView: View {
    @ObservedObject var vm: KnowledgeViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var alias = ""
    @State private var catId: UUID?
    @State private var tips = ""
    @State private var storage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("名称", text: $name)
                    TextField("别名（逗号分隔）", text: $alias)
                    Picker("分类", selection: $catId) {
                        Text("请选择").tag(nil as UUID?)
                        ForEach(vm.flattenedCategories) { c in Text(c.name).tag(c.id as UUID?) }
                    }
                }
                Section("可选信息") {
                    TextField("烹饪贴士（逗号分隔）", text: $tips)
                    TextField("储存建议", text: $storage)
                }
            }
            .navigationTitle("添加食材")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        guard !name.isEmpty, let cid = catId else { return }
                        let ing = Ingredient(
                            name: name,
                            aliases: alias.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) },
                            categoryId: cid,
                            cookingTips: tips.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) },
                            storageTips: storage.isEmpty ? nil : storage,
                            isCommon: false
                        )
                        vm.addCustomIngredient(ing)
                        dismiss()
                    }.disabled(name.isEmpty || catId == nil)
                }
            }
            .onAppear { catId = vm.topLevelCategories.first?.id }
        }
    }
}

// MARK: - Helpers

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}
