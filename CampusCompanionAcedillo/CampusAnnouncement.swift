import Foundation

struct CampusAnnouncement {
    let title: String
    let date: String
    let category: String
    let priority: String
    let postedBy: String
}

extension CampusAnnouncement {
    static let sampleAnnouncements: [CampusAnnouncement] = [
        CampusAnnouncement(
            title: "Enrollment Period Extended",
            date: "August 3, 2026",
            category: "Registrar",
            priority: "Normal",
            postedBy: "Registrar"
        ),
        CampusAnnouncement(
            title: "Library Schedule Update",
            date: "August 5, 2026",
            category: "Library",
            priority: "Normal",
            postedBy: "University Library"
        ),
        CampusAnnouncement(
            title: "Campus Sports Festival",
            date: "August 10, 2026",
            category: "Student Affairs",
            priority: "Normal",
            postedBy: "Student Affairs"
        ),
        CampusAnnouncement(
            title: "Scholarship Applications Open",
            date: "August 12, 2026",
            category: "Scholarships",
            priority: "Normal",
            postedBy: "Scholarship Office"
        ),
        CampusAnnouncement(
            title: "System Maintenance Notice",
            date: "August 15, 2026",
            category: "IT Services",
            priority: "Urgent",
            postedBy: "IT Services"
        ),
        CampusAnnouncement(
            title: "University Foundation Day",
            date: "August 20, 2026",
            category: "Campus Events",
            priority: "Normal",
            postedBy: "Events Office"
        )
    ]
}
