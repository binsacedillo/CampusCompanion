import UIKit

class ViewController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Campus Companion"
    }

    @IBAction private func getStartedTapped(_ sender: UIButton) {
        subtitleLabel.text = "Let's get started!"
    }
}
