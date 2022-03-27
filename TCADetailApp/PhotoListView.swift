import ComposableArchitecture
import SwiftUI

struct PhotoListView: View {
  let store: Store<AppState, AppAction>
  
  var body: some View {
    NavigationView {
      WithViewStore(store) { viewStore in
        List {
          ForEach(viewStore.isSearching ? viewStore.filteredPhotos : viewStore.photos) { photo in
            NavigationLink {
              PhotoView(photo: photo)
            } label: {
              PhotoRowView(photo: photo)
            }
          }
        }
        .searchable(text: viewStore.binding(
            get: { $0.searchText },
            send: { AppAction.onSearch($0) }
          )
        )
        .navigationTitle("Album")
        .onAppear { viewStore.send(.onAppear) }
      }
    }
  }
}

struct PhotoListView_Previews: PreviewProvider {
  static var previews: some View {
    PhotoListView(
      store: .init(
        initialState: .init(),
        reducer: appReducer,
        environment: AppEnvironment(
          mainQueue: { .main },
          albumProvider: { AlbumProviderMock() }
        )
      )
    )
  }
}
