# Reglas de Arquitectura - HealthTrack iOS

Este documento define las reglas arquitectónicas que DEBEN respetarse al trabajar en este proyecto. Este proyecto sigue **Clean Architecture** con el patrón **MVVM + Router/Coordinator**.

---

## Estructura de Capas

```
HealthTrack/
├── Domain/           # Lógica de negocio pura (SIN dependencias de UI)
├── Data/             # Fuentes de datos, DTOs, implementación de repositorios
├── Presentation/     # UI (SwiftUI), ViewModels, Navigation
└── Resources/        # Assets, Localizables
```

---

## Reglas de Dependencias entre Capas

### REGLA FUNDAMENTAL: Las dependencias fluyen hacia adentro

```
Presentation → Domain ← Data
```

| Capa | Puede importar | NO puede importar |
|------|----------------|-------------------|
| **Domain** | Foundation | SwiftUI, UIKit, Data |
| **Data** | Foundation, Domain | SwiftUI, UIKit, Presentation |
| **Presentation** | SwiftUI, Domain | Data (excepto a través de inyección) |

### Violaciones PROHIBIDAS

```swift
// PROHIBIDO en Domain:
import SwiftUI  // ❌ NUNCA

// PROHIBIDO en Data:
import SwiftUI  // ❌ NUNCA

// PROHIBIDO: Dependencia directa de Presentation a Data
let repo = ConcreteRepository()  // ❌ Usar protocol + inyección
```

---

## Estructura de Archivos por Capa

### Domain Layer

```
Domain/
├── Entities/           # Modelos de dominio puros
│   ├── [Feature]/      # Agrupados por feature
│   │   └── [Name]Model.swift
│   └── Errors/
│       └── AppError.swift
├── Repositories/       # SOLO protocolos de repositorio
│   └── [Name]RepositoryProtocol.swift
└── UseCases/          # Casos de uso
    └── [Feature]/
        └── [Action]UseCase.swift
```

### Data Layer

```
Data/
├── DataSources/
│   ├── [Feature]/
│   │   ├── DTOs/
│   │   │   └── [Name]DTO.swift
│   │   └── Handlers/
│   │       └── [Name]Handler.swift
└── Repositories/       # Implementación de protocolos
    └── [Name]Repository.swift
```

### Presentation Layer

```
Presentation/
├── App/
│   └── HealthTrackApp.swift
├── Navigation/         # Sistema de navegación (NO MODIFICAR sin autorización)
│   ├── Navigator.swift
│   ├── Router.swift
│   └── ...
└── Screens/
    └── [FeatureName]/
        ├── [Feature]View.swift
        ├── [Feature]ViewModel.swift
        ├── [Feature]Router.swift      # Opcional, si necesita navegación custom
        └── [Feature]Builder.swift     # Factory para inyección
```

---

## Sistema de Navegación

### Componentes Principales

| Componente | Responsabilidad |
|------------|-----------------|
| `Navigator` | Singleton que gestiona toda la navegación |
| `Router` | Clase base para routers de módulo (inyectada en ViewModels) |
| `Page` | Wrapper type-safe para vistas en NavigationStack |

### Reglas de Navegación

1. **ViewModels NUNCA acceden a Navigator directamente**
   ```swift
   // ❌ PROHIBIDO
   class MyViewModel {
       func navigate() {
           Navigator.shared.push(to: Page(from: SomeView()))
       }
   }

   // ✅ CORRECTO
   class MyViewModel {
       let router: Router

       func navigate() {
           router.navigateToSomeScreen()
       }
   }
   ```

2. **Views NO tienen lógica de navegación**
   ```swift
   // ❌ PROHIBIDO
   struct MyView: View {
       var body: some View {
           Button("Go") {
               Navigator.shared.push(to: Page(from: NextView()))
           }
       }
   }

   // ✅ CORRECTO
   struct MyView: View {
       @State var viewModel: MyViewModel

       var body: some View {
           Button("Go") {
               viewModel.didTapGoButton()
           }
       }
   }
   ```

3. **Usar Page() para envolver vistas en navegación**
   ```swift
   navigator.push(to: Page(from: MyView()))
   navigator.present(Page(from: MySheetView()))
   ```

### Tipos de Navegación Disponibles

```swift
// Stack Navigation
push(to: Page)              // Push a la pila
dismiss()                    // Pop
dismissAll()                 // Pop to root

// Modal Navigation
present(Page)               // Sheet
presentFullOverScreen(Page) // Full screen cover
dismissSheet()
dismissFullOverScreen()

// Tab Navigation
changeTab(index: Int)

// Overlays
showAlert(alertModel: AlertModel)
showToast(from: View)
```

---

## Patrones Obligatorios

### 1. MVVM para cada Screen

```swift
// [Feature]View.swift
struct ProfileView: View {
    @State var viewModel: ProfileViewModel

    var body: some View {
        // Solo UI, sin lógica de negocio
    }
}

// [Feature]ViewModel.swift
@Observable
class ProfileViewModel {
    let router: Router
    private let getUserUseCase: GetUserUseCaseProtocol

    var user: UserModel?
    var isLoading = false

    init(router: Router, getUserUseCase: GetUserUseCaseProtocol) {
        self.router = router
        self.getUserUseCase = getUserUseCase
    }

    func loadUser() async {
        isLoading = true
        user = await getUserUseCase.execute()
        isLoading = false
    }
}
```

### 2. Repository Pattern

