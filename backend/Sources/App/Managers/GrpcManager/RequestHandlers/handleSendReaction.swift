import Fluent
import Vapor

extension ClientToServerProvider {
    func handleSendReaction(_: Request_SendReactionPayload_Strict, user _: User) async throws -> Response_SendReactionPayload_Strict {
        throw ValidationError.invalidField()
    }
}
