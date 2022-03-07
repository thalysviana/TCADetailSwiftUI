import Combine
import Foundation
import UIKit

final class ImageLoader: ObservableObject {
  
  @Published var image = UIImage()
  
  private let session: URLSession
  private let url: String
  private var cancellable: AnyCancellable?
  
  init(session: URLSession = .shared, url: String) {
    self.session = session
    self.url = url
  }
  
  func downloadData() {
    guard let url = URL(string: url) else {
      return
    }
    
    cancellable = session.dataTaskPublisher(for: url)
      .receive(on: DispatchQueue.main)
      .map(\.data)
      .mapError { ImageLoaderError.downloadFailed($0.localizedDescription) }
      .eraseToAnyPublisher()
      .sink { _ in } receiveValue: { data in
        self.image = UIImage(data: data) ?? UIImage()
      }
  }
}

extension ImageLoader {
  enum ImageLoaderError: Error {
    case invalidUrl
    case downloadFailed(String)
  }
}
