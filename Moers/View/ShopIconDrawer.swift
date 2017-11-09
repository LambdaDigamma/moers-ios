//
//  ShopIconDrawer.swift
//  Moers
//
//  Created by Lennart Fischer on 23.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit

class ShopIconDrawer {
    
    class func image(from branch: String, with size: CGSize) -> UIImage? {
        
        let image = ShopIconDrawer.annotationImage(from: branch)
        
        // begin a graphics context of sufficient size
        UIGraphicsBeginImageContext(size)
        
        // draw original image into the context
        image?.draw(at: CGPoint.zero)
        
        // get the context for CoreGraphics
        if let context = UIGraphicsGetCurrentContext() {
            
            let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
            
            let path = UIBezierPath(roundedRect: rect, cornerRadius: 10)
            
            //        UIColor.yellow.setFill()
            //
            //        path.fill()
            
            context.addPath(path.cgPath)
            
            // set stroking width and color of the context
            //        context.setLineWidth(1.0)
            //        context.setStrokeColor(UIColor.blue.cgColor)
            
            // set stroking from & to coordinates of the context
            
            //        context.move(to: CGPoint(x: from.x, y: from.y))
            //        context.addLine(to: CGPoint(x: to.x, y: to.y))
            
            // apply the stroke to the context
            //        context.strokePath()
            
            // get the image from the graphics context
            let resultImage = UIGraphicsGetImageFromCurrentImageContext()
            
            // end the graphics context
            UIGraphicsEndImageContext()
            
            return resultImage
            
        }

        return UIImage()
        
    }
    
    class func annotationImage(from branch: String) -> UIImage? {
        
        switch branch {
            
        case "Spiel & Hobby": return UIImage(named: "hobby")!
        case "Buchhandlung": return UIImage(named: "book")!
        //            case "Schmuck": return UIImage(named: "vorlageShop")!
        case "Friseur": return UIImage(named: "hairdresser")!
        //            case "Gastronomie": return UIImage(named: "food")!
        case "Bekleidung": return UIImage(named: "clothes")!
        case "Reisebüro": return UIImage(named: "travel")!
        case "Backwaren": return UIImage(named: "backery")!
        case "Münzen": return UIImage(named: "coin")!
        case "Blumen": return UIImage(named: "flower")!
        case "Optiker": return UIImage(named: "glasses")!
        case "Foto": return UIImage(named: "photo")!
            //            case "Hörakkustik": return UIImage(named: "vorlageShop")!
            //            case "Gardinen": return UIImage(named: "vorlageShop")!
        //            case "Feinkost": return UIImage(named: "vorlageShop")!
        case "Lotto": return UIImage(named: "lottery")!
        case "Telekommunikation": return UIImage(named: "telecommunication")!
        //            case "Nähmaschinen": return UIImage(named: "vorlageShop")!
        case "Geschenkartikel": return UIImage(named: "gift")!
        case "Stoffe": return UIImage(named: "fabrics")!
        //            case "Heimtextilien, Oberbekleidung": return UIImage(named: "vorlageShop")!
        case "Süßwaren": return UIImage(named: "candy")!
        case "Schuhe": return UIImage(named: "shoes")!
        case "Parfümerie": return UIImage(named: "scent")!
        case "Kaffee": return UIImage(named: "coffee")!
        //            case "Zahnpflege": return UIImage(named: "vorlageShop")!
        case "Getränke": return UIImage(named: "bottle")!
        //            case "Vermögensberatung": return UIImage(named: "vorlageShop")!
        case "Übersetzungsbüro": return UIImage(named: "translator")!
            //            case "IHK": return UIImage(named: "vorlageShop")!
            //            case "Massage": return UIImage(named: "vorlageShop")!
        //            case "Druck und Beschriftungen": return UIImage(named: "vorlageShop")!
        case "Musikinstrumente": return UIImage(named: "music")!
        //            case "Versicherung": return UIImage(named: "vorlageShop")!
        default: return nil
            
        }
        
    }
    
}
