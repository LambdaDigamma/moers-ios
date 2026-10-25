import SwiftUI
import UIKit
import XCTest
@testable import moers_festival

@MainActor
final class EventDetailImageTransitionTests: XCTestCase {
    func testProgressiveBlurPreservesTopDetailAndBlendsIntoTheBackground() async throws {
        for scheme in [ColorScheme.light, .dark] {
            let blurred = try await render(scheme: scheme, isBlurEnabled: true)
            let fadeOnly = try await render(scheme: scheme, isBlurEnabled: false)

            XCTAssertLessThan(try red(blurred, x: 156, y: 40), 3, "The upper image must stay sharp.")
            XCTAssertGreaterThan(try red(blurred, x: 164, y: 40), 252)
            XCTAssertEqual(try red(blurred, x: 159, y: 40), try red(fadeOnly, x: 159, y: 40), accuracy: 1)
            let nearEdge = try red(blurred, x: 158, y: 230)
            let farFromEdge = try red(blurred, x: 140, y: 230)
            XCTAssertGreaterThan(nearEdge - farFromEdge, 12, "Blur must spread the edge near the bottom.")
            XCTAssertEqual(try red(fadeOnly, x: 158, y: 230), try red(fadeOnly, x: 140, y: 230), accuracy: 2)
            XCTAssertEqual(try red(blurred, x: 100, y: 298), scheme == .light ? 255 : 0, accuracy: 2)
        }
    }

    private func render(scheme: ColorScheme, isBlurEnabled: Bool) async throws -> UIImage {
        let source = UIGraphicsImageRenderer(size: CGSize(width: 320, height: 300)).image { context in
            UIColor.black.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 160, height: 300))
            UIColor.white.setFill()
            context.fill(CGRect(x: 160, y: 0, width: 160, height: 300))
        }
        let hosted = UIHostingController(rootView: Image(uiImage: source)
            .resizable()
            .frame(width: 320, height: 300)
            .modifier(EventDetailImageTransition(height: 300, isBlurEnabled: isBlurEnabled))
            .environment(\.colorScheme, scheme)
            .ignoresSafeArea())
        let container = UIViewController()
        container.addChild(hosted)
        container.view.addSubview(hosted.view)
        hosted.didMove(toParent: container)
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let previous = scene.windows.first(where: \.isKeyWindow)
        let window = UIWindow(windowScene: scene)
        window.rootViewController = container
        window.makeKeyAndVisible()
        defer {
            window.isHidden = true
            window.rootViewController = nil
            previous?.makeKey()
        }
        hosted.view.frame = CGRect(x: 0, y: 0, width: 320, height: 300)
        for _ in 0..<10 {
            window.layoutIfNeeded()
            try await Task.sleep(for: .milliseconds(50))
        }
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(size: hosted.view.bounds.size, format: format).image { _ in
            hosted.view.drawHierarchy(in: hosted.view.bounds, afterScreenUpdates: true)
        }
        let attachment = XCTAttachment(image: image)
        attachment.name = "Transition \(scheme), blur \(isBlurEnabled)"
        attachment.lifetime = .keepAlways
        add(attachment)
        return image
    }

    private func red(_ image: UIImage, x: Int, y: Int) throws -> Int {
        let source = try XCTUnwrap(image.cgImage)
        let pixel = try XCTUnwrap(source.cropping(to: CGRect(x: x, y: y, width: 1, height: 1)))
        var bytes = [UInt8](repeating: 0, count: 4)
        try bytes.withUnsafeMutableBytes { buffer in
            let context = try XCTUnwrap(CGContext(
                data: buffer.baseAddress, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
            ))
            context.draw(pixel, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        return Int(bytes[0])
    }
}
