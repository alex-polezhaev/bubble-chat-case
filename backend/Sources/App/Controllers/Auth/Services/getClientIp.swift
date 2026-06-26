import Vapor

func getClientIp(req: Request) -> String? {
    if let socketAddress = req.remoteAddress {
        switch socketAddress {
        case let .v4(address):
            return address.host
        case let .v6(address):
            return address.host
        default:
            return nil
        }
    }
    return nil
}
