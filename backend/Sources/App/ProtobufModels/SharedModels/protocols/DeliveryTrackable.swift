import Foundation

protocol DeliveryTrackable: HasCreatedAt {
    var status: DeliveryStatus { get set }
    var editedAt: Date? { get set }
}
