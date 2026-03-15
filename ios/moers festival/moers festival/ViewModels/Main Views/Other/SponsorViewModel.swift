//
//  SponsorViewModel.swift
//  moers festival
//
//  Created by Lennart Fischer on 17.04.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import Foundation

class SponsorViewModel {
    
    public let sponsors: [String: [Sponsor]]
    
    init() {
        self.sponsors = sponsors2018
    }
    
    let sponsors2018 = [
        "Die Hauptförderer": [
            Sponsor(name: "Stadt Moers",
                    image: #imageLiteral(resourceName: "moers"),
                    url: URL(string: "http://moers.de/")),
            Sponsor(name: "Die Bauftragte der Bundesregierung für Kultur und Medien",
                    image: #imageLiteral(resourceName: "bmk"),
                    url: nil),
            Sponsor(name: "Ministerium für Familie, Kinder, Jugend, Kultur und Sport des Landes Nordrhein-Westfalen",
                    image: #imageLiteral(resourceName: "ministerium_nrw"),
                    url: URL(string: "http://nrw.de/")),
            Sponsor(name: "Kunst Stiftung NRW",
                    image: #imageLiteral(resourceName: "kunststiftung_nrw"),
                    url: URL(string: "http://kunststiftungnrw.de/")),
            Sponsor(name: "Kulturstiftung Sparkasse am Niederrhein",
                    image: #imageLiteral(resourceName: "kulturstiftung_sparkasse"),
                    url: URL(string: "http://sparkasse-am-niederrhein.de/")),
            Sponsor(name: "WDR 3",
                    image: #imageLiteral(resourceName: "WDR3"),
                    url: URL(string: "http://www.wdr3.de/")),
            Sponsor(name: "arte concert",
                    image: #imageLiteral(resourceName: "arte_concert"),
                    url: URL(string: "https://www.arte.tv/de/videos/arte-concert/"))
        ],
        "Die Premium Partner": [
            Sponsor(name: "Kulturprojekte Niederrhein e.V.",
                    image: #imageLiteral(resourceName: "kulturprojekte-niederrhein"),
                    url: URL(string: "http://www.kulturprojekte-niederrhein.de/"))
        ],
        "Die Förderer": [
            Sponsor(name: "ENNI",
                    image: #imageLiteral(resourceName: "enni"),
                    url: URL(string: "http://www.enni.de/")),
            Sponsor(name: "Schlosstheater Moers",
                    image: #imageLiteral(resourceName: "schlosstheater"),
                    url: URL(string: "http://www.schlosstheater-moers.de/")),
            Sponsor(name: "Heringer-Klavierbau",
                    image: #imageLiteral(resourceName: "heringer-klavierbau"),
                    url: URL(string: "http://heringer-klavierbau.de")),
            Sponsor(name: "Autohaus Nuehlen",
                    image: #imageLiteral(resourceName: "nuehlen"),
                    url: URL(string: "http://www.autohaus-nuehlen.de/")),
            Sponsor(name: "sci:moers",
                    image: #imageLiteral(resourceName: "sci"),
                    url: URL(string: "http://sci.spirito.de/"))
        ],
        "Die Medienpartner": [
            Sponsor(name: "jazzthetik",
                    image: #imageLiteral(resourceName: "jazzthetik"),
                    url: URL(string: "http://www.jazzthetik.de/")),
            Sponsor(name: "freiStil",
                    image: #imageLiteral(resourceName: "freistil"),
                    url: URL(string: "http://freistil.klingt.org/")),
            Sponsor(name: "coolibri",
                    image: #imageLiteral(resourceName: "coolibri"),
                    url: URL(string: "http://www.coolibri.de/")),
            Sponsor(name: "Jazzthing",
                    image: #imageLiteral(resourceName: "jazzthing"),
                    url: URL(string: "https://www.jazzthing.de/")),
            Sponsor(name: "WIRE",
                    image: #imageLiteral(resourceName: "wire"),
                    url: URL(string: "https://www.thewire.co.uk/")),
            Sponsor(name: "Lokalkompass",
                    image: #imageLiteral(resourceName: "wochenmagazin"),
                    url: URL(string: "http://www.lokalkompass.de/wochen-magazin-moers"))
        ]
    ]
    
}
