import Fluent
import Vapor

extension ClientToServerProvider {
    func handleSendLayer(_: Request_SendLayerPayload_Strict, user _: User) async throws -> Response_SendLayerPayload_Strict {
        throw ValidationError.invalidField()
    }
}
