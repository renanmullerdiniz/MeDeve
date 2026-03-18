# MeDeve — Project Instructions

## What is this app
MeDeve is a native iOS app (SwiftUI + CoreData) for tracking IOUs — money owed to the user by friends. The name is a Brazilian Portuguese pun: "Me Deve" = "(They) Owe Me".
UI strings are in Brazilian Portuguese (pt_BR). Currency is BRL (R$).

## Tech Stack
- **Language:** Swift 5.0
- **UI:** SwiftUI (declarative, no UIKit)
- **Persistence:** CoreData (local only, no backend or cloud sync)
- **Architecture:** MVVM
- **No external dependencies** — pure Apple frameworks only (no CocoaPods, no SPM packages)
- **Build tool:** Xcode 14.2+

## Project Structure
```
MeDeve/
├── App/
│   ├── MeDeveApp.swift          # App entry point (@main)
│   └── PersistenceController.swift  # CoreData stack setup
├── Components/
│   └── EmbarrassmentBadge.swift # Reusable color badge UI component
├── Helpers/
│   ├── HapticHelper.swift       # UINotificationFeedbackGenerator wrapper
│   └── WhatsAppHelper.swift     # WhatsApp deep link integration
├── Models/
│   └── IOU+CoreData.swift       # NSManagedObject subclass + computed helpers
├── ViewModels/
│   └── IOUViewModel.swift       # ObservableObject with @Published state
└── Views/
    ├── ContentView.swift        # Root view
    ├── DebtListView.swift       # Main list
    ├── DebtRowView.swift        # Single row component
    └── AddDebtView.swift        # Add debt form
```

## CoreData Schema
Single entity: **IOU**
- `id` — UUID (required)
- `personName` — String (required)
- `amount` — Double (required, default 0.0)
- `note` — String (optional)
- `createdAt` — Date (required)
- `isPaid` — Boolean (required, default false)

## Architecture Rules (MVVM)
- **Views** hold no business logic — only layout and user interaction
- **ViewModels** (`ObservableObject` + `@Published`) own state and CoreData operations
- **Models** are CoreData entities with computed helpers as extensions
- Views use `@ObservedObject` or `@EnvironmentObject` to bind to ViewModels
- No direct CoreData access from Views

## Code Style
- **PascalCase** for types, structs, classes, enums, and file names
- **camelCase** for properties and methods
- Use `// MARK: -` to organize code sections within files
- Prefer computed properties and extensions on models over utility functions
- Use `do { try ... } catch { print(error) }` pattern for CoreData saves
- Always trigger haptic feedback on meaningful user actions

## Key Features & Patterns
- **Embarrassment system:** color-coded urgency based on days since debt was created
  - Green: < 7 days, Yellow: 7–29 days, Red: 30+ days
  - Defined as an enum/computed value on the IOU model
- **WhatsApp reminders:** deep link via `whatsapp://send?phone=...&text=...`
- **Locale formatting:** use `pt_BR` locale for currency (R$) and dates
- **Haptics:** success feedback on add/pay, warning on delete

## Building & Running
- Open `MeDeve/MeDeve/MeDeve.xcodeproj` in Xcode
- Run with **Cmd+R** (simulator or device)
- Build from CLI: `xcodebuild -scheme MeDeve -configuration Debug`
- Clean: `xcodebuild -scheme MeDeve clean`

## No Tests Yet
There are currently no test targets. When adding tests:
- Create unit tests for ViewModel logic
- Use in-memory CoreData store for tests (`NSInMemoryStoreType`)
- Do not mock CoreData — use a real in-memory stack

## Adding New Features
- **New view:** create in `Views/`, use `@ObservedObject` to bind to existing ViewModel
- **New model field:** add attribute in `MeDeve.xcdatamodeld`, update `IOU+CoreData.swift`, bump CoreData model version if app is already shipped
- **New helper/utility:** add to `Helpers/` only if reused across multiple files
- **New reusable UI piece:** add to `Components/`
