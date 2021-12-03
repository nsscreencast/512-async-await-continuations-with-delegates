import Foundation
import CoreLocation

final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let coreLocation: CLLocationManager
    
    override init() {
        coreLocation = CLLocationManager()
        super.init()
        coreLocation.delegate = self
    }
    
    private var permissionContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    
    func verifyPermission() async -> CLAuthorizationStatus {
        if coreLocation.authorizationStatus == .authorizedWhenInUse {
            return coreLocation.authorizationStatus
        }
        
        return await withCheckedContinuation { continuation in
            permissionContinuation = continuation
            coreLocation.requestWhenInUseAuthorization()
        }
    }
    
    func location() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            coreLocation.startUpdatingLocation()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        permissionContinuation?.resume(returning: manager.authorizationStatus)
        permissionContinuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        locationContinuation?.resume(returning: location)
        locationContinuation = nil
    }
}
