//
//  UI Design for CreateRequest.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 12/28/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import UIKit

extension CreateRequestTableViewController {
	
	// TO-DO: Resource for using custom fonts, and keeping them Accessible: https://grokswift.com/custom-fonts/
	
	func getFont(called fontName: String, size: Int, bold: Bool = false) -> UIFont {
		let descriptors = UIFontDescriptor(fontAttributes:
			[UIFontDescriptor.AttributeName.name : fontName])
		if bold {
			let boldTrait = [UIFontDescriptor.TraitKey.weight : UIFont.Weight.bold]
			descriptors.addingAttributes([UIFontDescriptor.AttributeName.traits : boldTrait])
		}
		
		let font = UIFont(descriptor: descriptors, size: CGFloat(size))
		return font
	}
	
	func attributedString(string: String) -> NSMutableAttributedString {
		let attrString = NSMutableAttributedString(string: string)
		
		let boldTrait = [UIFontDescriptor.TraitKey.weight : UIFont.Weight.bold]
		let descriptors = UIFontDescriptor(fontAttributes:
			[UIFontDescriptor.AttributeName.name : "BebasNeue",
			 UIFontDescriptor.AttributeName.traits : boldTrait ])
		let font = UIFont(descriptor: descriptors, size: 22)
		
		let fullRange = NSRange(location: 0, length: string.count)
		
		attrString.addAttribute(NSAttributedStringKey.font, value:font, range: fullRange)
		attrString.addAttribute(NSAttributedStringKey.kern, value: 2, range: fullRange)
		attrString.addAttribute(NSAttributedStringKey.foregroundColor, value: ypbOrange, range: fullRange)
		
		return attrString
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		let sectionNames = ["Name","Song","Notes/Dedication"]
		
		let label = UILabel()
		
		//label.attributedText = attributedString(string: string)
		
		label.text = "   " + "Your " + sectionNames[section] + ":"
		label.font = UIFont(name: "BebasNeue", size: 22)
		label.textColor = ypbOrange
		return label
	}
}

// TO-DO: Figure out how to indent the text of a label (possibly by "indenting" the label itself)
class IndentedLabel: UILabel {
	override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
		var rect = CGRect()
		rect.size.width = bounds.size.width * 0.5
		rect.origin.x += 100
		return rect
	}
}


