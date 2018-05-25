//
//  ThanksTableViewController.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 3/15/18.
//  Copyright © 2018 Jonathan Tuzman. All rights reserved.
//

import UIKit

class ThanksTableViewController: UITableViewController {

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.row {
		case 2: startNewRequest()
		case 3: shareToFacebook()
		default: break
		}
	}
	
	fileprivate func startNewRequest() {
		let form = navigationController!.viewControllers.first as! CreateRequestTableViewController
		form.resetRequest()
		navigationController?.popToRootViewController(animated: true)
	}

	fileprivate func shareToFacebook() {
		
	}
	
}
