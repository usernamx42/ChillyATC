import Foundation

struct ATCFeed: Identifiable, Hashable {
    let id = UUID().uuidString
    let name: String
    let description: String
    let city: String
    let state: String?
    let country: String
    let streamURL: String
    
    var displayName: String {
        var location = [city]
        if let state = state {
            location.append(state)
        }
        location.append(country)
        return "\(name) - \(location.joined(separator: ", "))"
    }
    
    static func == (lhs: ATCFeed, rhs: ATCFeed) -> Bool {
        lhs.id == rhs.id
    }
} 