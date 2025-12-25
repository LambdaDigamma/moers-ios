//
//  StaticNewsService.swift
//  
//
//  Created by Lennart Fischer on 10.02.22.
//

import Foundation
import FeedKit
import Combine

// swiftlint:disable type_body_length
// swiftlint:disable function_body_length
// swiftlint:disable line_length
public class StaticNewsService: NewsService {
    
    public init() {
        
    }
    
    public func loadNewsItems() -> AnyPublisher<[RSSFeedItem], Error> {
        
        let data = """
        <rss xmlns:atom="http://www.w3.org/2005/Atom" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:admin="http://webns.net/mvcb/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:media="http://search.yahoo.com/mrss/" xmlns:content="http://purl.org/rss/1.0/modules/content/" version="2.0">
            <channel>
            <title>Moers | RP ONLINE</title>
            <link>https://rp-online.de/nrw/staedte/moers/feed.rss</link>
            <description>Aktuelle Nachrichten</description>
            <language>de-DE</language>
            <lastBuildDate>Thu, 10 Feb 2022 23:41:32 +0100</lastBuildDate>
            <atom:link rel="self" href="https://rp-online.de/nrw/staedte/moers/feed.rss"/>
            <item>
            <content_tier>locked</content_tier>
            <title>Einkaufen in Moers: Läden sollen am Kirmessonntag öffnen</title>
            <link>https://rp-online.de/nrw/staedte/moers/moers-verkaufsoffener-sonntag-zur-kirmes-in-der-diskussion_aid-66126139</link>
            <guid isPermaLink="true">https://rp-online.de/66126139</guid>
            <description><![CDATA[
                                              <img src="https://rp-online.de/imgs/32/1/2/3/7/0/0/3/8/1/tok_8eb03d8e282ef01d1161201b97cd7ed1/w268_h201_x1796_y1124_RP_202004120_CREI_0374-8316b6d9896849bd.jpg" hspace="5" align="left"/>
                                                                                                          Das Stadtmarketing möchte einen dritten verkaufsoffenen Sonntag in der Moerser Innenstadt etablieren. SPD-Fraktionschef Atilla Cikoglu hält den Termin für nicht ideal. Auch die Evangelische Kirchengemeinde hat Bedenken.
                                            ]]></description>
            <enclosure url="https://rp-online.de/imgs/32/1/2/3/7/0/0/3/8/1/tok_60d93c1d93c309afa6c640b053af61c5/w950_h950_x1796_y1124_RP_202004120_CREI_0374-8316b6d9896849bd.jpg" length="1905180" type="image/jpeg"/>
            <dc:creator><![CDATA[
                            Julia Hagenacker
                            ]]></dc:creator>
            <category>NRW</category>
            <category>Städte</category>
            <category>Moers</category>
            <pubDate>Thu, 10 Feb 2022 17:37:00 +0100</pubDate>
            </item>
            <item>
            <content_tier>metered</content_tier>
            <title>Kindergärten in Moers: Warum drei Kitas neue Träger erhalten</title>
            <link>https://rp-online.de/nrw/staedte/moers/moers-warum-drei-kitas-neue-traeger-erhalten_aid-65961169</link>
            <guid isPermaLink="true">https://rp-online.de/65961169</guid>
            <description><![CDATA[
                                              <img src="https://rp-online.de/imgs/32/1/2/3/3/3/9/3/9/3/tok_12e87140bf45b6fcab6c76d91edea943/w268_h201_x600_y375_DPA_tmnbd_dpa_5FA12800AAFAF2E8-f2053d1b7970ff87.jpg" hspace="5" align="left"/>
                                                                                                          Zu wenig Geld, zu viel Arbeit: Evangelische Gemeinden geben Kindergärten in Hochstraß, Repelen und Eick ab.
                                            ]]></description>
            <enclosure url="https://rp-online.de/imgs/32/1/2/3/3/3/9/3/9/3/tok_5dea67a19e54c97041341f34086dd9d2/w950_h751_x600_y375_DPA_tmnbd_dpa_5FA12800AAFAF2E8-f2053d1b7970ff87.jpg" length="743953" type="image/jpeg"/>
            <category>NRW</category>
            <category>Städte</category>
            <category>Moers</category>
            <pubDate>Thu, 10 Feb 2022 16:50:45 +0100</pubDate>
            </item>
            <item>
            <content_tier>metered</content_tier>
            <title>Handball: Maik Pallach setzt auf die Heimstärke der HSG </title>
            <link>https://rp-online.de/nrw/staedte/krefeld/sport/maik-pallach-setzt-auf-die-heimstaerke-der-hsg-krefeld-niederrhein_aid-66136269</link>
            <guid isPermaLink="true">https://rp-online.de/66136269</guid>
            <description><![CDATA[
                                              <img src="https://rp-online.de/imgs/32/1/2/3/7/3/0/9/6/3/tok_6e4ebe41f88ad993fcc6ab0a828ea93b/w268_h201_x600_y396_RP_HSG__Trainer_Maik_Pallach002-36f87fb2a8b35be8.JPG" hspace="5" align="left"/>
                                                                                                          Beim Trainer des Krefelder Handball-Drittligisten und seinem Team herrscht vor dem Endspiel um Platz eins in der Staffel D gegen die Dragons aus Schalksmühle eine freudige Anspannung. Das erste Ziel ist Platz eins.
                                            ]]></description>
            <enclosure url="https://rp-online.de/imgs/32/1/2/3/7/3/0/9/6/3/tok_6f80016219016a259b29fef5073c9ade/w950_h794_x600_y396_RP_HSG__Trainer_Maik_Pallach002-36f87fb2a8b35be8.JPG" length="782260" type="image/jpeg"/>
            <dc:creator><![CDATA[
                            Luisa Schoofs
                            ]]></dc:creator>
            <category>NRW</category>
            <category>Städte</category>
            <category>Kempen</category>
            <category>Lokalsport</category>
            <pubDate>Thu, 10 Feb 2022 16:37:00 +0100</pubDate>
            </item>
            <item>
            <content_tier>metered</content_tier>
            <title>Fußball: Tobias Tatzel will sich in der Landesliga etablieren</title>
            <link>https://rp-online.de/nrw/staedte/xanten/sport/rheinberg-tobias-tatzel-will-sich-in-der-fussball-landesliga-etablieren_aid-66131631</link>
            <guid isPermaLink="true">https://rp-online.de/66131631</guid>
            <description><![CDATA[
                                              <img src="https://rp-online.de/imgs/32/1/2/3/7/1/6/3/2/7/tok_3c7b38a7b6f785993d272928bdf2ba35/w268_h201_x581_y687_Tazel.v1.cropped-5876dedcd6fdc143.jpg" hspace="5" align="left"/>
                                                                                                          Der Rheinberger hat sich in den vergangenen Jahren stetig weiterentwickelt. Aktuell spielt er für die SV Hönnepel-Niedermörmter. Auch für den SV Sonsbeck und den FC Meerfeld war er schon aktiv. Nach der Saison wird er zum Liga-Rivalen TSV Wachtendonk-Wankum wechseln.
                                            ]]></description>
            <enclosure url="https://rp-online.de/imgs/32/1/2/3/7/1/6/3/2/7/tok_b9bd480591582d595ef7b0a9822e0236/w950_h950_x581_y687_Tazel.v1.cropped-5876dedcd6fdc143.jpg" length="665749" type="image/jpeg"/>
            <dc:creator><![CDATA[
                            Fabian Kleintges-Topoll
                            ]]></dc:creator>
            <category>NRW</category>
            <category>Städte</category>
            <category>Moers</category>
            <category>Sport</category>
            <pubDate>Thu, 10 Feb 2022 14:36:00 +0100</pubDate>
            </item>
            <item>
            <content_tier>metered</content_tier>
            <title>Corona-Pandemie im Kreis Wesel: Ein weiterer Todesfall – Inzidenz leicht gesunken </title>
            <link>https://rp-online.de/nrw/staedte/wesel/corona-im-kreis-wesel-ein-weiterer-todesfall_aid-56628667</link>
            <guid isPermaLink="true">https://rp-online.de/56628667</guid>
            <description><![CDATA[
                                              <img src="https://rp-online.de/imgs/32/1/0/1/0/6/3/3/9/7/tok_eb573845bb2d18e72350568a1c4dddeb/w268_h201_x1500_y971_DPA_bfunk_dpa_5FA87400F1CBA3FD-0126d212eb381e3e.jpg" hspace="5" align="left"/>
                                                                                                          Im Kreis Wesel ist ein weiterer Mensch verstorben, der positiv auf das Coronavirus getestet wurde: eine 87 Jahre alte Frau aus Moers. Die 7-Tage-Inzidenz ist leicht gesunken. Ein Überblick über die Lage in den Städten und Gemeinden.
                                            ]]></description>
            <enclosure url="https://rp-online.de/imgs/32/1/0/1/0/6/3/3/9/7/tok_d24f91f36ccb7f8323d04a99edf86005/w950_h950_x1500_y971_DPA_bfunk_dpa_5FA87400F1CBA3FD-0126d212eb381e3e.jpg" length="509134" type="image/jpeg"/>
            <dc:creator><![CDATA[
                            Henning Rasche, Julia Hagenacker, Cornelia Brandt, Beate Wyglenda, Bernfried Paus, Fritz Schubert, Klaus Nikolei, Sina Zehrfeld, Heinz Schild, Jan Luhrenberg
                            ]]></dc:creator>
            <category>NRW</category>
            <category>Städte</category>
            <category>Dinslaken</category>
            <pubDate>Thu, 10 Feb 2022 12:50:00 +0100</pubDate>
            </item>
            <item>
            <content_tier>metered</content_tier>
            <title>Straßenbauprogramm Moers: Stadt fördert Radverkehr und erneuert Wohnstraßen</title>
            <link>https://rp-online.de/nrw/staedte/moers/moers-umbau-der-unterwallstrasse-in-vorbereitung_aid-65961711</link>
            <guid isPermaLink="true">https://rp-online.de/65961711</guid>
            <description><![CDATA[
                                              <img src="https://rp-online.de/imgs/32/1/2/3/3/4/0/6/2/1/tok_ed4170bef9911c1f3afd6bf41fb67217/w268_h201_x599_y365_x9Fenplanung-5b3d7a299ee99928.JPG" hspace="5" align="left"/>
                                                                                                          Das Straßenbauprogramm der Stadt Moers für 2022 steht. Welches Großprojekt noch in diesem Jahr in die politische Beratung gehen soll.
                                            ]]></description>
            <enclosure url="https://rp-online.de/imgs/32/1/2/3/3/4/0/6/2/1/tok_48aa984600782c36e65fba90338b2702/w950_h731_x599_y365_x9Fenplanung-5b3d7a299ee99928.JPG" length="738039" type="image/jpeg"/>
            <category>NRW</category>
            <category>Städte</category>
            <category>Moers</category>
            <pubDate>Wed, 09 Feb 2022 19:00:00 +0100</pubDate>
            </item>
            <item>
            <content_tier>locked</content_tier>
            <title>Wohnungsbau Stadt Moers: Garantin für erschwinglichen Wohnraum </title>
            <link>https://rp-online.de/nrw/staedte/moers/wohnungsbau-stadt-moers-garantin-fuer-erschwinglichen-wohnraum_aid-65878027</link>
            <guid isPermaLink="true">https://rp-online.de/65878027</guid>
            <description><![CDATA[
                                              <img src="https://rp-online.de/imgs/32/1/2/3/1/3/5/9/1/5/tok_340310b073dc29011a91734408f1bfe8/w268_h201_x600_y443_jn012102_AnbautenMeerbeck-987518eb2127d73b.jpg" hspace="5" align="left"/>
                                                                                                          Seit Jahrzehnten sorgt die Wohnungsbau Stadt Moers für Ausgleich auf einem überdrehenden Wohnungsmarkt. Selten war das so schwierig wie jetzt. Was die Geschäftsführer Jens Kreische und Tobias Pawletko planen.
                                            ]]></description>
            <enclosure url="https://rp-online.de/imgs/32/1/2/3/1/3/5/9/1/5/tok_65d6d96d4e7fd9f918b6dca0162e80f9/w950_h886_x600_y443_jn012102_AnbautenMeerbeck-987518eb2127d73b.jpg" length="750372" type="image/jpeg"/>
            <dc:creator><![CDATA[
                            Julia Hagenacker
                            ]]></dc:creator>
            <category>NRW</category>
            <category>Städte</category>
            <category>Moers</category>
            <pubDate>Wed, 09 Feb 2022 15:30:00 +0100</pubDate>
            </item>
            <item>
            <content_tier>locked</content_tier>
            <title>Fußball-Bezirkisliga: SV Budberg verliert Ole Egging an den SV Scherpenberg</title>
            <link>https://rp-online.de/nrw/staedte/xanten/sport/fussball-ole-egging-wechselt-vom-sv-buberg-zum-sv-scherpenberg_aid-66089695</link>
            <guid isPermaLink="true">https://rp-online.de/66089695</guid>
            <description><![CDATA[
                                              <img src="https://rp-online.de/imgs/32/1/2/3/6/1/5/3/8/1/tok_e4dcff6d58b689945b4ba33def4bfbab/w268_h201_x1796_y1425_RP_Xanten_-_TUS_Xanten_gegen_SV_Budberg_007-a69bc35f537b88ca.jpg" hspace="5" align="left"/>
                                                                                                          Der 20-jährige Senkrechtstarter, der sich im Sommer dem Landesligisten anschließen wird, hatte Angebote von weiteren höherklassigen Vereinen vorliegen. 17 Spieler haben zugesagt, in Budberg bleiben zu wollen.
                                            ]]></description>
            <enclosure url="https://rp-online.de/imgs/32/1/2/3/6/1/5/3/8/1/tok_2cd59f51d2a5af1f253127d8a23bafb3/w950_h950_x1796_y1425_RP_Xanten_-_TUS_Xanten_gegen_SV_Budberg_007-a69bc35f537b88ca.jpg" length="1364277" type="image/jpeg"/>
            <dc:creator><![CDATA[
                            René Putjus
                            ]]></dc:creator>
            <category>NRW</category>
            <category>Städte</category>
            <category>Moers</category>
            <category>Sport</category>
            <pubDate>Wed, 09 Feb 2022 12:30:00 +0100</pubDate>
            </item>
            <item>
            <content_tier>locked</content_tier>
            <title>Kriminalität in Moers: Spektakulärer Blitzeinbruch endet im Juwelier-Eingang</title>
            <link>https://rp-online.de/nrw/staedte/moers/moers-spektakulaerer-blitzeinbruch-endet-im-juwelier-eingang_aid-66087699</link>
            <guid isPermaLink="true">https://rp-online.de/66087699</guid>
            <description><![CDATA[
                                              <img src="https://rp-online.de/imgs/32/1/2/3/6/0/9/8/8/5/tok_14df4153bd613ab679ba5d327ba4eb93/w268_h201_x1000_y750_273744549_5039413796110577_333453260768517465_n-8da4e79fd6a0853e.jpg" hspace="5" align="left"/>
                                                                                                          Einen spektakulären Einbruchsversuch hat es in der Nacht auf Mittwoch auf der Steinstraße in Moers gegeben. Mit einem Auto rammten die Täter die Tür eines Geschäfts. Dessen Betreiber hatten sich aber gewappnet.
                                            ]]></description>
            <enclosure url="https://rp-online.de/imgs/32/1/2/3/6/0/9/8/8/5/tok_062b2a97cd1aa2ada8a5521ad32f2cbc/w950_h950_x1000_y750_273744549_5039413796110577_333453260768517465_n-8da4e79fd6a0853e.jpg" length="356537" type="image/jpeg"/>
            <dc:creator><![CDATA[
                            Josef Pogorzalek
                            ]]></dc:creator>
            <category>NRW</category>
            <category>Städte</category>
            <category>Moers</category>
            <pubDate>Wed, 09 Feb 2022 10:25:00 +0100</pubDate>
            </item>
            <item>
            <content_tier>metered</content_tier>
            <title>Fragen und Antworten: Was Sie zur Landtagswahl im Kreis Wesel wissen müssen</title>
            <link>https://rp-online.de/nrw/staedte/wesel/nrw-landtagswahl-2022-in-wesel/landtagswahl-2022-im-kreis-wesel-kandidaten-parteien-und-chancen_aid-65063121</link>
            <guid isPermaLink="true">https://rp-online.de/65063121</guid>
            <description><![CDATA[
                                              <img src="https://rp-online.de/imgs/32/1/2/1/2/5/0/5/2/5/tok_bf7d3c6d467738dd9305da0321e21264/w268_h201_x1500_y932_DPA_bfunk_dpa_5FA87400BCD7EA0E-7ded822541cb1f61.jpg" hspace="5" align="left"/>
                                                                                                          Nur acht Monate nach der Bundestagswahl werden die Menschen in NRW erneut an die Wahlurnen gerufen. Am 15. Mai wird über die Zusammensetzung des Landtags abgestimmt. So stehen die Chancen der Kandidaten aus dem Kreis Wesel.
                                            ]]></description>
            <enclosure url="https://rp-online.de/imgs/32/1/2/1/2/5/0/5/2/5/tok_426fcaa223061c8df162e63a8b267b85/w950_h950_x1500_y932_DPA_bfunk_dpa_5FA87400BCD7EA0E-7ded822541cb1f61.jpg" length="1137680" type="image/jpeg"/>
            <dc:creator><![CDATA[
                            Fritz Schubert
                            ]]></dc:creator>
            <category>NRW</category>
            <category>Städte</category>
            <category>Dinslaken</category>
            <pubDate>Wed, 09 Feb 2022 06:20:00 +0100</pubDate>
            </item>
            <item>
            <content_tier>locked</content_tier>
            <title>Co-Trainer an US-Universität: Wie ein Rheinberger seinen Fußball-Traum lebt</title>
            <link>https://rp-online.de/nrw/staedte/xanten/sport/rheinberger-mads-kaiser-ist-seit-acht-jahren-fuer-den-fussball-in-den-usa_aid-66061673</link>
            <guid isPermaLink="true">https://rp-online.de/66061673</guid>
            <description><![CDATA[
                                              <img src="https://rp-online.de/imgs/32/1/2/3/5/5/3/0/2/3/tok_3fc580d45b9ca8f847f3ff78030699d5/w268_h201_x709_y218_Mads-6d8808b878196732.jpg" hspace="5" align="left"/>
                                                                                                          Mads Kaiser wagte vor acht Jahren als Jugendlicher den Schritt in die USA. Von einem Abenteurer, der viele Wendungen erlebte - und noch lange nicht genug hat.
                                            ]]></description>
            <enclosure url="https://rp-online.de/imgs/32/1/2/3/5/5/3/0/2/3/tok_e3f4ae5fe6afae7d8c0c8c557944c68c/w950_h950_x709_y218_Mads-6d8808b878196732.jpg" length="1240299" type="image/jpeg"/>
            <dc:creator><![CDATA[
                            Michael Elsing
                            ]]></dc:creator>
            <category>NRW</category>
            <category>Städte</category>
            <category>Moers</category>
            <category>Sport</category>
            <pubDate>Wed, 09 Feb 2022 05:45:00 +0100</pubDate>
            </item>
            <item>
            <content_tier>metered</content_tier>
            <title>Blindgänger-Verdacht am Krankenhaus in Moers: Bethanien droht eine Evakuierung</title>
            <link>https://rp-online.de/nrw/staedte/moers/moers-blindgaenger-verdacht-krankenhaus-droht-evakuierung_aid-66056647</link>
            <guid isPermaLink="true">https://rp-online.de/66056647</guid>
            <description><![CDATA[
                                              <img src="https://rp-online.de/imgs/32/1/2/3/5/3/8/8/2/3/tok_8bce45d5c0c2b1795312e6923e50f60d/w268_h201_x1796_y1197_RP_NOP_8343_b-2ab54392976594fc.jpg" hspace="5" align="left"/>
                                                                                                          Auf einer Baustelle auf dem Gelände des Moerser Krankenhauses liegt möglicherweise ein Blindgänger aus dem Krieg im Boden. Patienten, deren Behandlung nicht akut notwendig ist, werden vorläufig nicht aufgenommen.
                                            ]]></description>
            <enclosure url="https://rp-online.de/imgs/32/1/2/3/5/3/8/8/2/3/tok_c3b1b21afa78722f80054ffd4f7c4360/w950_h950_x1796_y1197_RP_NOP_8343_b-2ab54392976594fc.jpg" length="1688138" type="image/jpeg"/>
            <dc:creator><![CDATA[
                            Josef Pogorzalek
                            ]]></dc:creator>
            <category>NRW</category>
            <category>Städte</category>
            <category>Moers</category>
            <pubDate>Tue, 08 Feb 2022 18:00:00 +0100</pubDate>
            </item>
            <item>
            <content_tier>metered</content_tier>
            <title>Kriminalität in Moers-Kapellen: Geldautomat der Sparkasse gesprengt</title>
            <link>https://rp-online.de/nrw/staedte/moers/geldautomat-der-sparkasse-gesprengt-in-moers-kapellen_aid-66052949</link>
            <guid isPermaLink="true">https://rp-online.de/66052949</guid>
            <description><![CDATA[
                                              <img src="https://rp-online.de/imgs/32/1/2/3/5/2/9/5/5/3/tok_3069252f4bfdd9affbdb6f3f3dc69824/w268_h201_x1500_y1000_DPA_bfunk_dpa_5FA8900067DDD9C9-30444c36693abacf.jpg" hspace="5" align="left"/>
                                                                                                          Unbekannte haben in der Nacht von Montag auf Dienstag an der Bahnhofstraße in Moers-Kapellen zugeschlagen. Sie flüchteten mit einem Auto in Richtung Niederlande.
                                            ]]></description>
            <enclosure url="https://rp-online.de/imgs/32/1/2/3/5/2/9/5/5/3/tok_513ad910da6d1664682ffed32306c616/w950_h950_x1500_y1000_DPA_bfunk_dpa_5FA8900067DDD9C9-30444c36693abacf.jpg" length="1066585" type="image/jpeg"/>
            <dc:creator><![CDATA[
                            Cornelia Brandt, Josef Pogorzalek
                            ]]></dc:creator>
            <category>NRW</category>
            <category>Städte</category>
            <category>Kamp-Lintfort</category>
            <pubDate>Tue, 08 Feb 2022 11:28:00 +0100</pubDate>
            </item>
            <item>
            <content_tier>locked</content_tier>
            <title>Gerichtsprozess in Moers: Pizzabote lieferte Marihuana frei Haus</title>
            <link>https://rp-online.de/nrw/staedte/moers/gerichtsprozess-in-moers-pizzabote-lieferte-marihuana-frei-haus_aid-66016627</link>
            <guid isPermaLink="true">https://rp-online.de/66016627</guid>
            <description><![CDATA[
                                              <img src="https://rp-online.de/imgs/32/1/2/3/4/4/9/4/1/7/tok_e9eb6fe022e12fd1b5c2db3af96ae5e0/w268_h201_x487_y598_DPA_bfunk_dpa_5FA1B200E1FD78E8-10f1100df68e3b62.jpg" hspace="5" align="left"/>
                                                                                                          Ein 32-Jähriger ist zu sechseinhalb Jahren Freiheitsstrafe verurteilt worden. Die Drogen, die er in seinem Haus anbaute, bot er auch im Internet an.
                                            ]]></description>
            <enclosure url="https://rp-online.de/imgs/32/1/2/3/4/4/9/4/1/7/tok_eed8764c97dec6b41703bf5dad06a524/w950_h950_x487_y598_DPA_bfunk_dpa_5FA1B200E1FD78E8-10f1100df68e3b62.jpg" length="908302" type="image/jpeg"/>
            <dc:creator><![CDATA[
                            Heidrun Jasper
                            ]]></dc:creator>
            <category>NRW</category>
            <category>Städte</category>
            <category>Duisburg</category>
            <pubDate>Mon, 07 Feb 2022 17:30:00 +0100</pubDate>
            </item>
            <item>
            <content_tier>metered</content_tier>
            <title>Trauer in Moers: Abschied von einer starken Frau</title>
            <link>https://rp-online.de/nrw/staedte/moers/moers-abschied-von-einer-starken-frau_aid-66016485</link>
            <guid isPermaLink="true">https://rp-online.de/66016485</guid>
            <description><![CDATA[
                                              <img src="https://rp-online.de/imgs/32/1/2/3/4/4/9/0/4/7/tok_a0e29c0daeee4c36a80e8aa81ad8e418/w268_h201_x580_y600_Christel_80_2015-05-15-ba260a054731cb36.jpg" hspace="5" align="left"/>
                                                                                                          Von 1994 bis 1996 war Christel Apostel Landrätin im Kreis Wesel. Nach langer Krankheit starb die Bundesverdienstkreuzträgerin am Samstag im Alter von 86 Jahren. Ein Nachruf.
                                            ]]></description>
            <enclosure url="https://rp-online.de/imgs/32/1/2/3/4/4/9/0/4/7/tok_c7a6f460cc4e557dbfd795da2d379085/w950_h950_x580_y600_Christel_80_2015-05-15-ba260a054731cb36.jpg" length="860831" type="image/jpeg"/>
            <dc:creator><![CDATA[
                            Julia Hagenacker
                            ]]></dc:creator>
            <category>NRW</category>
            <category>Städte</category>
            <category>Dinslaken</category>
            <pubDate>Mon, 07 Feb 2022 16:48:00 +0100</pubDate>
            </item>
            <item>
            <content_tier>locked</content_tier>
            <title>SPD in Moers: Treffpunkt am Kö sucht noch einen Namen</title>
            <link>https://rp-online.de/nrw/staedte/moers/moers-neues-partei-und-wahlkreisbuero-der-spd_aid-65986727</link>
            <guid isPermaLink="true">https://rp-online.de/65986727</guid>
            <description><![CDATA[
                                              <img src="https://rp-online.de/imgs/32/1/2/3/3/8/3/4/8/9/tok_fb87824c81553097129966fdf3b611d2/w268_h201_x2784_y1856_RP_NOP_7847_b-b7aaeda9fd2981a3.jpg" hspace="5" align="left"/>
                                                                                                          Das neue Partei- und Wahlkreisbüro der SPD soll gleichzeitig auch ein Ort der Begegnung werden, an dem Menschen Fragen stellen oder ihre Meinung sagen können.
                                            ]]></description>
            <enclosure url="https://rp-online.de/imgs/32/1/2/3/3/8/3/4/8/9/tok_79a7985bd84d613ddf19e186ab2d5265/w950_h950_x2784_y1856_RP_NOP_7847_b-b7aaeda9fd2981a3.jpg" length="2079138" type="image/jpeg"/>
            <dc:creator><![CDATA[
                            Peter Gottschlich
                            ]]></dc:creator>
            <category>NRW</category>
            <category>Städte</category>
            <category>Moers</category>
            <pubDate>Sun, 06 Feb 2022 16:00:00 +0100</pubDate>
            </item>
            <item>
            <content_tier>metered</content_tier>
            <title>Grafschafter Diakonie: Wenn die Sucht das Familienleben beeinflusst</title>
            <link>https://rp-online.de/nrw/staedte/moers/moers-kunsttherapie-fuer-kinder_aid-65909325</link>
            <guid isPermaLink="true">https://rp-online.de/65909325</guid>
            <description><![CDATA[
                                              <img src="https://rp-online.de/imgs/32/1/2/3/2/0/6/1/0/1/tok_af959513051f6bb7801c516a49659132/w268_h201_x1944_y1296_IMG_8161-25d0966cd51d30a7.jpg" hspace="5" align="left"/>
                                                                                                          Die Drogenhilfe und  die ambulante Familienhilfe bieten Kunsttherapie für Kinder suchterkrankter oder seelisch gehandicapter Eltern an. Mit dem Angebot sollen die Kinder gefördert und entlastet werden.
                                            ]]></description>
            <enclosure url="https://rp-online.de/imgs/32/1/2/3/2/0/6/1/0/1/tok_e2e1306bb76eef523a49f53ef2335d48/w950_h950_x1944_y1296_IMG_8161-25d0966cd51d30a7.jpg" length="1363574" type="image/jpeg"/>
            <category>NRW</category>
            <category>Städte</category>
            <category>Moers</category>
            <pubDate>Sun, 06 Feb 2022 16:00:00 +0100</pubDate>
            </item>
            <item>
            <content_tier>metered</content_tier>
            <title>„Gemeinsam gegen einsam“: Ehrenamtliche Seelsorge auf dem Weg</title>
            <link>https://rp-online.de/nrw/staedte/xanten/xanten-moers-ehrenamtliche-seelsorge-auf-dem-weg_aid-65957575</link>
            <guid isPermaLink="true">https://rp-online.de/65957575</guid>
            <description><![CDATA[
                                              <img src="https://rp-online.de/imgs/32/1/2/3/3/2/8/6/1/3/tok_a5b6f294a08cb407cd3341afad7d678e/w268_h201_x597_y251_2022-02-03-Beauftragung-84bce01d319d7138.jpg" hspace="5" align="left"/>
                                                                                                          Weihbischof Rolf Lohmann entsandte im St.-Viktor-Dom 16 Laien-Seelsorger aus den Dekanaten Xanten und Moers, die auf Wunsch kranke und alleinstehende Menschen besuchen, um sie aus der Isolation zu holen.
                                            ]]></description>
            <enclosure url="https://rp-online.de/imgs/32/1/2/3/3/2/8/6/1/3/tok_e54c168bfc1b9965ac8b423d6758aa6d/w950_h779_x597_y251_2022-02-03-Beauftragung-84bce01d319d7138.jpg" length="907275" type="image/jpeg"/>
            <dc:creator><![CDATA[
                            Bernfried Paus
                            ]]></dc:creator>
            <category>NRW</category>
            <category>Städte</category>
            <category>Kamp-Lintfort</category>
            <pubDate>Sun, 06 Feb 2022 11:19:00 +0100</pubDate>
            </item>
            <item>
            <content_tier>locked</content_tier>
            <title>Schwierige Kontrollen der Impfpässe: Ein zentrales Impfregister ist die Rettung</title>
            <link>https://rp-online.de/nrw/staedte/wesel/gefaelschte-impfpaesse-im-kreis-wesel-warum-ein-impfregister-die-rettung-ist_aid-65802733</link>
            <guid isPermaLink="true">https://rp-online.de/65802733</guid>
            <description><![CDATA[
                                              <img src="https://rp-online.de/imgs/32/1/2/2/9/6/2/0/4/9/tok_2d16023148c03cc90679eecd6581c244/w268_h201_x1500_y1092_DPA_kibld_dpa_5FA88600A6E2A7FF-39f5d2ae56e7bc3a.jpg" hspace="5" align="left"/>
                                                                                                          Die Kontrollen der Impfpässe sind aktuell sehr umständlich und fast schon sinnlos, weil die gelben Heftchen nicht fälschungssicher sind. Ein Impfregister würde vieles vereinfachen – und auch darüber hinaus viele Vorteile bieten.
                                            ]]></description>
            <enclosure url="https://rp-online.de/imgs/32/1/2/2/9/6/2/0/4/9/tok_f1d5692b555e8208f9fbd9c55c898bdc/w950_h950_x1500_y1092_DPA_kibld_dpa_5FA88600A6E2A7FF-39f5d2ae56e7bc3a.jpg" length="1128856" type="image/jpeg"/>
            <dc:creator><![CDATA[
                            Jan Luhrenberg
                            ]]></dc:creator>
            <category>NRW</category>
            <category>Städte</category>
            <category>Dinslaken</category>
            <pubDate>Sun, 06 Feb 2022 06:20:00 +0100</pubDate>
            </item>
            </channel>
        </rss>
        """
        
        let parser = FeedParser(data: data.data(using: .utf8)!)
        let result = parser.parse()
        let feed = try? result.get().rssFeed
        
        let items = (feed?.items ?? [])
            .map({ (item: RSSFeedItem) -> RSSFeedItem in
                let source = RSSFeedItemSource()
                source.value = feed?.title ?? ""
                item.source = source
                return item
            })
            .sorted(by: { ($0.date > $1.date ) })
        
        return Just(items)
            .setFailureType(to: Error.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
    }
    
}
