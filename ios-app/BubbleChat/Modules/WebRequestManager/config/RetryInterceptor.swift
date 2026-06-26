import Alamofire
import Foundation

class RetryInterceptor: RequestInterceptor {
    private let retryLimit: Int
    private let retryDelay: TimeInterval

    init(retryLimit: Int, retryDelay: TimeInterval) {
        self.retryLimit = retryLimit
        self.retryDelay = retryDelay
    }

    func retry(_ request: Request, for _: Session, dueTo _: Error, completion: @escaping (RetryResult) -> Void) {
        let retryCount = request.retryCount
        if retryCount < retryLimit {
            completion(.retryWithDelay(retryDelay))
        } else {
            completion(.doNotRetry)
        }
    }
}
