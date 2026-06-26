import Foundation

// Get the new deviceToken from the request body
struct UpdateDeviceTokenRequest: Codable {
    let deviceToken: String
}
