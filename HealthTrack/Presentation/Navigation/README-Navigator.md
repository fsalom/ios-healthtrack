# 🧭 Navigator System

## 📖 Overview

The Navigator is a centralized navigation system for SwiftUI applications that provides a clean and consistent way to handle all navigation patterns in your iOS app. It follows the Coordinator pattern principles adapted for SwiftUI.

### 🎯 Purpose

- **Centralized Navigation**: Single source of truth for all navigation states
- **Decoupled Logic**: Separates navigation logic from views and ViewModels
- **Multiple Navigation Types**: Supports push, modal, sheet, alerts, toasts, and more
- **Type-Safe**: Uses strongly typed navigation with Page wrapper
- **Module Independence**: Each module can navigate without knowing about others

## 🏗️ Architecture

### File Structure

```
Navigator/
├── Domain/                          # Domain Layer (Business Logic)
│   ├── Protocols/
│   │   └── NavigatorProtocol.swift # Navigation contracts
│   └── Entities/
│       └── AlertModel.swift        # Alert data model (pure data, no UI)
│
└── Presentation/                    # Presentation Layer (UI)
    ├── Navigation/
    │   ├── Navigator.swift         # Main navigator implementation (Singleton)
    │   └── Router.swift            # Base router class
    │
    ├── Root/
    │   └── NavigatorRootView.swift # Root view for navigation system
    │
    ├── Components/
    │   ├── Page.swift              # Type-safe page wrapper
    │   ├── NestedSheetHost.swift   # Sheet navigation handler
    │   ├── NestedFullScreenHost.swift  # Full screen modal handler
    │   ├── ToastView.swift         # Toast component
    │   └── CustomTabBar.swift      # Tab bar implementation
    │
    └── Configuration/
        ├── AlertStyles.swift       # Alert UI styles and buttons logic
        ├── ToastConfig.swift       # Toast configuration model
        ├── ConfirmationDialogConfig.swift  # Dialog configuration
        └── FullOverScreenConfig.swift      # Full screen configuration
```

### Architecture Explanation

This Navigator follows **Clean Architecture** principles, with clear separation between Domain and Presentation layers:

**Domain Layer:**
- Contains business logic and contracts (protocols)
- **No dependencies on UI frameworks** (SwiftUI)
- `NavigatorProtocol` defines navigation contracts
- `AlertModel` is pure data without UI logic (only `import Foundation`)

**Presentation Layer:**
- Contains all UI-related code
- Depends on SwiftUI framework
- `Navigator` implements NavigatorProtocol with SwiftUI-specific logic
- `Router` provides base navigation functionality
- `AlertStyles` contains the UI rendering logic for alerts (buttons, layouts)
- All Configuration files use SwiftUI's `@ViewBuilder`

#### AlertModel vs AlertStyles Separation

```swift
// Domain/Entities/AlertModel.swift (Pure Data)
struct AlertModel {
    let title: String
    let message: String
    let style: AlertStyle  // Enum without UI logic
}

// Presentation/Configuration/AlertStyles.swift (UI Logic)
enum AlertStyle {
    case info(action: () -> Void)
    case error(acceptAction: () -> Void, cancelAction: () -> Void)
    case permissions
    case custom(buttons: any View)

    var buttons: some View {  // SwiftUI components here
        // Button creation and layout logic
    }
}
```

**Why this separation?**
- ✅ Domain remains testable without SwiftUI
- ✅ Alert data can be created without UI dependencies
- ✅ UI rendering logic is isolated in Presentation layer
- ✅ Follows Dependency Inversion Principle

## 🚀 Features

- **Push Navigation** - Navigate to new screens in the navigation stack
- **Modal Sheets** - Present views as sheets
- **Full Screen Cover** - Present full screen modals
- **Alerts** - Show system alerts with predefined styles
- **Toast Messages** - Show temporary notifications with optional actions
- **Tab Bar Navigation** - Manage tab-based navigation with badges
- **Root Replacement** - Replace the entire navigation stack

## 💻 Implementation

### 1. Setup NavigatorRootView

In your main app file or module entry point:

```swift
@main
struct YourApp: App {
    var body: some Scene {
        WindowGroup {
            NavigatorRootView(root: YourInitialView())
        }
    }
}
```

**Note:** Some modules like Authentication provide their own specialized root views (e.g., `AuthNavigatorRootView`) with additional functionality specific to that module.

### 2. Create Module Router

All routers must inherit from the base `Router` class. The router is injected into ViewModels, not views:

```swift
// Router class for your module
class ProductCatalogRouter: Router {

    func navigateToProductDetail(productID: Int) {
        navigator.push(to: ProductDetailBuilder.build(productID: productID))
    }

    func navigateToCheckout() {
        navigator.push(to: CheckoutBuilder.build())
    }

    func presentCart() {
        navigator.presentSheet(CartBuilder.build())
    }

    func showProductAddedToast() {
        showToastWithCloseAction(
            with: "Product added to cart",
            closeAction: { }
        )
    }
}
```

### 3. Inject Router into ViewModel

The router is injected into the ViewModel, keeping views clean:

