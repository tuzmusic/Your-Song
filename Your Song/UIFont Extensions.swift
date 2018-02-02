//
//  UIFont Extensions.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 1/22/18.
//  Copyright © 2018 Jonathan Tuzman. All rights reserved.
//

import Foundation
import UIKit

struct AppFontName {
	static let regular = "Oswald-Regular"
	static let bold = "Oswald-Bold"
	static let light = "Oswald-Light"
}

extension UIFontDescriptor.AttributeName {
	static let nsctFontUIUsage =
		UIFontDescriptor.AttributeName(rawValue: "NSCTFontUIUsageAttribute")
}

extension UIFont {
	
	@objc class func mySystemFont(ofSize size: CGFloat) -> UIFont {
		return UIFont(name: AppFontName.regular, size: size)!
	}
	
	@objc class func myBoldSystemFont(ofSize size: CGFloat) -> UIFont {
		return UIFont(name: AppFontName.bold, size: size)!
	}
	
	@objc class func myLightSystemFont(ofSize size: CGFloat) -> UIFont {
		return UIFont(name: AppFontName.light, size: size)!
	}
	
	@objc convenience init(myCoder aDecoder: NSCoder) {
		if let fontDescriptor = aDecoder.decodeObject(forKey: "UIFontDescriptor") as? UIFontDescriptor {
			if let fontAttribute = fontDescriptor.fontAttributes[.nsctFontUIUsage] as? String {
				var fontName = ""
				switch fontAttribute {
				case "CTFontRegularUsage":
					fontName = AppFontName.regular
				case "CTFontEmphasizedUsage", "CTFontBoldUsage":
					fontName = AppFontName.bold
				case "CTFontObliqueUsage":
					fontName = AppFontName.light
				default:
					fontName = AppFontName.regular
				}
				self.init(name: fontName, size: fontDescriptor.pointSize)!
			}
			else {
				self.init(myCoder: aDecoder)
			}
		}
		else {
			self.init(myCoder: aDecoder)
		}
	}
	
	class func overrideInitialize() {
		if self == UIFont.self {
			let systemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:)))
			let mySystemFontMethod = class_getClassMethod(self, #selector(mySystemFont(ofSize:)))
			method_exchangeImplementations(systemFontMethod!, mySystemFontMethod!)
			
			let boldSystemFontMethod = class_getClassMethod(self, #selector(boldSystemFont(ofSize:)))
			let myBoldSystemFontMethod = class_getClassMethod(self, #selector(myBoldSystemFont(ofSize:)))
			method_exchangeImplementations(boldSystemFontMethod!, myBoldSystemFontMethod!)
			
			let italicSystemFontMethod = class_getClassMethod(self, #selector(italicSystemFont(ofSize:)))
			let myLightSystemFontMethod = class_getClassMethod(self, #selector(myLightSystemFont))
			method_exchangeImplementations(italicSystemFontMethod!, myLightSystemFontMethod!)
			
			let initCoderMethod = class_getInstanceMethod(self, #selector(UIFontDescriptor.init(coder:))) // Trick to get over the lack of UIFont.init(coder:))
			let myInitCoderMethod = class_getInstanceMethod(self, #selector(UIFont.init(myCoder:)))
			method_exchangeImplementations(initCoderMethod!, myInitCoderMethod!)
		}
	}
}

class AppDelegateRENAME_THIS: UIResponder, UIApplicationDelegate {
	// Avoid warning of Swift 3.1
	// Method 'initialize()' defines Objective-C class method 'initialize', which is not guaranteed to be invoked by Swift and will be disallowed in future versions
	override init() {
		super.init()
		UIFont.overrideInitialize()
	}
}

