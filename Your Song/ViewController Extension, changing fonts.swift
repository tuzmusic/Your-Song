//
//  ViewController Extension, changing fonts.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 1/23/18.
//  Copyright © 2018 Jonathan Tuzman. All rights reserved.
//

import Foundation
import UIKit

/*
struct FontNames {
    static let familyName = "Oswald"
    static let regular = "Oswald-Regular"
    static let bold = "Oswald-Bold"
    static let light = "Oswald-Light"
    static let regularItalic = "Oswald-RegularItalic"
    static let lightItalic = "Oswald-LightItalic"
    static let boldItalic = "Oswald-BoldItalic"

    static func fontName(bold: Bool = false, italic: Bool = false, light: Bool = false) -> String {
        var fontString = FontNames.familyName+"-"
        fontString += bold ? "Bold" : light ? "Light" : "Regular"
        if italic { fontString += "Italic"}
        return fontString
    }
}


extension UITableViewController {
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in subviewsOf(view) {
            setFont(for: view)
        }
    }
    
//    open override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
//        for view in subviewsOf(view) {
//            setFont(for: view)
//        }
//    }
	
    fileprivate func subviewsOf<T: UIView>(_ view: UIView) -> [T] {
        var subviews = [T]()
        
        for subview in view.subviews {
            subviews += subviewsOf(subview) as [T]
            
            if let subview = subview as? T {
                subviews.append(subview)
            }
        }
        return subviews
    }
    
    fileprivate func setFont(for view: UIView) {
       
        if let label = view as? UILabel {
            label.font = UIFont(name: FontNames.fontName(), size: label.font.pointSize)
        }
        else if let textField = view as? UITextField, let font = textField.font {
            textField.font = UIFont(name: FontNames.fontName(light: true), size: font.pointSize)
        }
        else if let textView = view as? UITextView, let font = textView.font {
            textView.font = UIFont(name: FontNames.fontName(light: true), size: font.pointSize)
        }
            // Technically this button font setting is unnecessary since the titleLabel will be covered as a UILabel in the view heirarchy,
            // but this allows a separate font for buttons if desired
        else if let button = view as? UIButton, let label = button.titleLabel {
            button.titleLabel!.font = UIFont(name: FontNames.fontName(), size: label.font.pointSize)
        }
        
    }
    
}
*/
