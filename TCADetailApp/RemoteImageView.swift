import Combine
import SwiftUI

struct RemoteImageView<Placeholder: View, Content: View>: View {
  
  private let placeholder: () -> Placeholder
  private let content: (Image) -> Content
  private let imageLoader: ImageLoader
  
  @State var imageData: UIImage?
  
  init(
    url: String,
    @ViewBuilder placeholder: @escaping () -> Placeholder,
    @ViewBuilder content: @escaping (Image) -> Content
  ) {
    self.placeholder = placeholder
    self.content = content
    self.imageLoader = ImageLoader(url: url)
  }
  
  @ViewBuilder private var imageContent: some View {
    Group {
      if let imageData = imageData {
        content(Image(uiImage: imageData))
      } else {
        placeholder()
      }
    }
  }
  
  var body: some View {
    imageContent.onReceive(imageLoader.$image) {
      imageData = $0
    }
    .onAppear(perform: imageLoader.downloadData)
  }
}

struct RemoteImageView_Previews: PreviewProvider {
  static var previews: some View {
    RemoteImageView(
      url: "",
      placeholder: { Color.blue },
      content: { _ in }
    )
  }
}
