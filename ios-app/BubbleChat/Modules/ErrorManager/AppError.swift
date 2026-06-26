import Alamofire
import Foundation

enum AppError: Error, Codable {
    case network(description: String, file: String = #file, line: Int = #line, function: String = #function)
    case decoding(description: String, file: String = #file, line: Int = #line, function: String = #function)
    case database(description: String, file: String = #file, line: Int = #line, function: String = #function)
    case unknown(description: String, file: String = #file, line: Int = #line, function: String = #function)

    // Name of the current case (e.g., Network, Decoding)
    var type: String {
        switch self {
        case .network:
            return "Network"
        case .decoding:
            return "Decoding"
        case .database:
            return "Database"
        case .unknown:
            return "Unknown"
        }
    }

    // General error description
    var metadata: (description: String, file: String, line: Int, function: String) {
        switch self {
        case let .network(description, file, line, function),
             let .decoding(description, file, line, function),
             let .database(description, file, line, function),
             let .unknown(description, file, line, function):
            return (description, file, line, function)
        }
    }

    // Method to automatically report the error via Alamofire
    func sendToServer() -> AppError {
        let url = "https://your-error-endpoint.example"
        let payload = ClientErrorRequest(
            type: type, // Send the case name
            description: metadata.description,
            file: metadata.file,
            line: metadata.line,
            function: metadata.function,
            timestamp: ISO8601DateFormatter().string(from: Date())
        )

        AF.request(url, method: .post, parameters: payload, encoder: JSONParameterEncoder.default)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    print("Error successfully sent to server")
                case let .failure(error):
                    print("Failed to send error: \(error.localizedDescription)")
                }
            }

        return self
    }
}

// Structure for error data
struct ClientErrorRequest: Codable {
    let type: String
    let description: String
    let file: String
    let line: Int
    let function: String
    let timestamp: String
}
