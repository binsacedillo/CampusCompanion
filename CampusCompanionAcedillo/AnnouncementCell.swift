import UIKit

class AnnouncementCell: UITableViewCell {

    @IBOutlet weak var categoryIconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    func configure(with announcement: CampusAnnouncement) {
        titleLabel.text = announcement.title ?? "Untitled"
        let category = announcement.category ?? "General"
        let date = announcement.date ?? "No date"
        let location = announcement.location ?? "No location"
        let priority = announcement.priority ?? "Normal"
        dateLabel.text = "\(category) • \(date)\n\(location) • \(priority) priority"
        categoryIconImageView.image = UIImage(systemName: "megaphone.fill")
        categoryIconImageView.tintColor = .systemBlue
    }
}
