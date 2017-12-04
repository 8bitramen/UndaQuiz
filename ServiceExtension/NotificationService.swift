import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    private let downloader = FileDownloader()

    private var videoLocation: URL {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        var url = URL(fileURLWithPath: path)
        url = url.appendingPathComponent("question.mp4")

        return url
    }

    override func didReceive(_ request: UNNotificationRequest,
                             withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        downloadVideo()
    }

    override func serviceExtensionTimeWillExpire() {
        guard let bestAttemptContent = bestAttemptContent else { return }

        contentHandler?(bestAttemptContent)
    }

    private func downloadVideo() {
        guard let urlString = bestAttemptContent?.userInfo["video-url"] as? String,
            let url = URL(string: urlString) else { return }

        downloader.downloadFile(from: url, to: videoLocation, completion: attachVideo)
    }

    private func attachVideo(videoLocation: URL?) {
        guard let videoLocation = videoLocation,
            let bestAttemptContent = bestAttemptContent else { return }

        if let attachment = try? UNNotificationAttachment(identifier: "video",
                                                          url: videoLocation) {
            bestAttemptContent.attachments = [ attachment ]
            self.contentHandler?(bestAttemptContent)
        }
    }
}
