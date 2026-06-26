import APNS
import Fluent
import FluentPostgresDriver
import JWT
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    #if DEBUG
        app.http.server.configuration.hostname = "127.0.0.1"
    #else
        app.http.server.configuration.hostname = "0.0.0.0"
    #endif
    app.http.server.configuration.port = 8080

//    app.logger.logLevel = .debug

    // Connect to PostgreSQL
    try app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "user_name",
        password: Environment.get("DATABASE_PASSWORD") ?? "password",
        database: Environment.get("DATABASE_NAME") ?? "my_database",
        tls: .prefer(.init(configuration: .clientDefault))
    )
    ), as: .psql)

    // Configure APNs using a .p8 token.
    // The key path and identifiers are read from the environment (see .env.example).
    // Place your own AuthKey_XXXX.p8 in Resources/ (gitignored).
    let apnsKeyPath = DirectoryConfiguration.detect().workingDirectory
        + (Environment.get("APNS_KEY_PATH") ?? "Resources/AuthKey_XXXXXXXXXX.p8")

    let environment: APNSwiftConfiguration.Environment

    #if DEBUG
        environment = .sandbox
    #else
        environment = .production
    #endif

    app.apns.configuration = try .init(
        authenticationMethod: .jwt(
            key: .private(filePath: apnsKeyPath),
            keyIdentifier: Environment.get("APNS_KEY_ID") ?? "your-apns-key-id", // Key ID
            teamIdentifier: Environment.get("APNS_TEAM_ID") ?? "your-apns-team-id" // Team ID
        ),
        topic: Environment.get("APNS_TOPIC") ?? "com.example.YourApp", // App Bundle ID
        environment: environment // or .production for real notifications
    )

    // Configure the JWT signer (set your own key via JWT_SECRET)
    app.jwt.signers.use(.hs256(key: Environment.get("JWT_SECRET") ?? "your-secret-key"))

    // Set the maximum upload body size (e.g. up to 10 MB)
    app.routes.defaultMaxBodySize = "10mb"

    // Configure the S3 client
    app.configureS3()

    app.databaseManager = DatabaseManager(db: app.db)

    GRPCConfiguration.setup(for: app)

    app.middleware.use(HttpLoggerMiddleware())

    app.migrations.add(FirstMigration())
    try await app.autoMigrate()

    try await insertMockData(app: app)

    try routes(app)
}
