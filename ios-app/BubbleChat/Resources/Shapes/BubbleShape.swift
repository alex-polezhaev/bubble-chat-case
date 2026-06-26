import SwiftUI

struct BubbleShape: InsettableShape {
    var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let insetRect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        let width = insetRect.size.width
        let height = insetRect.size.height

        path.move(to: CGPoint(x: 0, y: 0.5 * height))
        path.addCurve(
            to: CGPoint(x: 0.04377 * width, y: 0.13918 * height),
            control1: CGPoint(x: 0, y: 0.30669 * height),
            control2: CGPoint(x: 0, y: 0.21004 * height)
        )
        path.addCurve(
            to: CGPoint(x: 0.13918 * width, y: 0.04377 * height),
            control1: CGPoint(x: 0.06773 * width, y: 0.10039 * height),
            control2: CGPoint(x: 0.10039 * width, y: 0.06773 * height)
        )
        path.addCurve(
            to: CGPoint(x: 0.5 * width, y: 0),
            control1: CGPoint(x: 0.21004 * width, y: 0),
            control2: CGPoint(x: 0.30669 * width, y: 0)
        )
        path.addCurve(
            to: CGPoint(x: 0.86083 * width, y: 0.04377 * height),
            control1: CGPoint(x: 0.69331 * width, y: 0),
            control2: CGPoint(x: 0.78996 * width, y: 0)
        )
        path.addCurve(
            to: CGPoint(x: 0.95623 * width, y: 0.13918 * height),
            control1: CGPoint(x: 0.89961 * width, y: 0.06773 * height),
            control2: CGPoint(x: 0.93227 * width, y: 0.10039 * height)
        )
        path.addCurve(
            to: CGPoint(x: width, y: 0.5 * height),
            control1: CGPoint(x: width, y: 0.21004 * height),
            control2: CGPoint(x: width, y: 0.30669 * height)
        )
        path.addCurve(
            to: CGPoint(x: 0.95623 * width, y: 0.86083 * height),
            control1: CGPoint(x: width, y: 0.69331 * height),
            control2: CGPoint(x: width, y: 0.78996 * height)
        )
        path.addCurve(
            to: CGPoint(x: 0.86083 * width, y: 0.95623 * height),
            control1: CGPoint(x: 0.93227 * width, y: 0.89961 * height),
            control2: CGPoint(x: 0.89961 * width, y: 0.93227 * height)
        )
        path.addCurve(
            to: CGPoint(x: 0.5 * width, y: height),
            control1: CGPoint(x: 0.78996 * width, y: height),
            control2: CGPoint(x: 0.69331 * width, y: height)
        )
        path.addCurve(
            to: CGPoint(x: 0.13918 * width, y: 0.95623 * height),
            control1: CGPoint(x: 0.30669 * width, y: height),
            control2: CGPoint(x: 0.21004 * width, y: height)
        )
        path.addCurve(
            to: CGPoint(x: 0.04377 * width, y: 0.86083 * height),
            control1: CGPoint(x: 0.10039 * width, y: 0.93227 * height),
            control2: CGPoint(x: 0.06773 * width, y: 0.89961 * height)
        )
        path.addCurve(
            to: CGPoint(x: 0, y: 0.5 * height),
            control1: CGPoint(x: 0, y: 0.78996 * height),
            control2: CGPoint(x: 0, y: 0.69331 * height)
        )
        path.closeSubpath()

        return path
    }

    func inset(by amount: CGFloat) -> some InsettableShape {
        var shape = self
        shape.insetAmount += amount
        return shape
    }
}
