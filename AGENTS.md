# AGENTS.md

**Project:** `opencode/` (Flutter desktop application)  
**Target platforms:** macOS 🖥️ & Windows 🪟  

---

## 1️⃣ Purpose of the Agents

| Agent | Role |
|------|------|
| **Build** (primary) | Executes all file operations, runs shell commands, and orchestrates the full CI‑style build pipeline for macOS and Windows. |
| **Summarizer** (sub‑agent) | Generates concise markdown summaries (design notes, change‑log entries, implementation overviews) and stores them in a dedicated folder. |
| **Planner** (optional sub‑agent) | Provides high‑level architecture discussions, task breakdowns, and code reviews **without** making modifications. |

> **Rule:** Only the **Build** agent may modify source files. All other agents must request permission (`ask`) before any edit or command execution.

---

## 2️⃣ Agent Workflow

1. **Planner** – Analyses a feature request / bug report and creates a **plan** (`plan.md`).  
2. **Build** – Follows the plan, creates/modifies Dart/Flutter files, updates `pubspec.yaml`, runs `flutter pub get`.  
3. **Summarizer** – After each logical commit, writes a markdown summary in `summaries/`.  
4. **Build** – Runs platform‑specific build commands (`flutter build macos`, `flutter build windows`).  
5. **Planner** (optional) – Verifies artefacts, suggests next steps, and creates a `review.md`.

All agents communicate through the same repository; the **Summarizer** never changes production code – it only writes into the `summaries/` directory.

---

## 3️⃣ Coding Principles for Flutter / Dart  

| ✅ Principle | 📖 Description | 📂 Example |
|-------------|----------------|-----------|
| **Modularity** | Small, reusable `Widget`s; business logic lives in services / Riverpod providers. | `lib/widgets/login_button.dart` |
| **Only needed packages** | Add a dependency after the Planner confirms it’s required. | `http`, `shared_preferences` |
| **Minimal platform‑specific code** | Wrap `dart:io` / `dart:ffi` behind an abstract interface (`PlatformService`) and guard with `kIsWeb`, `Platform.isMacOS`, `Platform.isWindows`. | `lib/services/platform_service.dart` |
| **Test‑first mindset** | Unit tests for every public API; widget tests for UI. Agents run `flutter test` automatically. | `test/services/auth_service_test.dart` |
| **Lint & formatting** | Enforce `dart format .` and `flutter analyze`. CI must pass without warnings. | (auto‑fixed) |
| **Full null‑safety** | No unsafe `!` unless explicitly approved. | `String? name;` |
| **Performance awareness** | Prefer `const` constructors, avoid heavy rebuilds, use `ListView.builder` for long lists. | `const Text('Hello')` |
| **Folder structure** | ```<br>lib/<br> ├─ models/   ← data classes (Freezed recommended)<br> ├─ services/ ← business logic / API<br> ├─ ui/       ← screens & widgets<br> ├─ utils/    ← helpers, extensions<br>``` | — |
| **Documentation** | Every public class, method, and widget must have a Dartdoc comment. Agents add a stub when generating new files. | `/// Returns a list of …` |

---

## 4️⃣ Build Instructions (agents must follow)

### 4.1 Common prerequisites
```bash
# Ensure the Flutter SDK is on PATH and up‑to‑date
flutter channel stable
flutter upgrade
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop
```

### 4.2 macOS
```bash
# Clean previous artefacts
flutter clean

# Resolve dependencies
flutter pub get

# Build the macOS bundle
flutter build macos --release

# Verify the .app bundle
open build/macos/Build/Products/Release/<your_app>.app
```

### 4.3 Windows
```powershell
# Clean
flutter clean

# Get packages
flutter pub get

# Build the Windows executable
flutter build windows --release

# Run the .exe to confirm
Start-Process .\build\windows\runner\Release\<your_app>.exe
```

### 4.4 CI / Automation (agents)
* Use the same sequence in a GitHub Action / Azure Pipeline.
* After each successful build, **Summarizer** creates a markdown entry in `summaries/` containing:
    - Build date & time (ISO‑8601)
    - Platform
    - Git SHA
    - List of changed modules
    - Any build warnings or performance notes

---

## 5️⃣ Summarization Folder

```
summaries/
├─ 2024-08-01_macOS_build.md
├─ 2024-08-01_windows_build.md
└─ feature‑XYZ_design.md
```

* **File naming** – `YYYY-MM-DD_<platform>_<type>.md`
* **Content template** – Title, short Context paragraph, bullet list of changes, and a reference to the associated issue/PR.
* **Retention** – Keep the latest 30 files; older files can be archived automatically by a maintenance sub‑agent.

---

## 6️⃣ Permissions Matrix

| Action | Build | Planner | Summarizer |
|--------|-------|----------|------------|
| Edit source files | ✅ | ❓ (ask) | ❌ |
| Run `flutter` CLI | ✅ | ❓ (ask) | ❌ |
| Write to `summaries/` | ✅ (via Summarizer) | ✅ (ask) | ✅ |
| Commit & push | ✅ | ❓ (ask) | ❌ |
| Create/modify Git tags | ✅ | ❓ (ask) | ❌ |
| Access OS commands (`bash`, `powershell`) | ✅ | ❓ (ask) | ❌ |

> The **Planner** can request permission; the **Build** agent must confirm before executing.

---

## 7️⃣ Prompt Templates (quick reference)

### 7.1 Ask Planner for a feature plan
```
@planner
Please create a development plan for "Export project settings to JSON". Include:
- UI changes (screens/widgets)
- New data models
- Any new dependencies
- Approx. number of files to modify
```

### 7.2 Instruct Build to implement a task
```
@build
Implement the UI described in step 2 of the plan. Follow the coding principles above.
```

### 7.3 Request a summary after a build
```
@summarizer
Generate a build summary for the latest macOS release and store it in `summaries/`.
```

---

## 8️⃣ Maintenance Tips for Human Contributors

* Review the **summaries** folder regularly – it is the single source of truth for change history.
* Keep `pubspec.yaml` tidy; run `flutter pub outdated` before adding new packages.
* Run `flutter analyze && flutter test` locally before handing work to the **Build** agent.
* When adding platform‑specific code, also add a corresponding test stub that uses `Platform.isMacOS` / `Platform.isWindows` to verify conditional compilation.

---

## Сборка
1. Перед сборкой уточнаяй для какой ОС собирать проект
2. После  сборки делай установочный файл .msi для windows и .dmg для macOS
3. Собранные пакеты клади в папку releases
4. В названии должна быть указана дата и время сборки