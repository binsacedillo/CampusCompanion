import UIKit
import CoreData

private enum RemoteEndpoint {
    static let announcements = URL(
        string: "https://raw.githubusercontent.com/binsacedillo/CampusCompanion/main/announcements.json"
    )!
}

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

    @IBAction private func refreshTapped(_ sender: UIBarButtonItem) {
        fetchAnnouncementsFromServer()
    }

    private func fetchAnnouncementsFromServer() {
        let task = URLSession.shared.dataTask(with: RemoteEndpoint.announcements) {
            [weak self] data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Unexpected server response.")
                return
            }

            guard let self, let data = data else { return }
            print("Reached network handler with \(data.count) bytes.")
            if let rawJSON = String(data: data, encoding: .utf8) {
                print(rawJSON)
            }

            do {
                let decodedAnnouncements = try JSONDecoder().decode(
                    [AnnouncementDTO].self,
                    from: data
                )
                DispatchQueue.main.async {
                    self.replaceAnnouncements(with: decodedAnnouncements)
                    self.showNetworkConfirmationAlert(byteCount: data.count)
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }
        task.resume()
    }

    private func replaceAnnouncements(with dtos: [AnnouncementDTO]) {
        let request: NSFetchRequest<CampusAnnouncement> = CampusAnnouncement.fetchRequest()
        let existing = (try? context.fetch(request)) ?? []
        existing.forEach(context.delete)

        for dto in dtos {
            let announcement = CampusAnnouncement(context: context)
            announcement.title = dto.title
            announcement.date = dto.date
            announcement.category = dto.category
            announcement.location = dto.location
            announcement.priority = dto.priority
        }

        try? context.save()
        loadAnnouncements()
    }

    private func showNetworkConfirmationAlert(byteCount: Int) {
        let alert = UIAlertController(
            title: "Server Reached",
            message: "Received \(byteCount) bytes from the announcements endpoint.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func seedInitialAnnouncementsIfNeeded() {
        let request: NSFetchRequest<CampusAnnouncement> = CampusAnnouncement.fetchRequest()
        let existing = (try? context.fetch(request)) ?? []
        if !existing.isEmpty {
            for announcement in existing {
                if announcement.location?.isEmpty != false { announcement.location = "Campus" }
                if announcement.priority?.isEmpty != false { announcement.priority = "Normal" }
            }
            try? context.save()
            return
        }

        let seedAnnouncements = [
            ("Enrollment Period Extended", "August 3, 2026", "Registrar", "Registrar Office", "High"),
            ("Library Schedule Update", "August 5, 2026", "Library", "Main Library", "Normal"),
            ("Campus Sports Festival", "August 10, 2026", "Student Affairs", "Campus Gym", "High"),
            ("Scholarship Applications Open", "August 12, 2026", "Scholarships", "Student Center", "Normal"),
            ("System Maintenance Notice", "August 15, 2026", "IT Services", "Online", "High"),
            ("University Foundation Day", "August 20, 2026", "Campus Events", "Main Grounds", "Normal")
        ]

        for seed in seedAnnouncements {
            let announcement = CampusAnnouncement(context: context)
            announcement.title = seed.0
            announcement.date = seed.1
            announcement.category = seed.2
            announcement.location = seed.3
            announcement.priority = seed.4
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
