//
//  Font Extensions for Views.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 1/21/18.
//  Copyright © 2018 Jonathan Tuzman. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
	
	public var subFontName: String? {
		get {
			return self.font?.fontName
		}
		set {
			// TO-DO: self.font needs to be set to something other than nil, some default value that gets the default size for the object, and then we can grab that size below and set the font anew.
			if let font = self.font {
				if let size = font.fontDescriptor.fontAttributes[UIFontDescriptor.AttributeName.size] as? CGFloat {
					self.font = UIFont(name: newValue!, size: size)
				}
			}
		}
	}
}

extension UITextView {
	
	public var subFontName: String? {
		get {
			return self.font?.fontName
		}
		set {
			if self.font == nil { self.font = UIFont(name: "Arial", size: UIFont.labelFontSize) }
			if let font = self.font {
				if let size = font.fontDescriptor.fontAttributes[UIFontDescriptor.AttributeName.size] as? CGFloat {
					self.font = UIFont(name: newValue!, size: size)
				}
			}
		}
	}
}

extension UITextField {
	
	public var subFontName: String? {
		get {
			return self.font?.fontName
		}
		set {
			if self.font == nil { self.font = UIFont(name: "Arial", size: UIFont.labelFontSize) }
			if let font = self.font {
				if let size = font.fontDescriptor.fontAttributes[UIFontDescriptor.AttributeName.size] as? CGFloat {
					self.font = UIFont(name: newValue!, size: size)
				}
			}
		}
	}
}

