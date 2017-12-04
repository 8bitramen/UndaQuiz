import Foundation

class FileDownloader {

    func downloadFile(from url: URL, to destinationUrl: URL, completion: @escaping (URL?) -> Void) {
        URLSession.shared.downloadTask(with: url) { (fileUrl, _, _) in
            guard let fileUrl = fileUrl else {
                completion(nil)
                return
            }

            try? FileManager.default.moveItem(at: fileUrl, to: destinationUrl)
            completion(destinationUrl)
        }
        .resume()
    }
}
