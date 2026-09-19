import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var messageLabel: UILabel!

    var studentName: String = ""
    var notificationsEnabled: Bool = false
    var selectedRole: String = ""
    var preferredEventDate: Date = Date()
    var numberOfGuests: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Campus Events"
        let notificationStatus = notificationsEnabled ? "on" : "off"
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let eventDate = dateFormatter.string(from: preferredEventDate)
        messageLabel.text = "Welcome, \(studentName)! (\(selectedRole))\nNotifications: \(notificationStatus).\nEvent: \(eventDate)\nGuests: \(numberOfGuests)"
    }
}
