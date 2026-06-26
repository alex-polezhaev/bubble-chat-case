import Alamofire
import Vapor

struct CallVerificationResponse: Content {
    var status: String
    var code: String
    var call_id: String
    var cost: Double
    var balance: Double
}

func callVerificationCode(phone: String, req: Vapor.Request) async throws -> CallVerificationResponse {
    // Get api_id from the environment variables (sms.ru). Env-only, no hardcoded fallback.
    guard let apiId = Environment.get("SMS_API_ID") else {
        throw Abort(.internalServerError, reason: "SMS_API_ID is not set. Provide it via the environment (see .env.example).")
    }

    guard let ip = getClientIp(req: req) else {
        throw Abort(.internalServerError, reason: "Unknown IP address")
    }

    // Request URL
    let url = "https://sms.ru/code/call"

    // Request parameters
    let parameters: [String: String] = [
        "phone": phone,
        "ip": "-1",
        "api_id": apiId,
    ]

    return try await withCheckedThrowingContinuation { continuation in
        AF.request(url, parameters: parameters)
            .response { response in
                guard let data = response.data else {
                    continuation.resume(throwing: Abort(.internalServerError, reason: "Empty response body"))
                    return
                }

                // Use JSONSerialization to parse the data
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        // Extract data from the JSON
                        let status = jsonObject["status"] as? String ?? ""
                        let call_id = jsonObject["call_id"] as? String ?? ""
                        let cost = jsonObject["cost"] as? Double ?? 0.0
                        let balance = jsonObject["balance"] as? Double ?? 0.0

                        // Handle code, which can be either a string or a number
                        let code: String
                        if let codeString = jsonObject["code"] as? String {
                            code = codeString
                        } else if let codeNumber = jsonObject["code"] as? Int {
                            code = String(codeNumber)
                        } else {
                            code = ""
                        }

                        // Create and return CallVerificationResponse
                        let callVerificationResponse = CallVerificationResponse(
                            status: status,
                            code: code,
                            call_id: call_id,
                            cost: cost,
                            balance: balance
                        )
                        continuation.resume(returning: callVerificationResponse)
                    } else {
                        continuation.resume(throwing: Abort(.internalServerError, reason: "Invalid response format"))
                    }
                } catch {
                    // Handle the JSON parsing error
                    let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode response body"
                    print("Error decoding response: \(error)")
                    print("Response body: \(responseString)")

                    continuation.resume(throwing: Abort(.internalServerError, reason: "Failed to decode response: \(error)"))
                }
            }
    }
}