```swift
// Domain/Repositories/UserRepositoryProtocol.swift
protocol UserRepositoryProtocol {
    func getUser(id: String) async throws -> UserModel
    func saveUser(_ user: UserModel) async throws
}

// Data/Repositories/UserRepository.swift
class UserRepository: UserRepositoryProtocol {
    func getUser(id: String) async throws -> UserModel {
        // Implementación con API/DB
    }
}
```

### 3. Use Cases

```swift
// Domain/UseCases/User/GetUserUseCase.swift
protocol GetUserUseCaseProtocol {
    func execute(id: String) async throws -> UserModel
}

class GetUserUseCase: GetUserUseCaseProtocol {
    private let repository: UserRepositoryProtocol

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: String) async throws -> UserModel {
        return try await repository.getUser(id: id)
    }
}
```

### 4. Builder para Inyección

```swift
// Presentation/Screens/Profile/ProfileBuilder.swift
enum ProfileBuilder {
    static func build(router: Router = Router()) -> ProfileView {
        let repository = UserRepository()
        let useCase = GetUserUseCase(repository: repository)
        let viewModel = ProfileViewModel(router: router, getUserUseCase: useCase)
        return ProfileView(viewModel: viewModel)
    }
}
```

---

## Manejo de Errores

### Jerarquía de Errores

```
Error (Swift)
  └── AppError (Domain)
        ├── .generalError
        ├── .noInternet
        ├── .badCredentials(String)
        ├── .customError(String, Int?)
        └── .inputError(String, String)
```

### Flujo de Errores

1. **Data Layer**: Captura error de API/DB
2. **ErrorHandlerManager**: Transforma a `AppError`
3. **ViewModel**: Recibe `AppError`, decide acción
4. **Router**: Muestra alert con `showAlert(with: error)`

```swift
// En ViewModel
func loadData() async {
    do {
        data = try await useCase.execute()
    } catch let error as AppError {
        router.showAlert(with: error)
    } catch {
        router.showAlert(with: AppError.generalError)
    }
}
```

---

## Convenciones de Nombres

| Elemento | Convención | Ejemplo |
|----------|-----------|---------|
| Archivos | PascalCase | `ProfileViewModel.swift` |
| Clases/Structs | PascalCase | `UserModel`, `ProfileView` |
| Protocolos | PascalCase + Protocol | `UserRepositoryProtocol` |
| Variables | camelCase | `isLoading`, `userName` |
| Constantes | camelCase | `let maxRetries = 3` |
| Enums | PascalCase | `enum LoadingState` |
| Enum cases | camelCase | `.loading`, `.error(String)` |

### Sufijos Obligatorios

| Tipo | Sufijo | Ejemplo |
|------|--------|---------|
| Vista SwiftUI | View | `ProfileView` |
| ViewModel | ViewModel | `ProfileViewModel` |
| Protocolo | Protocol | `UserRepositoryProtocol` |
| DTO | DTO | `UserDTO` |
| Modelo Domain | Model | `UserModel` |
| Use Case | UseCase | `GetUserUseCase` |
| Router de módulo | Router | `ProfileRouter` |
| Builder | Builder | `ProfileBuilder` |

---

## Reglas de Código

### Imports

```swift
// Orden de imports
import Foundation      // 1. System frameworks
import SwiftUI        // 2. UI frameworks (solo en Presentation)
import TripleA        // 3. Third-party
// 4. Módulos internos (si aplica)
```

### MARK Comments

```swift
// MARK: - Properties
// MARK: - Init
// MARK: - Public Methods
// MARK: - Private Methods
// MARK: - View Body (para Views)
```

### Access Control

- Usar `private` por defecto
- Usar `private(set)` para propiedades observables que solo se modifican internamente
- Solo exponer lo necesario

---

## Checklist para Nuevas Features

Antes de crear una nueva feature, verificar:

- [ ] Crear carpeta en `Presentation/Screens/[FeatureName]/`
- [ ] Crear `[Feature]View.swift` con @State viewModel
- [ ] Crear `[Feature]ViewModel.swift` con @Observable
- [ ] Crear `[Feature]Builder.swift` para inyección
- [ ] Si necesita datos: crear protocol en `Domain/Repositories/`
- [ ] Si necesita datos: crear implementación en `Data/Repositories/`
- [ ] Si tiene lógica de negocio: crear UseCase en `Domain/UseCases/`
- [ ] Si necesita modelo: crear en `Domain/Entities/[Feature]/`
- [ ] Navegación a través de Router, nunca Navigator directo

---

## Archivos Protegidos (NO MODIFICAR sin autorización)

Los siguientes archivos son core del sistema y no deben modificarse sin revisión:

- `Presentation/Navigation/Navigator.swift`
- `Presentation/Navigation/Router.swift`
- `Presentation/Navigation/Protocols/*`
- `Presentation/Navigation/Components/*`
- `Presentation/Navigation/Root/NavigatorRootView.swift`
- `Data/DataSources/Errors/Handlers/ErrorHandlerManager.swift`

---

## Ejemplo Completo: Crear Screen "Settings"

```
1. Domain/Entities/Settings/SettingsModel.swift
2. Domain/Repositories/SettingsRepositoryProtocol.swift
3. Domain/UseCases/Settings/GetSettingsUseCase.swift
4. Data/Repositories/SettingsRepository.swift
5. Presentation/Screens/Settings/SettingsView.swift
6. Presentation/Screens/Settings/SettingsViewModel.swift
7. Presentation/Screens/Settings/SettingsBuilder.swift
```

### Navegación a Settings:

```swift
// En otro ViewModel
func didTapSettings() {
    let settingsView = SettingsBuilder.build()
    router.navigator.push(to: Page(from: settingsView))
}
```
