//
//  MailController.swift
//  Strafen
//
//  Created by Steven on 10.07.20.
//

import SwiftUI
import MessageUI

/// Controller to send mail
struct MailController: UIViewControllerRepresentable {
    
    /// Mail controller
    let controller = MFMailController()
    
    /// Shared instance for singelton
    static let shared = MailController()
    
    /// Private init for singleton
    private init() {}
    
    /// Send code email to given email
    func sendMail(to email: String, code: String) {
        controller.sendMail(to: email, code: code)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailController>) -> MFMailController {
        controller
    }
    
    func updateUIViewController(_ uiViewController: MFMailController, context: UIViewControllerRepresentableContext<MailController>) {}
}

class MFMailController: UIViewController, MFMailComposeViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func sendMail(to email: String, code: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([email])
            mail.setSubject("") // TODO
            mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
            present(mail, animated: true)
        } else {
            let alert = UIAlertController(title: "Senden nicht möglich", message: "Es konnte kein Email gesendet werden.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Verstanden", style: .destructive))
            present(alert, animated: true)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
