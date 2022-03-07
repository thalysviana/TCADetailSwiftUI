import SwiftUI

struct PhotoView: View {
  var body: some View {
    VStack {
      Image(systemName: "gear")
        .resizable()
        .scaledToFill()
        .frame(width: 300, height: 300)
      Text("Description")
        .padding(.top, 40)
        Spacer()
    }
    .padding()
  }
}

struct PhotoView_Previews: PreviewProvider {
  static var previews: some View {
    PhotoView()
  }
}
