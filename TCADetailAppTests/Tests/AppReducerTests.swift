import ComposableArchitecture
import Foundation
import XCTest

@testable import TCADetailApp

final class AppReducerTests: XCTestCase {
  func testOnAppearAction_ShouldFetchAlbum() {
    let scheduler = DispatchQueue.test
    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: AppEnvironment(
        mainQueue: { scheduler.eraseToAnyScheduler() },
        albumProvider: { AlbumProviderMock() }
      )
    )
    
    let identifiedPhotos: IdentifiedArrayOf<Photo> = [
      Photo(id: 1, title: "Title 1", url: ""),
      Photo(id: 2, title: "Title 1", url: ""),
      Photo(id: 3, title: "Title 1", url: ""),
      Photo(id: 4, title: "Title 1", url: "")
    ]
    let photos = identifiedPhotos.map { $0 }

    store.send(.onAppear)
    scheduler.advance()
    
    store.receive(.albumResponse(.success(photos))) {
      $0.photos = identifiedPhotos
    }
  }
  
  func testOnSearchAction_ShouldFetchAlbum() {
    let scheduler = DispatchQueue.test
    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: AppEnvironment(
        mainQueue: { scheduler.eraseToAnyScheduler() },
        albumProvider: { AlbumProviderMock() }
      )
    )
    
    let identifiedPhotos: IdentifiedArrayOf<Photo> = [
      Photo(id: 1, title: "Title 1", url: ""),
      Photo(id: 2, title: "Title 1", url: ""),
      Photo(id: 3, title: "Title 1", url: ""),
      Photo(id: 4, title: "Title 1", url: "")
    ]
    let photos = identifiedPhotos.map { $0 }
    
    store.send(.onAppear)
    
    scheduler.advance()
    
    store.receive(.albumResponse(.success(photos))) {
      $0.photos = identifiedPhotos
    }
    
    var searchText = ""
    
    store.send(.onSearch(searchText)) {
      $0.searchText = searchText
      $0.isSearching = false
      $0.filteredPhotos = []
    }
    
    searchText = "Title"
    
    store.send(.onSearch(searchText)) {
      $0.searchText = searchText
      $0.isSearching = true
      $0.filteredPhotos = identifiedPhotos
    }
  }
}
