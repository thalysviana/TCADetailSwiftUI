import SwiftUI

struct PhotoView: View {
  let photo: Photo
  
  var body: some View {
    VStack {
      RemoteImageView(url: photo.url) {
        Image(systemName: "gear")
          .resizable()
          .scaledToFill()
      } content: { image in
        image
          .resizable()
      }
        .frame(width: 300, height: 300)
      Text(photo.title)
        .padding(.top, 40)
        Spacer()
    }
    .padding()
  }
}

struct PhotoView_Previews: PreviewProvider {
  static var previews: some View {
    PhotoView(photo: .init(id: 1, title: "Title", url: ""))
  }
}
