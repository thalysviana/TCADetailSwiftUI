import Foundation

struct Photo: Codable, Equatable, Identifiable {
  let id: Int
  let title: String
  let url: String
}