```swift
class ProductListViewModel: ObservableObject {
    // MARK: - Properties
    private let router: ProductCatalogRouter
    private let useCase: ProductCatalogUseCaseProtocol
    @Published var products: [Product] = []
    @Published var isLoading = false

    // MARK: - Init
    init(router: ProductCatalogRouter,
         useCase: ProductCatalogUseCaseProtocol) {
        self.router = router
        self.useCase = useCase
    }

    // MARK: - Navigation Methods
    func didSelectProduct(_ product: Product) {
        router.navigateToProductDetail(productID: product.id)
    }

    func didTapCheckout() {
        router.navigateToCheckout()
    }

    func didAddProductToCart() {
        router.showProductAddedToast()
    }
}
```

### 4. Use Builder Pattern

Builders are classes that create views with all dependencies properly injected:

```swift
class ProductListBuilder {
    static func build() -> some View {
        let router = ProductCatalogRouter()
        let useCase = ProductCatalogUseCase()
        let viewModel = ProductListViewModel(
            router: router,
            useCase: useCase
        )
        return ProductListView(viewModel: viewModel)
    }
}
```

### 5. View Implementation

Views remain clean, only calling ViewModel methods:

```swift
struct ProductListView: View {
    @StateObject private var viewModel: ProductListViewModel

    init(viewModel: ProductListViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List(viewModel.products) { product in
            ProductRow(product: product)
                .onTapGesture {
                    viewModel.didSelectProduct(product)
                }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Checkout") {
                    viewModel.didTapCheckout()
                }
            }
        }
    }
}
```

## 🔧 Base Router Methods

The `Router` base class provides these common methods:

### Alerts
```swift
// Basic alert with info style
showAlert(title: "Title", message: "Message", action: { })

// Alert with error (requires DetailErrorProtocol)
showAlert(with: error, action: { })
```

### Toasts
```swift
// Toast with close button
showToastWithCloseAction(
    with: "Message",
    closeAction: { }
)
```

### Navigation
```swift
// Dismiss current modal/sheet
dismiss()

// Dismiss sheet specifically
dismissSheet()

// Dismiss full screen cover
dismissFullOverScreen()
```

## 📱 Tab Bar Navigation

### Setup Custom Tab Bar
```swift
// In your router
func showMainTabBar() {
    navigator.replaceRoot(to: CustomTabbar(initialTab: .home))
}
```

### Change Tab Programmatically
```swift
// Navigate to specific tab
navigator.changeTab(index: TabItem.profile.rawValue)
```

### Update Tab Badges
```swift
// Set badge count
navigator.tabBadges[.notifications] = 5

// Clear badge
navigator.tabBadges[.notifications] = nil
```

## 📋 Best Practices

1. **Always Inherit from Router** - Don't access Navigator directly
2. **Inject Router into ViewModel** - Keep navigation logic in ViewModels, not Views
3. **Use Builder Pattern** - Centralize dependency injection in Builders
4. **Keep Views Simple** - Views should only call ViewModel methods
5. **Module Independence** - Routers should not import other modules
6. **Type Safety** - Navigator automatically wraps views in Page for type safety

## ⚠️ Important Notes

- `Navigator` is a singleton (`Navigator.shared`)
- `Router` base class provides common navigation functionality
- Router is injected into ViewModel, not View
- NavigatorRootView must be initialized at app launch
- Each screen typically has its own Router, ViewModel, and Builder

## 🔗 Navigator Protocol Methods

### NavigatorProtocol (Composition of NavigationFlow & OverlayPresentation)

The NavigatorProtocol provides these methods that can be called from your router through `navigator` property:

#### Navigation Methods (NavigationFlow)

| Method | Description |
|--------|-------------|
| `push(to:)` | Push view onto navigation stack |
| `pushAndRemovePrevious(to:)` | Push new view and remove previous one |
| `present(view:)` | Present view as modal sheet |
| `dismiss()` | Go back one screen (pop navigation) |
| `dismissSheet()` | Dismiss current sheet/modal |
| `dismissFullOverScreen()` | Dismiss full screen cover |
| `dismissAll()` | Pop to root view (clear navigation stack) |
| `replaceRoot(to:)` | Replace entire navigation stack with new root |
| `presentCustomConfirmationDialog(from:)` | Show confirmation dialog with custom actions |
| `changeTab(index:)` | Switch to specific tab by index |

#### Overlay Presentation Methods (OverlayPresentation)

| Method | Description |
|--------|-------------|
| `showAlert(alertModel:)` | Show alert with AlertModel |
| `showToast(from:)` | Show toast with ToastConfig |
| `presentFullOverScreen(view:)` | Present full screen modal |
| `dismissToast()` | Dismiss current toast |

### Properties Available

| Property | Type | Description |
|----------|------|-------------|
| `path` | `[Page]` | Current navigation stack |
| `root` | `Page?` | Root view of navigation |
| `sheet` | `Page?` | Current sheet being presented |
| `tabIndex` | `Int` | Currently selected tab index |
| `tabBadges` | `[TabItem: Int]` | Badge counts for tabs |
| `toastConfig` | `ToastConfig?` | Current toast configuration |
| `alertModel` | `AlertModel` | Current alert model |
| `isPresentingAlert` | `Bool` | Whether alert is showing |

