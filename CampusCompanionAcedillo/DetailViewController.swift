import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var messageLabel: UILabel!

    var studentName: String = ""
    var notificationsEnabled: Bool = false
    var selectedRole: String = ""
    var preferredEventDate: Date = Date()
    var numberOfGuests: Int = 1
    var announcement: CampusAnnouncement?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let announcement = announcement {
            title = announcement.category ?? "Announcement"
            messageLabel.text = """
            \(announcement.title ?? "Untitled")
            Category: \(announcement.category ?? "General")
            Date: \(announcement.date ?? "No date")
            Location: \(announcement.location ?? "No location")
            Priority: \(announcement.priority ?? "Normal")
            """
        } else {
            title = "Campus Events"
            let notificationStatus = notificationsEnabled ? "on" : "off"
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            let eventDate = dateFormatter.string(from: preferredEventDate)
            messageLabel.text = "Welcome, \(studentName)! (\(selectedRole))\nNotifications: \(notificationStatus).\nEvent: \(eventDate)\nGuests: \(numberOfGuests)"
        }
    }
}
