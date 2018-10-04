//
//  UIColor+Image.swift
//  DeliTodo
//
//  Created by Kawoou on 04/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import UIKit

extension UIColor {
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }

        setFill()
        UIRectFill(CGRect(origin: .zero, size: size))

        guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else { return nil }
        return UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
    }
}
