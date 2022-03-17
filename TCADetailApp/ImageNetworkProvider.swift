import Combine
import Foundation
import UIKit

protocol ImageNetworking {
  func loadURL(_ url: String) -> AnyPublisher<Data, ImageNetworkProvider.ImageNetworkError>
}

final class ImageNetworkProvider: ImageNetworking {
  private let session: URLSession
  private let urlCache: URLCache
  
  init(session: URLSession = .shared, urlCache: URLCache = .shared) {
    self.session = session
    self.urlCache = urlCache
  }
  
  func loadURL(_ url: String) -> AnyPublisher<Data, ImageNetworkError> {
    guard let url = URL(string: url) else {
      return Fail(error: ImageNetworkError.invalidUrl).eraseToAnyPublisher()
    }
    
    let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60.0)
  
    if let data = urlCache.cachedResponse(for: request)?.data {
      return Just(data)
        .setFailureType(to: ImageNetworkError.self)
        .eraseToAnyPublisher()
    }
    
    return session.dataTaskPublisher(for: request)
      .mapError { ImageNetworkError.downloadFailed($0.localizedDescription) }
      .handleEvents(receiveOutput: { [weak self] data, response in
        guard let self = self else { return }
        
        let cachedResponse = CachedURLResponse(response: response, data: data)
        self.urlCache.storeCachedResponse(cachedResponse, for: request)
      })
      .map(\.data)
      .eraseToAnyPublisher()
  }
  
}

extension ImageNetworkProvider {
  enum ImageNetworkError: Error {
    case invalidUrl
    case downloadFailed(String)
  }
}
