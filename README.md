# arcade

Mom Said It's My Turn to Feed the Algorithm

A small collection of browser games by Oriana Fawkes.

Currently featuring:

* **2048** — an independent Flutter implementation inspired by [2048 by Gabriele Cirulli](https://github.com/gabrielecirulli/2048)

## Development

### Requirements

* Flutter SDK
* A supported browser such as Chrome or Edge

Check the Flutter installation with:

```bash
flutter doctor
```

### Run locally

```bash
flutter pub get
flutter run -d chrome
```

### Analyze

```bash
flutter analyze
```

### Test

```bash
flutter test
```

### Build for the web

```bash
flutter build web
```

The production build is generated in:

```text
build/web/
```

## Deployment

The project is deployed as a Flutter Web application through GitHub Actions and GitHub Pages.

The production site is:

https://arcade.emptyspaces.dev/

The current game is available at:

https://arcade.emptyspaces.dev/2048

Pushing to the main branch triggers the deployment workflow.

## Project Structure

```text
lib/
├── app/
├── features/
│   ├── 2048/
│   └── arcade/
├── shared/
└── main.dart
```

The project uses a lightweight feature-first structure. Shared code should only be moved into `shared/` when it is genuinely reusable across multiple features.

## Storage

Game progress and player settings are stored locally in the browser using `shared_preferences`.

There is no backend, account system, or server-side game state.

## Adding Another Game

When adding another game, prefer keeping its models, game logic, persistence, and presentation inside its own feature directory:

```text
lib/features/<game>/
├── game/
├── models/
└── presentation/
```

Avoid introducing additional architectural layers until the project actually needs them.

## Notes

This project is intentionally lightweight. It is a collection of small games rather than a large application, so new abstractions should earn their place by solving an actual problem.

The 2048 implementation is independent and is not affiliated with the original 2048 project.
