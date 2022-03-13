import ComposableArchitecture
import Foundation

struct AppState: Equatable {
  var photos: IdentifiedArrayOf<Photo> = []
  var filteredPhotos: IdentifiedArrayOf<Photo> = []
  var searchText = ""
  var isSearching = false
}

enum AppAction {
  case onAppear
  case albumResponse(Result<[Photo], Never>)
  case onSearch(String)
}

struct AppEnvironment {
  let mainQueue: AnySchedulerOf<DispatchQueue>
  let albumProvider: AlbumProvider
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
  switch action {
  case .onAppear:
    struct AlbumId: Hashable {}
    return environment
      .albumProvider.fetchAlbums()
      .receive(on: environment.mainQueue)
      .catchToEffect(AppAction.albumResponse)
      .cancellable(id: AlbumId(), cancelInFlight: true)
  case .albumResponse(.success(let photos)):
    var indentifiedPhotos = IdentifiedArrayOf<Photo>()
    photos.forEach { indentifiedPhotos.append($0) }
    state.photos = indentifiedPhotos
    return .none
  case .onSearch(let searchText):
    state.searchText = searchText
    state.isSearching = !searchText.isEmpty
    state.filteredPhotos = state.isSearching ? state.photos.filter { $0.title.lowercased().contains(searchText.lowercased()) } : []
    return .none
  }
}
