import Foundation
import XCTest
@testable import moers_festival

@MainActor
final class TicketViewModelTests: XCTestCase {
    func testAllTicketPricesUseCurrencyAndKeepTheirLabels() async {
        let model = viewModel(price: "15", locale: Locale(identifier: "en_US"))
        XCTAssertEqual(model.presale, "Presale: €15.00")
        XCTAssertEqual(model.boxOffice, "Box office: €15.00")
        XCTAssertEqual(model.discountSale, "Presale (discount): €15.00 (*)")
        XCTAssertEqual(model.discountBoxOfficeSale, "Box office (discount): €15.00 (*)")
    }

    func testDecimalPricesFollowTheLocale() async {
        let english = viewModel(price: "19.90", locale: Locale(identifier: "en_US"))
        let comma = viewModel(price: " 19,90 ", locale: Locale(identifier: "en_US"))
        XCTAssertEqual(english.presale, "Presale: €19.90")
        XCTAssertEqual(comma.presale, english.presale)
        let german = viewModel(price: "19,90", locale: Locale(identifier: "de_DE"))
        XCTAssertEqual(german.presale, "Presale: 19,90\u{00A0}€")
    }

    func testUnavailableValuesNeverBecomeZeroPrices() async {
        for value in ["/ ", "", "NaN", "inf", "-1"] {
            let model = viewModel(price: value, locale: Locale(identifier: "en_US"))
            XCTAssertEqual(model.presale, "Presale: Not available")
            XCTAssertEqual(model.boxOffice, "Box office: Not available")
            XCTAssertEqual(model.discountSale, "Presale (discount): Not available (*)")
            XCTAssertEqual(model.discountBoxOfficeSale, "Box office (discount): Not available (*)")
        }
    }

    private func viewModel(price: String, locale: Locale) -> TicketViewModel {
        TicketViewModel(ticket: Ticket(
            title: "Ticket", date: "Date", pricePresale: price, priceBoxOffice: price,
            pricePresaleDiscount: price, priceBoxOfficeDiscount: price, buyURL: nil, type: .mainTicket
        ), locale: locale)
    }
}
