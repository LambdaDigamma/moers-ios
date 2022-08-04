//
//  TandCViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 15.08.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Core
import UIKit
import Gestalt
import MMUI

// swiftlint:disable line_length
class TandCViewController: UIViewController {

    lazy var textView: UITextView = {
        
        let textView = UITextView()
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isSelectable = false
        textView.isEditable = false
        
        return textView
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = String.localized("TandC")
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }

    private func setupUI() {
        
        self.view.addSubview(textView)
        
        self.textView.text = text
        
    }
    
    private func setupConstraints() {
        
        let constraints = [textView.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 8),
                           textView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8),
                           textView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -8),
                           textView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor, constant: -8)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    let text =
    """
    Durch das Herunterladen oder Verwenden der App gelten diese Bedingungen automatisch für Sie - Sie sollten sich daher vergewissern, dass Sie sie vor der Verwendung der App sorgfältig lesen. Sie sind nicht berechtigt, die App, Teile der App oder unsere Marken in irgendeiner Weise zu kopieren oder zu verändern. Sie dürfen nicht versuchen, den Quellcode der Anwendung zu extrahieren, und Sie sollten auch nicht versuchen, die Anwendung in andere Sprachen zu übersetzen oder abgeleitete Versionen zu erstellen. Die App selbst und alle damit verbundenen Marken-, Urheber-, Datenbank- und sonstigen Schutzrechte gehören weiterhin Lennart Fischer.
    
    Lennart Fischer setzt sich dafür ein, dass die App so nützlich und effizient wie möglich ist. Aus diesem Grund behalten wir uns das Recht vor, jederzeit und aus beliebigem Grund Änderungen an der App vorzunehmen.

    Die App Mein Moers speichert und verarbeitet personenbezogene Daten, die Sie uns zur Verfügung gestellt haben, um meinen Service zu ermöglichen. Es liegt in Ihrer Verantwortung, Ihr Telefon und den Zugriff auf die App sicher zu halten. Wir empfehlen Ihnen daher, Ihr Telefon nicht Verfahren wie „Jailbreak“ oder „Root“ zu unterziehen, da dies der Prozess der Beseitigung von Software-Beschränkungen und -Einschränkungen ist, die durch das offizielle Betriebssystem Ihres Geräts auferlegt werden. Es könnte Ihr Telefon anfällig für Malware/Viren/Bösartige Programme machen, die Sicherheitsfunktionen Ihres Telefons beeinträchtigen und dazu führen, dass die Mein Moers App nicht richtig oder überhaupt nicht funktioniert.

    Sie sollten sich bewusst sein, dass es bestimmte Dinge gibt, für die Lennart Fischer keine Verantwortung übernimmt. Bestimmte Funktionen der App erfordern eine aktive Internetverbindung. Die Verbindung kann Wi-Fi sein oder von Ihrem Mobilfunkanbieter bereitgestellt werden, aber Lennart Fischer kann keine Verantwortung dafür übernehmen, dass die Anwendung nicht mit voller Funktionalität funktioniert, wenn Sie keinen Zugang zu Wi-Fi haben und Sie keine Daten mehr haben.

    Wenn Sie die App außerhalb eines Bereichs mit Wi-Fi nutzen, sollten Sie daran denken, dass die Bedingungen der Vereinbarung mit Ihrem Mobilfunkanbieter weiterhin gelten. Dies kann dazu führen, dass Ihnen von Ihrem Mobilfunkanbieter die Kosten für die Dauer der Verbindung während des Zugriffs auf die App oder andere Gebühren Dritter in Rechnung gestellt werden. Mit der Nutzung der App übernehmen Sie die Verantwortung für solche Gebühren, einschließlich Roaming-Datengebühren, wenn Sie die App außerhalb Ihres Heimatlandes (d.h. Region oder Land) nutzen, ohne das Datenroaming abzuschalten. Wenn Sie nicht der Rechnungszahler für das Gerät sind, auf dem Sie die App nutzen, beachten Sie bitte, dass wir davon ausgehen, dass Sie die Erlaubnis des Rechnungszahlers zur Nutzung der App erhalten haben.

    In diesem Sinne kann Lennart Fischer nicht immer die Verantwortung für die Art und Weise übernehmen, wie Sie die App nutzen, d.h. Sie müssen sicherstellen, dass Ihr Gerät geladen bleibt - wenn der Akku leer ist und Sie es nicht einschalten können, um den Service in Anspruch zu nehmen, kann Lennart Fischer keine Verantwortung übernehmen.

    Im Hinblick auf die Zuständigkeit von Lennart Fischer für Ihre Nutzung der App ist es wichtig zu bedenken, dass wir uns zwar bemühen, diese jederzeit zu aktualisieren und zu korrigieren, uns aber auf Informationen Dritter verlassen, damit wir sie Ihnen zur Verfügung stellen können. Lennart Fischer übernimmt keine Haftung für direkte oder indirekte Schäden, die Ihnen dadurch entstehen, dass Sie sich vollständig auf diese Funktionalität der App verlassen.

    Irgendwann möchten wir vielleicht die App aktualisieren. Die App ist derzeit auf iOS verfügbar - die Anforderungen für beide Systeme (und für alle weiteren Systeme, auf die wir die Verfügbarkeit der App erweitern wollen) können sich ändern, und Sie müssen die Updates herunterladen, wenn Sie die App weiterhin verwenden möchten. Lennart Fischer verspricht nicht, die App immer so zu aktualisieren, dass sie für Sie relevant ist und/oder mit der iOS-Version, die Sie auf Ihrem Gerät installiert haben, funktioniert. Wir können auch die Bereitstellung der Anwendung einstellen und die Nutzung der Anwendung jederzeit ohne Kündigung beenden. Sofern wir Ihnen nichts anderes mitteilen, enden (a) die Ihnen in diesen Bedingungen gewährten Rechte und Lizenzen; (b) Sie müssen die Nutzung der App einstellen und (falls erforderlich) sie von Ihrem Gerät löschen.

    Änderungen dieser Geschäftsbedingungen

    Ich kann unsere Allgemeinen Geschäftsbedingungen von Zeit zu Zeit aktualisieren. Wir empfehlen Ihnen daher, diese Seite regelmäßig auf Änderungen zu überprüfen. Ich werde Sie über alle Änderungen informieren, indem ich die neuen Allgemeinen Geschäftsbedingungen auf dieser Seite veröffentliche. Diese Änderungen werden sofort nach ihrer Veröffentlichung auf dieser Seite wirksam.
    """
    
}

extension TandCViewController: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.view.backgroundColor = UIColor.systemBackground // theme.backgroundColor
        self.textView.backgroundColor = UIColor.systemBackground // theme.backgroundColor
        self.textView.textColor = UIColor.label // theme.color
    }
    
}
