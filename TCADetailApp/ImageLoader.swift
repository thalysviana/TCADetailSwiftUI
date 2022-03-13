import Combine
import Foundation
import UIKit

protocol LoadableImage: ObservableObject {
  func downloadData()
}

final class ImageLoader: LoadableImage {
  private let session: URLSession
  private let url: String
  private let urlCache: URLCache
  private var cancellable: AnyCancellable?
  
  @Published var image: UIImage?
  
  init(
    session: URLSession = .shared,
    urlCache: URLCache = .shared,
    url: String) {
    self.session = session
    self.urlCache = urlCache
    self.url = url
  }
  
  func downloadData() {
    guard let url = URL(string: url) else {
      return
    }
    
    let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60.0)
    
    if let data = urlCache.cachedResponse(for: request)?.data {
      self.image = UIImage(data: data)
    } else {
      cancellable = session.dataTaskPublisher(for: request)
        .receive(on: DispatchQueue.main)
        .mapError { ImageLoaderError.downloadFailed($0.localizedDescription) }
        .eraseToAnyPublisher()
        .sink { _ in } receiveValue: { [weak self] data, response in
          guard let self = self else { return }
          
          let cachedResponse = CachedURLResponse(response: response, data: data)
          self.urlCache.storeCachedResponse(cachedResponse, for: request)
          
          self.image = UIImage(data: data)
        }
    }
  }
}

extension ImageLoader {
  enum ImageLoaderError: Error {
    case invalidUrl
    case downloadFailed(String)
  }
}
