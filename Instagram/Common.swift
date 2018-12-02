//
//  Common.swift
//  Instagram
//
//  Created by QueenaHuang on 13/1/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import Foundation
import UIKit

let defaultBackgroundColor = UIColor().colorWithHexString(hexString: "#D8DFE5")

class Helper {

    static func displayAlert(vc: UIViewController, title: String, message: String, completion:(()->())?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{ ( action ) in
            alert.dismiss(animated: true, completion: nil)
            completion?()
        }))

        vc.present(alert, animated: true, completion: nil)
    }
}

extension UIColor {

    func colorWithHexString(hexString: String) -> UIColor {

        var cString:String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        let r: CGFloat = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let g: CGFloat = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let b: CGFloat = CGFloat((rgbValue & 0x0000FF)) / 255.0
        let a: CGFloat = CGFloat(rgbValue & 0x000000FF) / 255.0

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }

    var imageRepresentation : UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()

        context?.setFillColor(self.cgColor)
        context?.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }

    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func toJPEGNSData(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
}
