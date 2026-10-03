import UIKit

class AnnouncementCell: UITableViewCell {

    @IBOutlet weak var categoryIconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    func configure(with announcement: CampusAnnouncement) {
        titleLabel.text = announcement.title
        dateLabel.text = "\(announcement.postedBy) • \(announcement.priority)"

        let isUrgent = announcement.priority == "Urgent"
        categoryIconImageView.image = UIImage(
            systemName: isUrgent ? "exclamationmark.circle.fill" : "megaphone.fill"
        )
        categoryIconImageView.tintColor = isUrgent ? .systemRed : .systemBlue
        titleLabel.textColor = isUrgent ? .systemRed : .label
        dateLabel.textColor = isUrgent ? .systemRed : .secondaryLabel
        contentView.backgroundColor = isUrgent
            ? UIColor.systemRed.withAlphaComponent(0.12)
            : .systemBackground
    }
}
