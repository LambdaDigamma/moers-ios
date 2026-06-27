//
//  RubbishScheduleViewModelTests.swift
//
//
//  Created by Codex on 27.06.26.
//

import XCTest
@testable import RubbishFeature

nonisolated final class RubbishScheduleViewModelTests: XCTestCase {

    @MainActor
    func testLoadWithConfiguredStreetPublishesSections() async {
        let viewModel = RubbishScheduleViewModel(
            rubbishService: StaticRubbishService(rubbishStreet: Self.street)
        )

        await viewModel.load()

        guard case let .success(sections) = viewModel.state else {
            return XCTFail("Expected successful rubbish sections, got \(viewModel.state)")
        }

        XCTAssertEqual(sections.flatMap(\.items).count, 3)
        XCTAssertFalse(sections.isEmpty)
    }

    @MainActor
    func testLoadWithDisabledServicePublishesDeactivatedError() async {
        let viewModel = RubbishScheduleViewModel(
            rubbishService: StaticRubbishService(
                rubbishStreet: Self.street,
                isEnabled: false
            )
        )

        await viewModel.load()

        guard case .error(.deactivated) = viewModel.state else {
            return XCTFail("Expected deactivated error, got \(viewModel.state)")
        }
    }

    @MainActor
    func testLoadWithoutConfiguredStreetPublishesNoStreetError() async {
        let viewModel = RubbishScheduleViewModel(
            rubbishService: StaticRubbishService(rubbishStreet: nil)
        )

        await viewModel.load()

        guard case .error(.noStreetConfigured) = viewModel.state else {
            return XCTFail("Expected no street configured error, got \(viewModel.state)")
        }
    }

    @MainActor
    func testRepeatedLoadAfterSuccessDoesNotRemainLoading() async {
        let viewModel = RubbishScheduleViewModel(
            rubbishService: StaticRubbishService(rubbishStreet: Self.street)
        )

        await viewModel.load()
        await viewModel.load()

        guard case let .success(sections) = viewModel.state else {
            return XCTFail("Expected successful rubbish sections after repeated load, got \(viewModel.state)")
        }

        XCTAssertFalse(viewModel.state.loading)
        XCTAssertEqual(sections.flatMap(\.items).count, 3)
    }

    private static let street = RubbishCollectionStreet(
        id: 1,
        street: "Musterstrasse",
        residualWaste: 0,
        organicWaste: 0,
        paperWaste: 0,
        yellowBag: 0,
        greenWaste: 0,
        sweeperDay: ""
    )

}
