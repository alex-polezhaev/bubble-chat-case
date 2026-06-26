import Foundation
import Moya

/// Plugin that adds the authorization token to the header of every request
final class BearerTokenPlugin: PluginType {
    /// Method to retrieve the token
    private let tokenProvider: () -> String?

    /// Initialize with a closure that retrieves the token
    init(tokenProvider: @escaping () -> String?) {
        self.tokenProvider = tokenProvider
    }

    /// Add the token before sending the request
    func prepare(_ request: URLRequest, target _: TargetType) -> URLRequest {
        var request = request
        if let token = tokenProvider(), !token.isEmpty {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("BearerTokenPlugin: token is missing")
        }
        return request
    }
}
