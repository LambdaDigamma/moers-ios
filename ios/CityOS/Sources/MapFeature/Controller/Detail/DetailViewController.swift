import Core
import FactoryKit
import FuelFeature
import MapKit
import SafariServices
import SwiftUI
import UIKit

public final class DetailViewController: UITableViewController {
    @LazyInjected(\.locationService) private var locationService
    @LazyInjected(\.entryManager) private var entryManager
    @LazyInjected(\.petrolService) private var petrolService
    public weak var coordinator: MapCoordintor?
    private let placeHeader = MapPlaceHeaderView()
    private var sections: [MapPlaceSection] = []
    private var authorizationTask: Task<Void, Never>?
    private var distanceTask: Task<Void, Never>?
    public var selectedLocation: Location? {
        didSet { if isViewLoaded { configurePlace() } }
    }

    init() { super.init(style: .insetGrouped) }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlaceInfo")
        tableView.tableHeaderView = placeHeader
        placeHeader.performAction = { [weak self] in self?.perform($0) }
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (controller: DetailViewController, _) in
            controller.tableView.reloadData()
        }
        configurePlace()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let expanded = view.safeAreaLayoutGuide.layoutFrame.height >= 210
        placeHeader.showsActions = expanded
        tableView.isScrollEnabled = expanded
        sizeHeader()
    }

    private func sizeHeader() {
        let width = tableView.bounds.width
        guard width > 0 else { return }
        // The sheet animates its container. Header sizing must not add another frame animation.
        UIView.performWithoutAnimation {
            if abs(placeHeader.frame.width - width) > 0.5 {
                placeHeader.frame.size.width = width
            }
            placeHeader.layoutIfNeeded()
            let height = placeHeader.systemLayoutSizeFitting(
                CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel
            ).height
            if abs(placeHeader.frame.height - height) > 0.5 {
                placeHeader.frame.size.height = height
                tableView.tableHeaderView = placeHeader
            }
        }
    }

    private func configurePlace() {
        authorizationTask?.cancel()
        distanceTask?.cancel()
        guard let location = selectedLocation else { return }
        var actions: [MapPlaceAction] = [.route]
        if let entry = location as? Entry {
            if phoneURL(for: entry) != nil { actions.append(.call) }
            if websiteURL(for: entry) != nil { actions.append(.website) }
            sections = entrySections(entry)
        } else if let station = location as? PetrolStationViewModel {
            sections = stationSections(station)
        } else {
            sections = []
            if location is Camera { actions.append(.camera) }
        }
        placeHeader.configure(title: location.name, subtitle: UIProperties.detailSubtitle(for: location),
                              symbol: UIProperties.symbolName(for: location), availableActions: actions)
        tableView.reloadData()
        sizeHeader()
        calculateETA(to: location.location.coordinate)
    }

    public override func numberOfSections(in tableView: UITableView) -> Int { sections.count }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows.count
    }

    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    public override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        sections[section].footer
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceInfo", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = row.title
        content.secondaryText = row.detail
        content.textProperties.numberOfLines = 0
        content.secondaryTextProperties.numberOfLines = 0
        content.image = row.symbol.flatMap { UIImage(systemName: $0) }
        content.imageProperties.tintColor = .tintColor
        content.textProperties.color = row.action == nil ? .label : .tintColor
        content.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = content
        cell.accessoryType = row.action == nil ? .none : .disclosureIndicator
        cell.selectionStyle = row.action == nil ? .none : .default
        return cell
    }

    public override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        configureSectionLabel(view, text: sections[section].title)
    }

    public override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        configureSectionLabel(view, text: sections[section].footer)
    }

    private func configureSectionLabel(_ view: UIView, text: String?) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        var content = header.defaultContentConfiguration()
        content.text = text
        content.textProperties.numberOfLines = 0
        content.textProperties.color = .secondaryLabel
        header.contentConfiguration = content
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let action = sections[indexPath.section].rows[indexPath.row].action { perform(action) }
    }

    private func calculateETA(to coordinate: CLLocationCoordinate2D) {
        let service = locationService
        authorizationTask = Task { [weak self] in
            for await _ in service.authorizationStatuses {
                guard !Task.isCancelled else { return }
                self?.calculateDistance(to: coordinate)
            }
        }
    }

    private func calculateDistance(to coordinate: CLLocationCoordinate2D) {
        distanceTask?.cancel()
        let service = locationService
        service.requestCurrentLocation()
        distanceTask = Task { [weak self] in
            do {
                for try await location in service.locations {
                    guard !Task.isCancelled else { return }
                    let request = MKDirections.Request()
                    request.source = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))
                    request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
                    request.transportType = .automobile
                    let response = try await MKDirections(request: request).calculateETA()
                    guard !Task.isCancelled else { return }
                    let minutes = Int(response.expectedTravelTime / 60)
                    self?.placeHeader.routeButton?.configuration?.subtitle = String(localized: "\(minutes) min", bundle: .module)
                    self?.sizeHeader()
                    break
                }
            } catch {
                // The route action stays available without an ETA.
            }
        }
    }

    nonisolated deinit {
        authorizationTask?.cancel()
        distanceTask?.cancel()
    }
}

