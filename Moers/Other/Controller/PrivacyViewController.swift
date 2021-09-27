//
//  PrivacyViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 15.08.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMUI

// swiftlint:disable line_length
class PrivacyViewController: UIViewController {

    lazy var textView: UITextView = {
        
        let textView = UITextView()
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isSelectable = true
        textView.isEditable = false
        textView.dataDetectorTypes = .all
        
        return textView
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = String.localized("PrivacyPolicy")
        
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
    Lennart Fischer hat die Mein Moers App als kostenlose App erstellt. Dieser Dienst wird von Lennart Fischer kostenlos zur Verfügung gestellt und ist zur Nutzung in der vorliegenden Form bestimmt.

    Diese Informationsseite dient dazu, Nutzer der Applikation über meine Richtlinien bei der Erfassung, Nutzung und Offenlegung persönlicher Daten zu informieren, wenn sich jemand für die Nutzung meines Dienstes entschieden hat.

    Wenn Sie sich dafür entscheiden, meinen Service zu nutzen, stimmen Sie der Sammlung und Nutzung von Informationen im Zusammenhang mit diesen Richtlinien zu. Die von mir gesammelten persönlichen Daten werden für die Bereitstellung und Verbesserung des Dienstes verwendet. Ich werde Ihre Daten nicht verwenden oder an Dritte weitergeben, außer wie in dieser Datenschutzerklärung beschrieben.

    Die in dieser Datenschutzerklärung verwendeten Begriffe haben die gleiche Bedeutung wie in unseren Allgemeinen Geschäftsbedingungen, die bei Mein Moers zugänglich sind, sofern in dieser Datenschutzerklärung nicht anders definiert.

    Sammlung und Verwendung von Daten

    Für eine bessere Erfahrung bei der Nutzung unseres Dienstes kann ich von Ihnen verlangen, dass Sie uns bestimmte personenbezogene Daten zur Verfügung stellen, einschließlich, aber nicht beschränkt auf den Standort. Die von mir angeforderten Informationen werden auf Ihrem Gerät gespeichert und von mir in keiner Weise erfasst.

    Die App nutzt Dienste von Drittanbietern, die möglicherweise Informationen sammeln, um Sie zu identifizieren.

    Link zu den Datenschutzbestimmungen von Drittanbietern, die von der App verwendet werden:
    –    Firebase Analytics (https://firebase.google.com/policies/analytics)
    –    Fabric (https://fabric.io/privacy)
    –    Crashlytics (http://try.crashlytics.com/terms/privacy-policy.pdf)

    Protokolldaten

    Ich möchte Sie darüber informieren, dass ich im Falle eines Fehlers in der Anwendung Daten und Informationen (über Produkte von Drittanbietern) auf Ihrem Telefon Protokolldaten sammle, wann immer Sie meinen Service nutzen. Diese Protokolldaten können Informationen wie die IP-Adresse Ihres Geräts, den Gerätenamen, die Version des Betriebssystems, die Konfiguration der Anwendung bei der Nutzung meines Dienstes, die Uhrzeit und das Datum Ihrer Nutzung des Dienstes und andere Statistiken enthalten.

    Dienstleister

    Ich kann aus folgenden Gründen Drittfirmen und Einzelpersonen beauftragen:
    Um unseren Service zu verbessern;
    Den Service in unserem Sinne zu erbringen;
    um servicebezogene Dienstleistungen zu erbringen; oder
    Um uns bei der Analyse der Nutzung unseres Dienstes zu unterstützen.
    
    Ich möchte die Nutzer dieses Dienstes darüber informieren, dass diese Dritten Zugang zu Ihren persönlichen Daten haben. Der Grund dafür ist, die ihnen übertragenen Aufgaben in unserem Namen zu erfüllen. Sie sind jedoch verpflichtet, die Informationen nicht weiterzugeben oder für andere Zwecke zu verwenden.

    Sicherheit

    Ich schätze Ihr Vertrauen, dass Sie uns Ihre persönlichen Daten zur Verfügung stellen, daher sind wir bestrebt, diese zu schützen. Aber denken Sie daran, dass keine Methode der Übertragung über das Internet, oder Methode der elektronischen Speicherung ist 100% sicher und zuverlässig ist, und ich keine Garantie für absolute Sicherheit geben kann.

    Links zu externen Seiten

    Dieser Service kann Links zu anderen Websites enthalten. Wenn Sie auf einen Link eines Drittanbieters klicken, werden Sie auf diese Seite weitergeleitet. Bitte beachten Sie, dass diese externen Seiten nicht von mir betrieben werden. Daher empfehle ich Ihnen dringend, die Datenschutzerklärung dieser Websites zu lesen. Ich habe keine Kontrolle über die Inhalte, Datenschutzrichtlinien oder Praktiken von Websites oder Diensten Dritter und übernehme keine Verantwortung dafür.

    Datenschutzhinweis für Kinder
    
    Diese Dienste richten sich nicht an Personen unter 13 Jahren und ich sammle nicht wissentlich personenbezogene Daten von Kindern unter 13 Jahren. Sollte ich feststellen, dass mir ein Kind unter 13 Jahren persönliche Daten zur Verfügung gestellt hat, lösche ich diese sofort von unseren Servern. Wenn Sie ein Elternteil oder Erziehungsberechtigter sind und Sie wissen, dass Ihr Kind uns persönliche Daten zur Verfügung gestellt hat, kontaktieren Sie mich bitte, damit ich die notwendigen Maßnahmen ergreifen kann.
    
    Änderungen dieser Datenschutzerklärung
    
    Ich kann unsere Datenschutzerklärung von Zeit zu Zeit aktualisieren. Wir empfehlen Ihnen daher, diese Seite regelmäßig auf Änderungen zu überprüfen. Ich werde Sie über alle Änderungen informieren, indem ich die neue Datenschutzerklärung auf dieser Seite veröffentliche. Diese Änderungen werden sofort nach ihrer Veröffentlichung auf dieser Seite wirksam.
    
    Kontaktieren Sie mich
    
    Wenn Sie Fragen oder Anregungen zu meiner Datenschutzerklärung haben, zögern Sie nicht, mich zu kontaktieren.

    Lennart Fischer
    info@lambdadigamma.com
    """
    
}

extension PrivacyViewController: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.view.backgroundColor = UIColor.systemBackground // theme.backgroundColor
        self.textView.backgroundColor = UIColor.systemBackground // theme.backgroundColor
        self.textView.textColor = UIColor.label // theme.color
    }
    
}
