import Combine
import SwiftUI

struct RemoteImageView<Placeholder: View>: View {
  @StateObject private var imageLoader: ImageLoader
  
  private let placeholder: () -> Placeholder
  private let content: (Image) -> Image
  @State var data: Data?
  private let imageProvider = ImageNetworkProvider()
  
  init(
    url: String,
    @ViewBuilder placeholder: @escaping () -> Placeholder,
    @ViewBuilder content: @escaping (Image) -> Image = { _ in .init("") }
  ) {
    self.placeholder = placeholder
    self.content = content
    self._imageLoader = .init(wrappedValue: .init(url: url))
  }
  
  @ViewBuilder private var imageContent: some View {
    Group {
      if let image = imageLoader.image {
        content(Image(uiImage: image))
      } else {
        placeholder()
      }
    }
  }
  
  var body: some View {
    imageContent
      .onAppear(perform: imageLoader.downloadData)
  }
}

struct RemoteImageView_Previews: PreviewProvider {
  static var previews: some View {
    RemoteImageView(url: "") {
      Text("Loading...")
    }
  }
}
