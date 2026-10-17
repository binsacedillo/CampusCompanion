import UIKit
import CoreData

class AnnouncementsViewController: UITableViewController {

    private var announcements: [CampusAnnouncement] = []
    private var selectedAnnouncement: CampusAnnouncement?

    private var context: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Campus Announcements"
        seedInitialAnnouncementsIfNeeded()
        loadAnnouncements()
    }

    private func seedInitialAnnouncementsIfNeeded() {
        let request: NSFetchRequest<CampusAnnouncement> = CampusAnnouncement.fetchRequest()
        let existingCount = (try? context.count(for: request)) ?? 0
        guard existingCount == 0 else { return }

        let seedAnnouncements = [
            ("Enrollment Period Extended", "August 3, 2026", "Registrar"),
            ("Library Schedule Update", "August 5, 2026", "Library"),
            ("Campus Sports Festival", "August 10, 2026", "Student Affairs"),
            ("Scholarship Applications Open", "August 12, 2026", "Scholarships"),
            ("System Maintenance Notice", "August 15, 2026", "IT Services"),
            ("University Foundation Day", "August 20, 2026", "Campus Events")
        ]

        for seed in seedAnnouncements {
            let announcement = CampusAnnouncement(context: context)
            announcement.title = seed.0
            announcement.date = seed.1
            announcement.category = seed.2
        }

        try? context.save()
    }

    private func loadAnnouncements() {
        let request: NSFetchRequest<CampusAnnouncement> = CampusAnnouncement.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        announcements = (try? context.fetch(request)) ?? []
        tableView.reloadData()
    }

    @IBAction private func addAnnouncementTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(
            title: "New Announcement",
            message: "Enter a title and category.",
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.placeholder = "Title"
        }
        alert.addTextField { textField in
            textField.placeholder = "Category"
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak alert] _ in
            guard let self,
                  let titleText = alert?.textFields?[0].text, !titleText.isEmpty,
                  let categoryText = alert?.textFields?[1].text, !categoryText.isEmpty else {
                return
            }

            let newAnnouncement = CampusAnnouncement(context: self.context)
            newAnnouncement.title = titleText
            newAnnouncement.date = DateFormatter.localizedString(
                from: Date(),
                dateStyle: .long,
                timeStyle: .none
            )
            newAnnouncement.category = categoryText
            try? self.context.save()
            self.loadAnnouncements()
        }

        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return announcements.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "AnnouncementCell",
            for: indexPath
        ) as? AnnouncementCell else {
            return UITableViewCell()
        }
        cell.configure(with: announcements[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedAnnouncement = announcements[indexPath.row]
        performSegue(withIdentifier: "ShowAnnouncementDetailSegue", sender: self)
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        let announcement = announcements[indexPath.row]
        context.delete(announcement)
        try? context.save()
        announcements.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowAnnouncementDetailSegue",
              let destination = segue.destination as? DetailViewController,
              let announcement = selectedAnnouncement else { return }
        destination.announcement = announcement
    }
}
