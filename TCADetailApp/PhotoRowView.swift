import ComposableArchitecture
import SwiftUI

struct PhotoRowView: View {
  let photo: Photo
  
  var body: some View {
    HStack {
      RemoteImageView(url: photo.url, placeholder: {
        Image(systemName: "gear")
          .resizable()
          .background(Color.blue)
      },
      content: { image in
        image
          .resizable()
      })
        .scaledToFill()
        .frame(width: 40, height: 40)
      
      Text(photo.title)
      Spacer()
    }
  }
}

struct PhotoRowView_Previews: PreviewProvider {
  static var previews: some View {
    PhotoRowView(photo: .init(id: 1, title: "Title", url: ""))
  }
}