private extension DetailViewController {
    func entrySections(_ entry: Entry) -> [MapPlaceSection] {
        var result = [MapPlaceSection(title: String(localized: "Address", bundle: .module), rows: [
            MapPlaceRow(title: address(street: entry.street, number: entry.houseNumber, postcode: entry.postcode, place: entry.place),
                        detail: String(localized: "Germany", bundle: .module), symbol: "mappin")
        ])]
        let days = [
            (String(localized: "Monday", bundle: .module), entry.monday),
            (String(localized: "Tuesday", bundle: .module), entry.tuesday),
            (String(localized: "Wednesday", bundle: .module), entry.wednesday),
            (String(localized: "Thursday", bundle: .module), entry.thursday),
            (String(localized: "Friday", bundle: .module), entry.friday),
            (String(localized: "Saturday", bundle: .module), entry.saturday),
            (String(localized: "Sunday", bundle: .module), entry.sunday),
            (String(localized: "Sunday and Holidays", bundle: .module), entry.other)
        ].compactMap { day, value -> MapPlaceRow? in
            guard let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
            return MapPlaceRow(title: day, detail: value)
        }
        if !days.isEmpty { result.append(MapPlaceSection(title: String(localized: "Opening hours", bundle: .module), rows: days)) }
        var contacts: [MapPlaceRow] = []
        if phoneURL(for: entry) != nil {
            contacts.append(MapPlaceRow(title: String(localized: "Phone", bundle: .module), detail: entry.phone,
                                        symbol: "phone", action: .call))
        }
        if websiteURL(for: entry) != nil {
            contacts.append(MapPlaceRow(title: String(localized: "Website", bundle: .module), detail: entry.url,
                                        symbol: "safari", action: .website))
        }
        if !contacts.isEmpty { result.append(MapPlaceSection(title: nil, rows: contacts)) }
        if !entry.tags.isEmpty {
            result.append(MapPlaceSection(title: String(localized: "Tags", bundle: .module),
                                          rows: [MapPlaceRow(title: entry.tags.joined(separator: ", "), detail: nil)]))
        }
        var information: [MapPlaceRow] = []
        if let updated = entry.updatedAt {
            information.append(MapPlaceRow(title: String(localized: "Last updated: \(updated.formatted(date: .numeric, time: .shortened))", bundle: .module), detail: nil))
        } else {
            information.append(MapPlaceRow(title: String(localized: "Last updated: not known", bundle: .module), detail: nil))
        }
        if coordinator != nil {
            information.append(MapPlaceRow(title: String(localized: "Edit information", bundle: .module), detail: nil, symbol: "pencil", action: .edit))
            information.append(MapPlaceRow(title: String(localized: "Show history", bundle: .module), detail: nil, symbol: "clock.arrow.circlepath", action: .history))
        }
        result.append(MapPlaceSection(title: nil, rows: information,
                                      footer: String(localized: "All data is entered by citizens. No guarantee can be given for correctness and timeliness.", bundle: .module)))
        return result
    }

    func stationSections(_ station: PetrolStationViewModel) -> [MapPlaceSection] {
        let price = station.price?.formatted(.currency(code: "EUR")) ?? String(localized: "n/a", bundle: .module)
        return [
            MapPlaceSection(title: String(localized: "Price", bundle: .module),
                            rows: [MapPlaceRow(title: petrolService.petrolType.name, detail: price, symbol: "fuelpump")]),
            MapPlaceSection(title: String(localized: "Address", bundle: .module), rows: [
                MapPlaceRow(title: address(street: station.street, number: station.houseNumber,
                                          postcode: station.postCode.map(String.init) ?? "", place: station.place),
                            detail: String(localized: "Germany", bundle: .module), symbol: "mappin")
            ])
        ]
    }

    func address(street: String, number: String?, postcode: String, place: String) -> String {
        [[street, number ?? ""].filter { !$0.isEmpty }.joined(separator: " "),
         [postcode, place].filter { !$0.isEmpty }.joined(separator: " ")].filter { !$0.isEmpty }.joined(separator: "\n")
    }

    func phoneURL(for entry: Entry) -> URL? {
        guard let phone = entry.phone, !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        let number = phone.filter { $0.isNumber || $0 == "+" || $0 == "*" || $0 == "#" }
        guard !number.isEmpty else { return nil }
        return URL(string: "tel://\(number)")
    }

    func websiteURL(for entry: Entry) -> URL? {
        guard let raw = entry.url?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else { return nil }
        let value = raw.contains("://") ? raw : "https://" + raw
        guard let url = URL(string: value), ["http", "https"].contains(url.scheme?.lowercased() ?? ""), url.host != nil else { return nil }
        return url
    }

    func perform(_ action: MapPlaceAction) {
        guard let location = selectedLocation else { return }
        switch action {
        case .route:
            let item = MKMapItem(placemark: MKPlacemark(coordinate: location.location.coordinate))
            item.name = location.name
            item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        case .camera:
            guard let camera = location as? Camera else { return }
            let controller = CameraViewController()
            controller.panoID = camera.id
            navigationController?.pushViewController(controller, animated: true)
        case .call:
            guard let entry = location as? Entry, let url = phoneURL(for: entry) else { return }
            UIApplication.shared.open(url)
        case .website:
            guard let entry = location as? Entry, let url = websiteURL(for: entry) else { return }
            present(SFSafariViewController(url: url), animated: true)
        case .edit:
            editEntry()
        case .history:
            showHistory()
        }
    }

    func editEntry() {
        guard let entry = selectedLocation as? Entry else { return }
        let controller = EntryOnboardingOverviewViewController(entryManager: entryManager)
        controller.overviewType = .edit(entry: entry)
        navigationController?.pushViewController(controller, animated: true)
    }

    func showHistory() {
        guard let entry = selectedLocation as? Entry, let coordinator else { return }
        let controller = EntryHistoryViewController(coordinator: coordinator)
        controller.entry = entry
        navigationController?.pushViewController(controller, animated: true)
    }
}

#Preview {
    let controller = DetailViewController()
    controller.selectedLocation = Camera.stub(withID: 1)
    return UINavigationController(rootViewController: controller)
}
