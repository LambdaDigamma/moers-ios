import CoreLocation
@testable import FuelFeature

final class RecordingPetrolService: PetrolService {
    
    var petrolType: PetrolType
    var lastLoadLocation: CLLocation?
    
    private(set) var requestedCoordinates: [CLLocationCoordinate2D] = []
    private let stations: [PetrolStation]
    
    init(
        petrolType: PetrolType = .diesel,
        stations: [PetrolStation]
    ) {
        self.petrolType = petrolType
        self.stations = stations
    }
    
    func getPetrolStations(
        coordinate: CLLocationCoordinate2D,
        radius: Double,
        sorting: PetrolSorting,
        type: PetrolType,
        shouldReload: Bool
    ) async throws -> [PetrolStation] {
        requestedCoordinates.append(coordinate)
        lastLoadLocation = CLLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        return stations
    }
    
    func getPetrolStation(id: PetrolStation.ID) async throws -> PetrolStation {
        stations.first ?? PetrolStation.stub(withID: id)
    }
    
}
