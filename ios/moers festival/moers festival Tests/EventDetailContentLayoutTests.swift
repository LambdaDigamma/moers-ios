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
final class EventDetailContentLayoutTests: XCTestCase {
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

    func testContentFollowsWidthAndSafeAreaChangesWithoutHorizontalOverflow() async throws {
        model.header = makeMedia()
        model.pageID = 1
        let hosted = UIHostingController(rootView: ModernEventView(
            viewModel: model, actionTransmitter: ActionTransmitter()
        ))
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let previousKeyWindow = scene.windows.first(where: \.isKeyWindow)
        let window = UIWindow(windowScene: scene)
        window.rootViewController = makeContainer(hosted)
        window.makeKeyAndVisible()
        defer {
            window.isHidden = true
            window.rootViewController = nil
            previousKeyWindow?.makeKey()
        }
        hosted.view.autoresizingMask = []
        let wideWidth = window.bounds.width
        let narrowWidth = wideWidth * 0.7

        for (width, left, right) in [
            (wideWidth, 0.0, 90.0),
            (narrowWidth, 0.0, 90.0),
            (narrowWidth, 70.0, 0.0),
            (wideWidth, 70.0, 0.0),
            (wideWidth, 0.0, 90.0),
        ] {
            hosted.view.frame = CGRect(x: 0, y: 0, width: width, height: window.bounds.height)
            hosted.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: left, bottom: 0, right: right)
            await settle(window)
            let scroll = try XCTUnwrap(descendants(of: hosted.view).compactMap { $0 as? UIScrollView }.first)
            let availableWidth = hosted.view.safeAreaLayoutGuide.layoutFrame.width
            let scrollFrame = scroll.convert(scroll.bounds, to: hosted.view)

            XCTAssertEqual(scrollFrame.minX, hosted.view.bounds.minX, accuracy: 0.5)
            XCTAssertEqual(scrollFrame.width, hosted.view.bounds.width, accuracy: 0.5)
            XCTAssertEqual(scroll.contentSize.width, availableWidth, accuracy: 1)
            XCTAssertEqual(scroll.contentOffset.x, -scroll.adjustedContentInset.left, accuracy: 1)
            XCTAssertTrue(scroll.automaticallyAdjustsScrollIndicatorInsets)
            let geometry = XCTAttachment(string: """
                Host: \(hosted.view.bounds), safe: \(hosted.view.safeAreaLayoutGuide.layoutFrame)
                Scroll: \(scroll.frame), content: \(scroll.contentSize), offset: \(scroll.contentOffset)
                Insets: \(scroll.adjustedContentInset), indicator: \(scroll.verticalScrollIndicatorInsets)
                """)
            geometry.name = "Native scroll geometry"
            geometry.lifetime = .keepAlways
            add(geometry)
            scroll.flashScrollIndicators()
            _ = snapshot(window, name: "Event content \(Int(width)) left \(Int(left)) right \(Int(right))")
        }
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
