//
//  ViewController.swift
//  FaceChat
//
//  Created by user on 2021/06/08.
//

import Cocoa
import GroupActivities
import Combine

struct ChatActivity: GroupActivity {
    var text: String? = "first"
    
    var metadata: GroupActivityMetadata {
        get async {
            var metadata = GroupActivityMetadata()
            metadata.type = .watchTogether
            metadata.title = "GroupActivity Now"
            metadata.fallbackURL = URL(string: "https://rinsuki.net/")
            return metadata
        }
    }
}

class ViewController: NSViewController {
    var session: GroupSession<ChatActivity>?
    var subscriptions = Set<AnyCancellable>()
    @IBOutlet weak var myField: NSTextField!
    @IBOutlet var everyoneView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        async {
            for await session in ChatActivity.sessions() {
                self.session = session
                subscriptions.removeAll()
                session.$state.sink { [weak self] state in
                    print(state)
                    if case .invalidated = state {
                        self?.session = nil
                        self?.subscriptions.removeAll()
                    }
                }.store(in: &subscriptions)
                session.join()
                session.$activity.sink { [weak self] activity in
                    self?.everyoneView.string = activity.text ?? "null"
                }.store(in: &subscriptions)
            }
        }
    }

    @IBAction func pushToEveryone(_ sender: Any) {
        let aaa = myField.stringValue
        let activity = ChatActivity(text: aaa)
        async {
            switch await activity.prepareForActivation() {
            case .activationPreferred:
                activity.activate()
            default:
                let alert = NSAlert()
                alert.messageText = "denied"
                alert.runModal()
            }
        }
    }
    
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

