import Combine
import Foundation
import GRPC
import Logging
import Network
import NIO
import NIOSSL

final class GRPCManager: ObservableObject {
    static let shared = GRPCManager()

    private var group: EventLoopGroup?
    private var connection: ClientConnection?

    var serverToClientProvider: ServerToClientProvider?
    var contactWithUserActivityProvider: ContactWithUserActivityProvider?
    var clientToServerProvider: ClientToServerProvider?

    private var timerCancellable: AnyCancellable?

    @Published var connectionState: ConnectivityState?
    @Published var isSTCActive: Bool = false
    @Published var isCWUAActive: Bool = false
    @Published var isCTSActive: Bool = false

    private init() {}

    func initialize() {
        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        #if DEBUG
            // Debug configuration
            connection = ClientConnection
                .insecure(group: group!)
                .withKeepalive(ClientConnectionKeepalive(
                    interval: .seconds(10),
                    timeout: .seconds(5)
                ))
                .connect(host: DEV_GRPC_HOST, port: DEV_GRPC_PORT)
        #else
            // Release configuration
            connection = ClientConnection
                .usingPlatformAppropriateTLS(for: .singletonMultiThreadedEventLoopGroup)
                .connect(host: GRPC_HOST)

        #endif

        let callOptions = CallOptions(
            customMetadata: ["Authorization": getBearerToken()]
        )

        // Initialize providers
        serverToClientProvider = ServerToClientProvider(
            connection: connection!,
            callOptions: callOptions
        )
        contactWithUserActivityProvider = ContactWithUserActivityProvider(
            connection: connection!,
            callOptions: callOptions
        )
        clientToServerProvider = ClientToServerProvider(
            connection: connection!,
            callOptions: callOptions
        )

        runStreams()

        startMonitoringConnectionState()
    }

    func runStreams() {
        // Start providers
        serverToClientProvider?.startStream()
        contactWithUserActivityProvider?.startStream()
        clientToServerProvider?.startStream()
    }

    func shutdown() throws {
        // Shut down providers
        serverToClientProvider?.clean()
        contactWithUserActivityProvider?.clean()
        clientToServerProvider?.clean()

        serverToClientProvider = nil
        contactWithUserActivityProvider = nil
        clientToServerProvider = nil

        // Close the connection
        try connection?.close().wait()
        try group?.syncShutdownGracefully()

        group = nil
        connection = nil
    }

    deinit {
        try? shutdown()
    }

    private func startMonitoringConnectionState() {
        // Create a timer that fires every second
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateConnectionState()
            }
    }

    private func updateConnectionState() {
        if connection?.connectivity.state != connectionState {
            connectionState = connection?.connectivity.state
            print("Connection state changed: \(String(describing: connectionState))")
        }
    }
}
