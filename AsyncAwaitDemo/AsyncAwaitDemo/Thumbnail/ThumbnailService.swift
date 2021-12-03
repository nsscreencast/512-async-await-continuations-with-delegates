import UIKit
import AVFoundation

struct ThumbnailService {
    struct InvalidImage: Error { }
    struct UnexpectedResponse: Error { }
    
    func downloadThumbnail(_ url: URL) async throws -> UIImage {
        let session = URLSession.shared
        
        await Task.sleep(NSEC_PER_SEC)
        
        let (data, response) = try await session.data(from: url, delegate: nil)
        
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw UnexpectedResponse()
        }
        
        guard let image = UIImage(data: data) else {
            throw InvalidImage()
        }
        
        let thumbSize = CGSize(width: 600, height: 600)
        let thumbRect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: .zero, size: thumbSize))
        
        return try await withCheckedThrowingContinuation { continuation in
            image.prepareThumbnail(of: thumbRect.size) { image in
                guard let image = image else {
                    continuation.resume(throwing: InvalidImage())
                    return
                }
                continuation.resume(returning: image)
            }
        }
    }
}
