import SwiftUI

struct UIKitPageControl: UIViewRepresentable {
    var numberOfPages: Int
    @Binding var currentPage: Int

    func makeUIView(context: Context) -> UIPageControl {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = currentPage
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.gray

        pageControl.backgroundStyle = .prominent
        pageControl.addTarget(
            context.coordinator,
            action: #selector(Coordinator.pageChanged),
            for: .valueChanged
        )
        return pageControl
    }

    func updateUIView(_ uiView: UIPageControl, context _: Context) {
        uiView.currentPage = currentPage
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: UIKitPageControl

        init(_ parent: UIKitPageControl) {
            self.parent = parent
        }

        @objc func pageChanged(sender: UIPageControl) {
            parent.currentPage = sender.currentPage
        }
    }
}
