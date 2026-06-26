import Vapor

final class HttpLoggerMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        let headers = request.headers.reduce(into: [String: String]()) { result, header in
            result[header.name] = header.value
        }

        let userId: UUID?

        if let userIdString = request.headers["user_id"].first {
            userId = UUID(uuidString: userIdString)
        } else {
            userId = nil
        }

        if request.url.path.contains("/asset") {
            return next.respond(to: request)
        }

        if request.url == "/auth/check_token_header" {
            return next.respond(to: request)
        }
        return next.respond(to: request).flatMap { response in
            let statusCode = Int(exactly: response.status.code)

            let log = HttpLog(
                userId: userId,
                method: request.method.rawValue,
                url: request.url.string,
                headers: headers,
                body: request.body.string,
                responseBody: response.body.string,
                statusCode: statusCode,
                timestamp: Date()
            )

            return log.save(on: request.db).map { response }
        }
    }
}
