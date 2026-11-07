import UIKit
import PhotosUI

private enum DefaultsKey {
    static let studentName = "studentName"
    static let notificationsEnabled = "notificationsEnabled"
    static let selectedRoleIndex = "selectedRoleIndex"
}

class ViewController: UIViewController, PHPickerViewControllerDelegate {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var removePhotoButton: UIButton!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var notifySwitch: UISwitch!
    @IBOutlet private weak var roleSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var eventDatePicker: UIDatePicker!
    @IBOutlet private weak var guestStepper: UIStepper!

    private var profilePhotoURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first?.appendingPathComponent("profilePhoto.jpg")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Campus Companion"
        nameTextField.text = UserDefaults.standard.string(forKey: DefaultsKey.studentName) ?? ""
        notifySwitch.isOn = UserDefaults.standard.bool(forKey: DefaultsKey.notificationsEnabled)
        roleSegmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(
            forKey: DefaultsKey.selectedRoleIndex
        )
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        loadProfileImageFromDisk()
    }

    @IBAction private func getStartedTapped(_ sender: UIButton) {
        subtitleLabel.text = "Let's get started!"
    }

    @IBAction private func changePhotoTapped(_ sender: UIButton) {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    @IBAction private func removePhotoTapped(_ sender: UIButton) {
        guard let profilePhotoURL else { return }
        do {
            if FileManager.default.fileExists(atPath: profilePhotoURL.path) {
                try FileManager.default.removeItem(at: profilePhotoURL)
            }
            profileImageView.image = UIImage(systemName: "person.crop.circle")
            removePhotoButton.isEnabled = false
        } catch {
            print("Could not remove profile photo: \(error.localizedDescription)")
        }
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                guard let self else { return }
                self.profileImageView.image = image
                self.saveProfileImageToDisk(image)
            }
        }
    }

    private func saveProfileImageToDisk(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.8),
              let profilePhotoURL else { return }
        do {
            try data.write(to: profilePhotoURL, options: .atomic)
            removePhotoButton.isEnabled = true
        } catch {
            print("Could not save profile photo: \(error.localizedDescription)")
        }
    }

    private func loadProfileImageFromDisk() {
        profileImageView.image = UIImage(systemName: "person.crop.circle")
        guard let profilePhotoURL,
              let image = UIImage(contentsOfFile: profilePhotoURL.path) else {
            removePhotoButton.isEnabled = false
            return
        }
        profileImageView.image = image
        removePhotoButton.isEnabled = true
    }

    @IBAction func exploreButtonTapped(_ sender: UIButton) {
        nameTextField.resignFirstResponder()
        let enteredName = nameTextField.text ?? ""
        UserDefaults.standard.set(enteredName, forKey: DefaultsKey.studentName)
        UserDefaults.standard.set(notifySwitch.isOn, forKey: DefaultsKey.notificationsEnabled)
        UserDefaults.standard.set(
            roleSegmentedControl.selectedSegmentIndex,
            forKey: DefaultsKey.selectedRoleIndex
        )
        performSegue(withIdentifier: "ShowDetailSegue", sender: self)
    }

    @IBAction private func resetPreferencesTapped(_ sender: UIBarButtonItem) {
        UserDefaults.standard.removeObject(forKey: DefaultsKey.studentName)
        UserDefaults.standard.removeObject(forKey: DefaultsKey.notificationsEnabled)
        UserDefaults.standard.removeObject(forKey: DefaultsKey.selectedRoleIndex)

        nameTextField.text = ""
        notifySwitch.isOn = false
        roleSegmentedControl.selectedSegmentIndex = 0
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowDetailSegue",
              let destination = segue.destination as? DetailViewController else {
            return
        }

        let enteredName = nameTextField.text ?? ""
        destination.studentName = enteredName.isEmpty ? "Student" : enteredName
        destination.notificationsEnabled = notifySwitch.isOn
        destination.selectedRole = roleSegmentedControl.selectedSegmentIndex == 0
            ? "Student" : "Faculty"
        destination.preferredEventDate = eventDatePicker.date
        destination.numberOfGuests = Int(guestStepper.value)
    }
}
