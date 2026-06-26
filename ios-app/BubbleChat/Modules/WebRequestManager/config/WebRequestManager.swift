import Alamofire
import Foundation
import KeychainAccess
import Moya

class WebRequestManager {
    private let retryInterceptor: RetryInterceptor
    private let session: Session
    let provider: MoyaProvider<BackendEndpoints>

    /// Initializer for configuring the request manager
    init(retryLimit: Int = 3, retryDelay: TimeInterval = 2, additionalPlugins: [PluginType] = []) {
        // Configure the interceptor for retries
        retryInterceptor = RetryInterceptor(retryLimit: retryLimit, retryDelay: retryDelay)

        // Create an Alamofire session with the interceptor
        session = Session(interceptor: retryInterceptor)

        let bearerTokenPlugin = BearerTokenPlugin {
            getAccessToken()
        }

        // Add built-in plugins and additional plugins
        var plugins: [PluginType] = [
            bearerTokenPlugin,
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)), // Logging
            // Authorization plugin
        ]
        plugins.append(contentsOf: additionalPlugins)

        // Create a MoyaProvider with the custom session and plugins
        provider = MoyaProvider<BackendEndpoints>(session: session, plugins: plugins)
    }
}
