import Events
import FactoryKit
import GRDB
import MediaLibraryKit
import Pages
import SwiftUI
import UIKit
import XCTest
@testable import moers_festival

@MainActor
final class EventDetailPresentationTests: XCTestCase {
    private var model: EventDetailViewModel!
    private var imageURL: URL!

    override func setUp() async throws {
        try await super.setUp()
        let queue = try DatabaseQueue()
        let database = try AppDatabase(queue)
        let repository = EventRepository(
            store: EventStore(writer: database.dbWriter, reader: database.reader),
            service: StaticEventService(events: .success([])), pageStore: nil
        )
        Container.shared.eventRepository.register { repository }
        let pageRepository = PageRepository(
            service: MockPageService(result: .success(try makeArticle())),
            store: PageStore(writer: database.dbWriter, reader: database.reader)
        )
        Container.shared.pageRepository.register { pageRepository }
        try await pageRepository.reloadPage(for: 1)
        model = EventDetailViewModel(eventID: nil)
        model.event = Event(id: 10, name: "Event with a long, wrapping title")
        imageURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID()).png")
        let image = UIGraphicsImageRenderer(size: CGSize(width: 320, height: 180)).image { context in
            UIColor.systemBlue.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 320, height: 180))
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 45, width: 320, height: 6))
        }
        try XCTUnwrap(image.pngData()).write(to: imageURL)
    }

    override func tearDown() async throws {
        model = nil
        try FileManager.default.removeItem(at: imageURL)
        imageURL = nil
        Container.shared.eventRepository.reset()
        Container.shared.pageRepository.reset()
        try await super.tearDown()
    }

    func testNativeTitleAppearsAfterArtworkAndClearsOnReturn() async throws {
        model.header = makeMedia()
        model.pageID = 1
        let navigation = UINavigationController()
        let hosted = UIHostingController(rootView: ModernEventView(
            viewModel: model, actionTransmitter: ActionTransmitter(),
            updateNavigationTitle: { [weak navigation] title in
                navigation?.topViewController?.navigationItem.title = title
            }
        ))
        hosted.navigationItem.largeTitleDisplayMode = .never
        hosted.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "heart"), style: .plain, target: nil, action: nil
        )
        navigation.setViewControllers([hosted], animated: false)
        let navigationItem = hosted.navigationItem
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let previousKeyWindow = scene.windows.first(where: \.isKeyWindow)
        let window = UIWindow(windowScene: scene)
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        defer {
            window.isHidden = true
            window.rootViewController = nil
            previousKeyWindow?.makeKey()
        }
        await settle(window)
        let scroll = try XCTUnwrap(descendants(of: hosted.view).compactMap { $0 as? UIScrollView }.first)
        for _ in 0..<20 where scroll.contentSize.height < scroll.bounds.height * 2 {
            await settle(window)
        }
        XCTAssertGreaterThan(scroll.contentSize.height, scroll.bounds.height * 2)
        XCTAssertNil(navigationItem.title)

        scroll.setContentOffset(CGPoint(x: 0, y: 20), animated: false)
        await settle(window)
        XCTAssertNil(navigationItem.title, "A partial scroll must keep the artwork clear.")

        let bodyOffset = scroll.contentSize.height / 2
        scroll.setContentOffset(CGPoint(x: 0, y: bodyOffset), animated: false)
        await settle(window)
        XCTAssertEqual(navigationItem.title, model.event?.name)

        for offset in [bodyOffset + 50, bodyOffset - 50] {
            scroll.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
            await settle(window)
            XCTAssertEqual(navigationItem.title, model.event?.name)
        }

        scroll.setContentOffset(CGPoint(x: 0, y: -scroll.adjustedContentInset.top), animated: false)
        await settle(window)
        XCTAssertNil(navigationItem.title)
    }

    func testMissingArtworkKeepsNativeTitleAndObservesEventChanges() async {
        let navigationItem = UINavigationItem()
        let hosted = UIHostingController(rootView: ModernEventView(
            viewModel: model, actionTransmitter: ActionTransmitter(),
            updateNavigationTitle: { navigationItem.title = $0 }
        ))
        let window = mount(hosted)
        defer { window.isHidden = true }
        await settle(window)
        XCTAssertEqual(navigationItem.title, model.event?.name)

        model.event?.name = "Updated event"
        await settle(window)
        XCTAssertEqual(navigationItem.title, "Updated event")
    }

    func testPullStretchesArtworkAndExtensionWithoutChangingLayout() async throws {
        model.header = makeMedia()
        let hosted = UIHostingController(rootView: ModernEventView(
            viewModel: model, actionTransmitter: ActionTransmitter()
        ))
        let container = makeContainer(hosted)
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let previousKeyWindow = scene.windows.first(where: \.isKeyWindow)
        let window = UIWindow(windowScene: scene)
        window.rootViewController = container
        window.makeKeyAndVisible()
        defer {
            window.isHidden = true
            window.rootViewController = nil
            previousKeyWindow?.makeKey()
        }
        hosted.view.autoresizingMask = []
        hosted.view.frame = CGRect(x: 0, y: 0, width: 320, height: 600)
        for trailingInset in [true, false] {
            hosted.additionalSafeAreaInsets = UIEdgeInsets(
                top: 0, left: trailingInset ? 0 : 50, bottom: 0, right: trailingInset ? 50 : 0
            )
            await settle(window)
            let scroll = try XCTUnwrap(descendants(of: hosted.view).compactMap { $0 as? UIScrollView }.first)
            scroll.showsVerticalScrollIndicator = false
            XCTAssertTrue(scroll.alwaysBounceVertical, "Short event pages must still support a pull.")
            try await assertArtworkPulls(
                in: window, scroll: scroll,
                safeFrame: hosted.view.safeAreaLayoutGuide.layoutFrame, trailingInset: trailingInset
            )
        }
    }

    func testArtworkHeightRespondsToViewportWithoutChangingScrollPosition() async throws {
        model.header = makeMedia()
        let hosted = UIHostingController(rootView: ModernEventView(
            viewModel: model, actionTransmitter: ActionTransmitter()
        ))
        let container = makeContainer(hosted)
        let window = mount(container)
        defer { window.isHidden = true }
        hosted.view.frame = CGRect(x: 0, y: 0, width: 600, height: 800)
        await settle(window)
        let scroll = try XCTUnwrap(descendants(of: hosted.view).compactMap { $0 as? UIScrollView }.first)
        let tallContentHeight = scroll.contentSize.height
        let offset = scroll.contentOffset

        hosted.view.frame.size.height = 300
        await settle(window)
        XCTAssertLessThan(scroll.contentSize.height, tallContentHeight)
        XCTAssertEqual(scroll.contentOffset.y, offset.y, accuracy: 0.5)

        hosted.view.frame.size.height = 800
        await settle(window)
        XCTAssertEqual(scroll.contentSize.height, tallContentHeight, accuracy: 0.5)
    }

    func testScrollViewExtendsUnderBarsWithAsymmetricSafeAreas() async throws {
        model.header = makeMedia()
        let hosted = UIHostingController(rootView: ModernEventView(
            viewModel: model, actionTransmitter: ActionTransmitter()
        ))
        hosted.additionalSafeAreaInsets = UIEdgeInsets(top: 80, left: 40, bottom: 20, right: 90)
        let window = mount(hosted)
        defer { window.isHidden = true }
        await settle(window)
        let scroll = try XCTUnwrap(descendants(of: hosted.view).compactMap { $0 as? UIScrollView }.first)
        let frame = scroll.convert(scroll.bounds, to: hosted.view)

        XCTAssertEqual(frame.minX, hosted.view.bounds.minX, accuracy: 0.5)
        XCTAssertEqual(frame.minY, hosted.view.bounds.minY, accuracy: 0.5)
        XCTAssertEqual(frame.width, hosted.view.bounds.width, accuracy: 0.5)
        XCTAssertEqual(frame.height, hosted.view.bounds.height, accuracy: 0.5)
        if #available(iOS 26, *) {
            XCTAssertEqual(scroll.adjustedContentInset.top, 0, accuracy: 0.5)
        } else {
            XCTAssertGreaterThan(scroll.adjustedContentInset.top, 0)
        }
    }

    private func assertArtworkPulls(
        in window: UIWindow, scroll: UIScrollView, safeFrame: CGRect, trailingInset: Bool
    ) async throws {
        let column = Int(safeFrame.midX)
        var before = snapshot(window, name: "Artwork before pull")
        for _ in 0..<10 {
            let color = try rgba(before, x: column, y: 100)
            if Int(color[2]) - Int(color[0]) > 40 { break }
            await settle(window)
            before = snapshot(window, name: "Artwork loaded")
        }
        let originalMarker = try XCTUnwrap(firstRedRow(before, x: column))
        let originalContentSize = scroll.contentSize
        let originalOffset = scroll.contentOffset
        let headerHeight = safeFrame.width * 9 / 16

        for distance in [30.0, 120.0, 240.0] {
            scroll.setContentOffset(CGPoint(x: 0, y: originalOffset.y - distance), animated: false)
            await settle(window)
            let pulled = snapshot(window, name: "Artwork pull \(Int(distance)), trailing inset \(trailingInset)")
            let pull = originalOffset.y - scroll.contentOffset.y
            XCTAssertEqual(pull, distance, accuracy: 0.5)
            XCTAssertEqual(scroll.contentSize, originalContentSize)
            let pulledMarker = try XCTUnwrap(firstRedRow(pulled, x: column))
            XCTAssertEqual(CGFloat(pulledMarker), CGFloat(originalMarker) * (1 + pull / headerHeight), accuracy: 3)
            let row = Int((headerHeight + pull) * 0.6)
            for x in [column, trailingInset ? 310 : 10] {
                if #unavailable(iOS 26), x != column { continue }
                let color = try rgba(pulled, x: x, y: row)
                XCTAssertGreaterThan(Int(color[2]) - Int(color[0]), 40, "Artwork must fill the pulled top and side region.")
            }
            if #available(iOS 26, *) {
                let colors = try (0..<Int(scroll.bounds.width)).map { try rgba(pulled, x: $0, y: row) }
                for (previous, current) in zip(colors, colors.dropFirst()) {
                    let delta = zip(previous, current).prefix(3).map { abs(Int($0.0) - Int($0.1)) }.max() ?? 0
                    XCTAssertLessThan(delta, 48, "The uniform image row must have no sharp seam, including displaced seams.")
                }
            }
        }

        scroll.setContentOffset(originalOffset, animated: false)
        await settle(window)
        let returned = snapshot(window, name: "Artwork after release")
        XCTAssertEqual(try firstRedRow(returned, x: column), originalMarker)
        XCTAssertEqual(scroll.contentSize, originalContentSize)
    }

    private func makeMedia() -> Media {
        Media(
            id: 1, modelType: "Event", modelID: 10, uuid: nil, collectionName: "header",
            fullURL: imageURL.absoluteString, name: "Header fixture", fileName: "header.png", size: 0,
            alt: "Event artwork", caption: nil, credits: "Photo credit"
        )
    }

    private func makeArticle() throws -> Pages.Page {
        let text = String(repeating: "A long event description for the scroll test. ", count: 250)
        let data = try JSONSerialization.data(withJSONObject: [
            "text": ["type": "document", "content": [
                ["type": "paragraph", "content": [["type": "text", "text": text]]]
            ]]
        ])
        let block = try JSONDecoder().decode(TextBlock.self, from: data)
        var page = Pages.Page.stub(withID: 1)
        page.blocks = [PageBlock(id: 1, pageID: 1, blockType: .text, data: AnyBlockable(block))]
        return page
    }

    private func snapshot(_ window: UIWindow, name: String) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(size: window.bounds.size, format: format).image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        return image
    }

    private func firstRedRow(_ image: UIImage, x: Int) throws -> Int? {
        for y in 0..<150 {
            let color = try rgba(image, x: x, y: y)
            if color[0] > 200 && color[1] < 80 && color[2] < 80 { return y }
        }
        return nil
    }

    private func rgba(_ image: UIImage, x: Int, y: Int) throws -> [UInt8] {
        let source = try XCTUnwrap(image.cgImage)
        let pixel = try XCTUnwrap(source.cropping(to: CGRect(
            x: CGFloat(x) * image.scale, y: CGFloat(y) * image.scale, width: 1, height: 1
        )))
        var bytes = [UInt8](repeating: 0, count: 4)
        try bytes.withUnsafeMutableBytes { buffer in
            let context = try XCTUnwrap(CGContext(
                data: buffer.baseAddress, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
            ))
            context.draw(pixel, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        return bytes
    }

    private func mount(_ controller: UIViewController) -> UIWindow {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 600, height: 800))
        window.rootViewController = controller
        window.isHidden = false
        return window
    }

    private func makeContainer(_ child: UIViewController) -> UIViewController {
        let controller = UIViewController()
        controller.addChild(child)
        controller.view.addSubview(child.view)
        child.didMove(toParent: controller)
        return controller
    }

    private func settle(_ window: UIWindow) async {
        for _ in 0..<5 {
            window.layoutIfNeeded()
            try? await Task.sleep(for: .milliseconds(30))
        }
    }

    private func descendants(of view: UIView) -> [UIView] {
        view.subviews.flatMap { [$0] + descendants(of: $0) }
    }
}
