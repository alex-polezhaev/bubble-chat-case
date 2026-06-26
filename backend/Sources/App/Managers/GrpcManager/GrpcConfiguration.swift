import GRPC
import NIO
import Vapor

// MARK: - GRPCConfiguration

enum GRPCConfiguration {
    // gRPC server configuration
    static func setup(for app: Application) {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)

        // Create the service providers
        let clientToServerProvider = ClientToServerProvider(app: app)
        let serverToClientProvider = ServerToClientProvider(app: app)
        let contactWithUserActivityProvider = ContactWithUserActivityProvider(app: app)

        // Register `ServerToClientProvider` in `Application`
        app.storage[Application.GRPCStorageKey.self] = serverToClientProvider

        let server = Server.insecure(group: group)
            .withKeepalive(.init(
                interval: .seconds(10), // Interval between keep-alive pings
                timeout: .seconds(5), // Timeout waiting for a keep-alive response
                permitWithoutCalls: true // Allow pings without active calls
            ))
            .withConnectionIdleTimeout(.seconds(5))
            .withServiceProviders([
                clientToServerProvider,
                serverToClientProvider,
                contactWithUserActivityProvider, // Add the new provider
            ])

        #if DEBUG
            .bind(host: "127.0.0.1", port: 50051)
        #else
            .bind(host: "0.0.0.0", port: 50051)
        #endif

        // Add the lifecycle handler
        app.lifecycle.use(GRPCLifecycleHandler(server: server))
    }
}

// MARK: - GRPCLifecycleHandler

struct GRPCLifecycleHandler: LifecycleHandler {
    let server: EventLoopFuture<GRPC.Server>

    func willShutdown(_: Application) {
        server.whenSuccess { $0.close().whenComplete { _ in } }
    }
}

// MARK: - Application Extension

extension Application {
    struct GRPCStorageKey: StorageKey {
        typealias Value = ServerToClientProvider
    }

    var grpcServerToClientProvider: ServerToClientProvider? {
        get { storage[GRPCStorageKey.self] }
        set { storage[GRPCStorageKey.self] = newValue }
    }
}
