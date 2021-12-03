import SwiftUI
import CoreLocation

@MainActor
final class LocationViewModel: ObservableObject {
    let locationManager = LocationManager()
    
    @Published var location: CLLocation?
    
    func getLocation() {
        Task {
            if await locationManager.verifyPermission() == .authorizedWhenInUse {
                location = try await locationManager.location()
            }
        }
    }
}

struct LocationView: View {
    @ObservedObject var viewModel = LocationViewModel()
    
    var body: some View {
        VStack(spacing: 40) {
            
            if let loc = viewModel.location {
                Text("Your location is: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
            }
            
            Button(action: {
                viewModel.getLocation()
            }) {
                Label("Get Location", systemImage: "location")
            }
            .buttonStyle(BorderedButtonStyle())
        }
    }
}


#if DEBUG
struct LocationView_Preview: PreviewProvider {
    static var previews: some View {
        ZStack {
            LocationView()
        }
        .edgesIgnoringSafeArea(.all)
    }
}
#endif

