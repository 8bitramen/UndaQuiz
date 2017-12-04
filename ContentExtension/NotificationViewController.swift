import UIKit
import UserNotifications
import UserNotificationsUI
import AVFoundation

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var videoContainer: UIView!
    @IBOutlet weak var questionLabel: UILabel!

    private let iconboard = Iconboard()
    private let iconboardHeader = IconboardHeader()

    private var videoPlayer: AVPlayer?

    private var countdownSeconds = 15
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }

    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content
        customizeLabels(with: content)

        extractVideo(from: content)
        videoPlayer?.addToView(videoContainer)
        observePlayerDidPlayToEndTime()
    }

    private func customizeLabels(with content: UNNotificationContent) {
        titleLabel.text = content.userInfo["title"] as? String
        questionLabel.text = content.userInfo["question"] as? String
    }

    private func extractVideo(from content: UNNotificationContent) {
        guard let attachment = content.attachments.first else { return }

        if attachment.url.startAccessingSecurityScopedResource() {
            videoPlayer = AVPlayer(url: attachment.url)
            attachment.url.stopAccessingSecurityScopedResource()
        }
    }

    private func observePlayerDidPlayToEndTime() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(playerDidFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: videoPlayer?.currentItem)
    }

    @objc
    private func playerDidFinishPlaying() {
        showQuestion()
        startTimer()
        becomeFirstResponder()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1,
                             target: self,
                             selector: #selector(updateTimer),
                             userInfo: nil, repeats: true)
    }

    @objc
    private func updateTimer() {
        countdownSeconds -= 1
        if countdownSeconds < 0 {
            stopTimer()
        } else {
            iconboardHeader.updateTimer(countdownSeconds)
        }
    }

    private func stopTimer() {
        timer?.invalidate()
    }

    private func showQuestion() {
        questionLabel.isHidden = false
    }
}

extension NotificationViewController {

    override var inputView: UIView? {
        return iconboard
    }

    override var inputAccessoryView: UIView? {
        return iconboardHeader
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
}

extension NotificationViewController {

    private var mediaButtonHeight: CGFloat { return 125 }
    private var mediaButtonWidth: CGFloat { return 125 }
    private var mediaButtonOrigin: CGPoint {
        return CGPoint(x: videoContainer.center.x - 54.5,
                       y: videoContainer.center.y - 30.5)
    }

    var mediaPlayPauseButtonFrame: CGRect {
        return CGRect(x: mediaButtonOrigin.x, y: mediaButtonOrigin.y, width: mediaButtonWidth, height: mediaButtonHeight)
    }

    var mediaPlayPauseButtonTintColor: UIColor {
        return .white
    }

    var mediaPlayPauseButtonType: UNNotificationContentExtensionMediaPlayPauseButtonType {
        return .overlay
    }

    func mediaPlay() {
        videoPlayer?.play()
    }
}

extension AVPlayer {

    func addToView(_ view: UIView) {
        let playerLayer = AVPlayerLayer(player: self)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        view.layer.addSublayer(playerLayer)
    }
}
