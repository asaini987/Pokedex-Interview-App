# Pokédex

## Overview
This app is a simple Pokédex built in SwiftUI.  
It fetches Pokémon data from the [PokeAPI](https://pokeapi.co), displays a paginated grid of Pokémon, and allows the user to tap a Pokémon to view its details and sprite.

The app demonstrates:
- SwiftUI UI architecture
- MVVM design pattern
- Async/await networking
- Image caching with `URLCache` + `NSCache`
- Pagination and error handling

---

## Features
- Paginated list of Pokémon with infinite scrolling
- Image loading with caching  
  - Uses `URLCache` for disk/network response caching  
  - Uses `NSCache` for in-memory decoded `UIImage` caching  
- ProgressView placeholders while loading
- Fallbacks (question mark icon if sprite is missing)
- Error handling  
  - Silent ignore of cancelled network requests (common during fast scrolling)  
  - Inline error display for list fetch failures
- Adaptive grid layout (no hard-coded cell sizes; scales per device)
- Built entirely with SwiftUI + async/await

---

## Architecture

The app follows MVVM (Model-View-ViewModel):

- **Models** (`PokemonDetail`, `PokemonAPIResource`, etc.)  
  Codable structs mapping directly to PokeAPI JSON.

- **ViewModel** (`PokemonGridViewModel`)  
  Holds app state: Pokémon list, detail cache, selected Pokémon.  
  Handles API calls, pagination, and updates `@Observable` state.  
  Runs on `@MainActor` so UI updates are thread-safe.

- **Views**  
  - `PokemonGridView` → Main screen with paginated grid  
  - `PokemonCell` → Each grid cell (sprite + name)  
  - `SelectedPokemonView` → Shows tapped Pokémon in detail  
  - `CachedAsyncImage` → Custom image loader with caching

---

## Technical Decisions

### Networking
- Implemented in `PokeAPIClient` using `URLSession` with `async/await`.
- Errors wrapped in a `PokeAPIError` enum (network, decoding, bad response, etc.).

### Pagination
- Grid triggers `fetchMorePokemons()` when reaching the last cell.
- Concurrency guarded with `isLoadingMore` flag.

### Image Caching
This app implements a hybrid caching strategy:

- **`URLCache`**: Persists raw HTTP responses (image data) to both disk and memory, managed by the system. This ensures sprites remain available across app launches and respects server cache headers for freshness.
- **`NSCache`**: Stores already-decoded `UIImage` objects in memory. This avoids the cost of repeatedly decoding PNG data while scrolling, resulting in smoother UI performance.

By combining these two:
- **Freshness** is preserved — if the API updates a sprite, the app will fetch new data once the cache expires.
- **Performance** is optimized — recently displayed images are instantly available from memory without re-decoding or re-fetching.

In a real-world production app, teams often opt for a third-party library like **Kingfisher** or **SDWebImage** to handle caching, downsampling, retries, and other edge cases.  
For this project, I implemented a custom caching layer to demonstrate my understanding of iOS caching mechanisms.

### Error Handling
- Grid fetch errors update a shared `lastError` displayed as small text above the grid.
- Cell detail fetch errors are logged but not shown (since cells already handle missing sprites gracefully).
- Image load errors show a question mark icon.

### UI Design Choices
- `LazyVGrid` for efficient scrolling
- Adaptive grid sizing for different screen sizes

---

## Running the App
1. Clone the repo
2. Open `Pokedex.xcodeproj` in Xcode 15+
3. Run on iOS 17+ simulator or device