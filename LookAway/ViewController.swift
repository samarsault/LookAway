import Cocoa

// Handle Skip
protocol VCDelegate {
    func onSkip(_ sender: NSButton)
}

class ViewController: NSViewController {
    @IBOutlet weak var button: NSButton!
    var delegate: VCDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func skipButtonClick(_ sender: NSButton) {
        delegate.onSkip(sender)
    }
    
}

