//
//  ArtistsInGenreTableViewController.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 4/13/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import RealmSwift

class ArtistsInGenreTableViewController: UITableViewController {
	
	var objects = [Object]()
	var itemType: Object.Type!
	var realm: Realm! {
		didSet {
			objects = Array(realm.objects(itemType))
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		itemType = Genre.self
	}
	
	// MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return objects.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		// let item = objects[indexPath.row] as! itemType.self
		// cell.textLabel?.text = String(describing: item.value(forKey: item.objectSchema.properties.first!.name))
		let item = objects[indexPath.row] as! Genre
		cell.textLabel?.text = item.name
		
		cell.detailTextLabel?.text = String(item.songs.count) + " songs"
		
		return cell
	}
	
	
	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let dvc = segue.destination as? ArtistsInGenreTableViewController {
			
		}
	}
	
}
