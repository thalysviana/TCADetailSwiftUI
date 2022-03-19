import Combine
import Foundation
import UIKit

protocol ImageNetworking {
  func loadURL(_ url: String) -> AnyPublisher<Data, ImageNetworkProvider.ImageNetworkError>
}

final class ImageNetworkProvider: ImageNetworking {
  private let session: URLSession
  private let urlCache: URLCacheable
  
  init(session: URLSession = .shared, urlCache: URLCacheable = URLCache.shared) {
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
      .mapError { _ in ImageNetworkError.downloadFailed("Could not finish image download") }
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

extension ImageNetworkProvider.ImageNetworkError: Equatable {
  public static func == (lhs: ImageNetworkProvider.ImageNetworkError, rhs: ImageNetworkProvider.ImageNetworkError) -> Bool {
    switch (lhs, rhs) {
    case (.invalidUrl, .invalidUrl):
      return true
    case let (.downloadFailed(lhsString), .downloadFailed(rhsString)):
      return lhsString == rhsString
    default:
      return false
    }
  }
}
