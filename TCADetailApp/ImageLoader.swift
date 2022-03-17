import Combine
import Foundation
import UIKit

protocol LoadableImage: ObservableObject {
  func downloadData()
}

final class ImageLoader: LoadableImage {
  private let url: String
  private let imageProvider: ImageNetworking
  private let dispatchQueue: DispatchQueue
  private var cancellable: AnyCancellable?
  
  @Published var image: UIImage?
  
  init(
    url: String,
    imageProvider: ImageNetworking = ImageNetworkProvider(),
    dispatchQueue: DispatchQueue = .main
  ) {
    self.url = url
    self.imageProvider = imageProvider
    self.dispatchQueue = dispatchQueue
  }
  
  func downloadData() {
    cancellable = imageProvider.loadURL(url)
      .receive(on: dispatchQueue)
      .sink { _ in } receiveValue: { [weak self] data in
        self?.image = UIImage(data: data)
      }
  }
}

