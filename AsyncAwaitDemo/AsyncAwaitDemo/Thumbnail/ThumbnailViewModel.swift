import SwiftUI

@MainActor
final class ThumbnailViewModel: ObservableObject {
    @Published
    var output: [String] = []
    
    @Published
    var image: UIImage?
    
    @Published
    var running = false
    
    func run() async {
        running = true
        outputMessage("Running...")
        
        do {
            let url = URL(string: "https://nsscreencast-uploads.imgix.net/production/series/image/57/Async_Series_Artwork.png?w=600&dpr=2")!
            
            self.image = try await ThumbnailService().downloadThumbnail(url)
            
        } catch {
            outputMessage("Ooops, got an error!")
        }
        
        outputMessage("Done!")
        running = false
    }
    
    private var lock = NSLock()
    private func outputMessage(_ string: String) {
        lock.lock()
        defer { lock.unlock() }
        output.append(string)
    }
}