---

## 🏛️ Clean Architecture Principles Applied

### 1. **Dependency Inversion Principle**
- Domain layer (`NavigatorProtocol`, `AlertModel`) has no dependencies on SwiftUI
- Presentation layer (`Navigator`, `Router`) depends on Domain abstractions
- UI logic (`AlertStyles.buttons`) is isolated in Presentation layer

### 2. **Single Responsibility Principle**
- `AlertModel` → Data structure (title, message, style type)
- `AlertStyles` → UI rendering logic (buttons, layouts)
- `Navigator` → Navigation state management
- `Router` → Navigation actions and conveniences

### 3. **Open/Closed Principle**
- Base `Router` class can be extended with module-specific navigation
- `NavigatorProtocol` can be implemented differently for different platforms
- Alert styles can be extended without modifying core logic

### 4. **Separation of Concerns**

```
┌─────────────────────────────────────────┐
│ Presentation Layer                       │
│  ├── Navigator (State + SwiftUI)        │
│  ├── Router (Convenience Methods)       │
│  └── AlertStyles (UI Rendering)         │
└──────────────┬──────────────────────────┘
               │ depends on
               ▼
┌─────────────────────────────────────────┐
│ Domain Layer                             │
│  ├── NavigatorProtocol (Contracts)      │
│  └── AlertModel (Pure Data)             │
└─────────────────────────────────────────┘
```

**Benefits:**
- ✅ Testable: Domain can be tested without SwiftUI
- ✅ Flexible: UI can change without affecting Domain
- ✅ Maintainable: Clear boundaries and responsibilities
- ✅ Reusable: Domain logic can be shared across platforms

---

## 📍 Location

The Navigator module is located at:
```
Gula/App/Navigator/
```

**Note:** There may be legacy Navigator files in `Gula/Shared/Navigator/` which should be considered deprecated. Always use the version in `Gula/App/Navigator/` which follows Clean Architecture principles.

---

## 📚 Related Documentation

- **NavigatorProtocol**: See `Domain/Protocols/NavigatorProtocol.swift` for typealias composition
- **NavigationFlow**: See `Domain/Protocols/NavigationFlow.swift` for navigation flow protocol
- **OverlayPresentation**: See `Domain/Protocols/OverlayPresentation.swift` for overlay presentation protocol
- **AlertModel**: See `Domain/Entities/AlertModel.swift` for data structure
- **AlertStyles**: See `Presentation/Configuration/AlertStyles.swift` for UI rendering
- **Router Base Class**: See `Presentation/Navigation/Router.swift` for common navigation methods

---

## 🧪 Testing

### Testing Navigation Logic

With the separated protocols, you can create focused mocks:

```swift
// Mock only NavigationFlow if you only need navigation
class NavigationFlowMock: NavigationFlow {
    var pushedViews: [Page] = []
    var presentedSheets: [Page] = []

    var path: [Page] = []
    var root: Page?
    // ... implement other NavigationFlow properties and methods

    func push(to view: any View) {
        pushedViews.append(Page(from: view))
    }

    func present(view: any View) {
        presentedSheets.append(Page(from: view))
    }
    // ... implement other methods
}

// Mock only OverlayPresentation if you only need overlays
class OverlayPresentationMock: OverlayPresentation {
    var shownAlerts: [AlertModel] = []
    var shownToasts: [ToastConfig] = []

    var toastConfig: ToastConfig?
    var alertModel: AlertModel = AlertModel()
    // ... implement other OverlayPresentation properties and methods

    func showAlert(alertModel: AlertModel) {
        shownAlerts.append(alertModel)
    }

    func showToast(from toast: ToastConfig) {
        shownToasts.append(toast)
    }
    // ... implement other methods
}

// Mock complete Navigator when needed
class NavigatorMock: NavigatorProtocol {
    // Combine both mocks or implement all methods
    var pushedViews: [Page] = []
    var presentedSheets: [Page] = []
    var shownAlerts: [AlertModel] = []

    // ... implement all NavigatorProtocol methods
}

// In your ViewModel test
func testNavigationToDetail() {
    let mockNavigator = NavigatorMock()
    let router = ProductRouter(navigator: mockNavigator)
    let viewModel = ProductListViewModel(router: router, useCase: mockUseCase)

    viewModel.didSelectProduct(mockProduct)

    XCTAssertEqual(mockNavigator.pushedViews.count, 1)
}
```

### Testing Alert Logic

```swift
func testShowErrorAlert() {
    let mockNavigator = NavigatorMock()
    let router = ProductRouter(navigator: mockNavigator)

    let error = AppError.customError("Error", nil)
    router.showAlert(with: error)

    XCTAssertEqual(mockNavigator.shownAlerts.count, 1)
    XCTAssertEqual(mockNavigator.shownAlerts.first?.title, "Error")
}
```

---

**Last Updated:** December 2025
**Version:** 2.0 (Clean Architecture)