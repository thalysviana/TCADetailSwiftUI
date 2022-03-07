import SwiftUI

struct ContentView: View {
  var body: some View {
    RemoteImageView(url: "https://i0.wp.com/www.vooks.net/img/2021/04/instax.jpg?fit=1424%2C800&ssl=1") {
      Color.blue
    } content: { image in
      image.resizable().scaledToFit()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
