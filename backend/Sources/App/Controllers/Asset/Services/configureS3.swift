import SotoCore
import SotoS3
import Vapor

extension Application {
    private struct S3ClientKey: StorageKey {
        typealias Value = S3
    }

    // Property to access the S3 client through Application
    var s3: S3 {
        get {
            guard let s3Client = storage[S3ClientKey.self] else {
                fatalError("S3 Client not configured. Use app.s3.configure()")
            }
            return s3Client
        }
        set {
            storage[S3ClientKey.self] = newValue
        }
    }

    // Configures the S3 client at startup.
    // Credentials are read from the environment only — there are no hardcoded fallbacks.
    func configureS3() {
        guard let accessKeyId = Environment.get("S3_ACCESS_KEY") else {
            fatalError("S3_ACCESS_KEY is not set. Provide it via the environment (see .env.example).")
        }
        guard let secretAccessKey = Environment.get("S3_SECRET_KEY") else {
            fatalError("S3_SECRET_KEY is not set. Provide it via the environment (see .env.example).")
        }
        let endpoint = Environment.get("S3_ENDPOINT") ?? "https://storage.yandexcloud.net"

        // S3 client configuration for Yandex Object Storage
        let awsClient = AWSClient(
            credentialProvider: .static(accessKeyId: accessKeyId, secretAccessKey: secretAccessKey),
            httpClientProvider: .createNew
        )

        s3 = S3(client: awsClient, region: .eucentral1, endpoint: endpoint)
    }
}
