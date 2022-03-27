import SwiftUI

@main
struct TCADetailAppApp: App {
  var body: some Scene {
    WindowGroup {
      PhotoListView(
        store: .init(
          initialState: .init(),
          reducer: appReducer,
          environment: .live
        )
      )
    }
  }
}
