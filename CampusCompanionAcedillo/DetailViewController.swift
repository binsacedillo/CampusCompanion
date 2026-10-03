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
            title = announcement.category
            messageLabel.text = """
            \(announcement.title)
            Category: \(announcement.category)
            Date: \(announcement.date)
            Priority: \(announcement.priority)
            Posted by: \(announcement.postedBy)
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
