import UIKit
import MapKit
import CoreLocation

class DetailViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var campusMapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!

    private enum CampusLocation {
        static let coordinate = CLLocationCoordinate2D(latitude: 14.6255, longitude: 121.0034)
    }

    private enum LibraryLocation {
        static let coordinate = CLLocationCoordinate2D(latitude: 14.6266, longitude: 121.0048)
    }

    private let locationManager = CLLocationManager()

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

        let region = MKCoordinateRegion(
            center: CampusLocation.coordinate,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        campusMapView.setRegion(region, animated: false)

        let campusPin = MKPointAnnotation()
        campusPin.coordinate = CampusLocation.coordinate
        campusPin.title = "Campus"

        let libraryPin = MKPointAnnotation()
        libraryPin.coordinate = LibraryLocation.coordinate
        libraryPin.title = "Campus Library"
        campusMapView.addAnnotations([campusPin, libraryPin])

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            distanceLabel.text = "Location access denied."
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.first else { return }
        let campusLocation = CLLocation(
            latitude: CampusLocation.coordinate.latitude,
            longitude: CampusLocation.coordinate.longitude
        )
        let distance = currentLocation.distance(from: campusLocation)
        distanceLabel.text = String(format: "You are approximately %.0f meters from campus.", distance)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        distanceLabel.text = "Could not determine your location."
    }
}
