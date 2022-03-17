import ComposableArchitecture
import Combine
import SwiftUI

protocol AlbumProvider {
  func fetchAlbums() -> Effect<[Photo], Never>
}

struct AlbumClient: AlbumProvider {
  private let service: Networking
  
  init(service: Networking = NetworkService()) {
    self.service = service
  }
  
  func fetchAlbums() -> Effect<[Photo], Never> {
    service
      .fetchContent(of: [Photo].self, url: url)
      .catchToEffect { result in
        switch result {
        case .success(let photos):
          return photos
        case .failure:
          return []
        }
      }
      .eraseToEffect()
  }
}

extension AlbumClient {
  var url: String { "https://jsonplaceholder.typicode.com/photos" }
}

struct AlbumProviderMock: AlbumProvider {
  func fetchAlbums() -> Effect<[Photo], Never> {
    .init(value: [
      .init(id: 1, title: "Title 1", url: ""),
      .init(id: 2, title: "Title 1", url: ""),
      .init(id: 3, title: "Title 1", url: ""),
      .init(id: 4, title: "Title 1", url: ""),
    ])
  }
}
