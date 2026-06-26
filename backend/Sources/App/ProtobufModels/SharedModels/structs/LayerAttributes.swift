import Foundation

struct TextAttributes: Codable {
    var text: String
    var fontStyle: String
    var fontColor: String
    var fontSize: Double
    var backgroundStyle: String
    var backgroundColor: String

    // Initialization from Protobuf
    init(from proto: Entities_TextAttributes) {
        text = proto.text
        fontStyle = proto.fontStyle
        fontColor = proto.fontColor
        fontSize = proto.fontSize
        backgroundStyle = proto.backgroundStyle
        backgroundColor = proto.backgroundColor
    }

    // Conversion to Protobuf
    func toProto() -> Entities_TextAttributes {
        return Entities_TextAttributes.with {
            $0.text = text
            $0.fontStyle = fontStyle
            $0.fontColor = fontColor
            $0.fontSize = fontSize
            $0.backgroundStyle = backgroundStyle
            $0.backgroundColor = backgroundColor
        }
    }
}

struct GifAttributes: Codable {
    var url: String
    var width: Double
    var height: Double

    // Initialization from Protobuf
    init(from proto: Entities_GifAttributes) {
        url = proto.url
        width = proto.width
        height = proto.height
    }

    // Conversion to Protobuf
    func toProto() -> Entities_GifAttributes {
        return Entities_GifAttributes.with {
            $0.url = url
            $0.width = width
            $0.height = height
        }
    }
}

struct StickerAttributes: Codable {
    var url: String
    var width: Double
    var height: Double
    var rotation: Double

    // Initialization from Protobuf
    init(from proto: Entities_StickerAttributes) {
        url = proto.url
        width = proto.width
        height = proto.height
        rotation = proto.rotation
    }

    // Conversion to Protobuf
    func toProto() -> Entities_StickerAttributes {
        return Entities_StickerAttributes.with {
            $0.url = url
            $0.width = width
            $0.height = height
            $0.rotation = rotation
        }
    }
}
