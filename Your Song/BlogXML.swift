//
//  BlogXML.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 5/27/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

extension YPB {
	
	struct Blogger {
		static let footer = "</feed>"
		
		struct Post {
			static let title = "SONG TITLE"
			static let artist = "SONG ARTIST"
			static let songNumId = "SONG #"
			//static let basePostID = "6963107680176187154"
			//static let basePostID2 = "343456466211441902"
			//static let songID = "song-title-"
		}
		
		static let eachPost = "\n" + " /* SONG # */ <entry><id>tag:blogger.com,1999:blog-914891131162139721.post-6963107680176187154</id><published>2017-05-27T08:39:00.003-07:00</published><updated>2017-05-27T08:39:24.604-07:00</updated><category scheme='http://schemas.google.com/g/2005#kind' term='http://schemas.google.com/blogger/2008/kind#post'/><title type='text'>SONG TITLE</title><content type='html'>SONG ARTIST</content><link rel='replies' type='application/atom+xml' href='https://yourpianobarsonglist.blogspot.com/feeds/6963107680176187154/comments/default' title='Post Comments'/><link rel='replies' type='text/html' href='http://yourpianobarsonglist.blogspot.com/2017/05/song-title-2.html#comment-form' title='0 Comments'/><link rel='edit' type='application/atom+xml' href='https://www.blogger.com/feeds/914891131162139721/posts/default/6963107680176187154'/><link rel='self' type='application/atom+xml' href='https://www.blogger.com/feeds/914891131162139721/posts/default/6963107680176187154'/><link rel='alternate' type='text/html' href='http://yourpianobarsonglist.blogspot.com/2017/05/song-title-2.html' title='link title (should be safe to ignore)'/><author><name>Jonathan Tuzman</name><uri>https://www.blogger.com/profile/11107905425531958358</uri><email>noreply@blogger.com</email><gd:image rel='http://schemas.google.com/g/2005#thumbnail' width='35' height='35' src='//lh3.googleusercontent.com/zFdxGE77vvD2w5xHy6jkVuElKv-U9_9qLkRYK8OnbDeJPtjSZ82UPq5w6hJ-SA=s35'/></author><thr:total>0</thr:total></entry>"

		static let eachPost4 = "<entry><id>tag:blogger.com,1999:blog-914891131162139721.post-6963107680176187154</id><published>2017-05-27T08:39:00.003-07:00</published><updated>2017-05-27T08:39:24.604-07:00</updated><category scheme='http://schemas.google.com/g/2005#kind' term='http://schemas.google.com/blogger/2008/kind#post'/><title type='text'>SONG TITLE</title><content type='html'>SONG ARTIST</content><link rel='replies' type='application/atom+xml' href='https://yourpianobarsonglist.blogspot.com/feeds/6963107680176187154/comments/default' title='Post Comments'/><link rel='replies' type='text/html' href='http://yourpianobarsonglist.blogspot.com/2017/05/song-title-2.html#comment-form' title='0 Comments'/><link rel='edit' type='application/atom+xml' href='https://www.blogger.com/feeds/914891131162139721/posts/default/6963107680176187154'/><link rel='self' type='application/atom+xml' href='https://www.blogger.com/feeds/914891131162139721/posts/default/6963107680176187154'/><link rel='alternate' type='text/html' href='http://yourpianobarsonglist.blogspot.com/2017/05/song-title-2.html' title='SONG TITLE 2'/><author><name>Jonathan Tuzman</name><uri>https://www.blogger.com/profile/11107905425531958358</uri><email>noreply@blogger.com</email><gd:image rel='http://schemas.google.com/g/2005#thumbnail' width='35' height='35' src='//lh3.googleusercontent.com/zFdxGE77vvD2w5xHy6jkVuElKv-U9_9qLkRYK8OnbDeJPtjSZ82UPq5w6hJ-SA=s35'/></author><thr:total>0</thr:total></entry>"
		
		static let eachPost3 = "<entry><id>tag:blogger.com,1999:blog-914891131162139721.post-6963107680176187154</id><published>2017-05-27T08:39:00.003-07:00</published><updated>2017-05-27T08:39:24.604-07:00</updated><category scheme='http://schemas.google.com/g/2005#kind' term='http://schemas.google.com/blogger/2008/kind#post'/><title type='text'>SONG TITLE</title><content type='html'>SONG ARTIST</content><link rel='replies' type='application/atom+xml' href='https://yourpianobarsonglist.blogspot.com/feeds/6963107680176187154/comments/default' title='Post Comments'/><link rel='replies' type='text/html' href='http://yourpianobarsonglist.blogspot.com/2017/05/song-title-.html#comment-form' title='0 Comments'/><link rel='edit' type='application/atom+xml' href='https://www.blogger.com/feeds/914891131162139721/posts/default/6963107680176187154'/><link rel='self' type='application/atom+xml' href='https://www.blogger.com/feeds/914891131162139721/posts/default/6963107680176187154'/><link rel='alternate' type='text/html' href='http://yourpianobarsonglist.blogspot.com/2017/05/song-title-.html' title='SONG TITLE'/><author><name>Jonathan Tuzman</name><uri>https://www.blogger.com/profile/11107905425531958358</uri><email>noreply@blogger.com</email><gd:image rel='http://schemas.google.com/g/2005#thumbnail' width='35' height='35' src='//lh3.googleusercontent.com/zFdxGE77vvD2w5xHy6jkVuElKv-U9_9qLkRYK8OnbDeJPtjSZ82UPq5w6hJ-SA=s35'/></author><thr:total>0</thr:total></entry>"
		
		static let eachPost2 = "<entry><id>tag:blogger.com,1999:blog-914891131162139721.post-343456466211441902</id><published>2017-05-27T08:39:00.001-07:00</published><updated>2017-05-27T08:39:14.218-07:00</updated><category scheme='http://schemas.google.com/g/2005#kind' term='http://schemas.google.com/blogger/2008/kind#post'/><title type='text'>SONG TITLE</title><content type='html'>SONG ARTIST</content><link rel='replies' type='application/atom+xml' href='https://yourpianobarsonglist.blogspot.com/feeds/343456466211441902/comments/default' title='Post Comments'/><link rel='replies' type='text/html' href='http://yourpianobarsonglist.blogspot.com/2017/05/song-title-.html#comment-form' title='0 Comments'/><link rel='edit' type='application/atom+xml' href='https://www.blogger.com/feeds/914891131162139721/posts/default/343456466211441902'/><link rel='self' type='application/atom+xml' href='https://www.blogger.com/feeds/914891131162139721/posts/default/343456466211441902'/><link rel='alternate' type='text/html' href='http://yourpianobarsonglist.blogspot.com/2017/05/song-title-.html' title='SONG TITLE'/><author><name>Jonathan Tuzman</name><uri>https://www.blogger.com/profile/11107905425531958358</uri><email>noreply@blogger.com</email><gd:image rel='http://schemas.google.com/g/2005#thumbnail' width='35' height='35' src='//lh3.googleusercontent.com/zFdxGE77vvD2w5xHy6jkVuElKv-U9_9qLkRYK8OnbDeJPtjSZ82UPq5w6hJ-SA=s35'/></author><thr:total>0</thr:total></entry>"
		
		static var header: String! {
			let fileName = "header.xml" //this is the file. we will write to and read from it
			if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
				let path = dir.appendingPathComponent(fileName)
				do {
					return try String(contentsOf: path)
				}
				catch {
					print("Couldn't write file")
					return nil
				}
			}
			return nil
		}
	}
	
	class func blogPostOLD(for song: Song) -> String {
		var text = Blogger.eachPost2
		text = text.replacingOccurrences(of: Blogger.Post.title, with: song.title
			.replacingOccurrences(of: "&", with: "&amp;"))
		
		let artists = song.songDescription.components(separatedBy: " - ").last!
			.replacingOccurrences(of: "&", with: "&amp;")
		text = text.replacingOccurrences(of: Blogger.Post.artist, with: artists)
		/*
		let songNum = YPB.realmLocal.objects(Song.self).index(of: song)!
		text = text.replacingOccurrences(of: Blogger.Post.songID, with: Blogger.Post.songID + String(songNum))
		
		let songID = String(Int(Blogger.Post.basePostID)! + songNum)
		text = text.replacingOccurrences(of: Blogger.Post.basePostID2, with: songID)
		*/
		return text
	}
	
	class func createBlogFromXMLWithMultipleEntries() {
		
		let XMLSourceName = "blog with ALL songs.xml"
		
		if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
			// Get contents of importer that appears to work
			let origPath = dir.appendingPathComponent(XMLSourceName)
			let origText = try! String(contentsOf: origPath)
			var text = origText
			
			// For each songs, replace the placeholders with the info
			let allSongs = YPB.realmLocal.objects(Song.self)
			for song in allSongs {
				
				let descComponents = song.songDescription.fixXMLEscapes().components(separatedBy: " - ")
				guard let titleRange = text.range(of: Blogger.Post.title),
					let artistRange = text.range(of: Blogger.Post.artist)
					else { return }
				
				text = text.replacingCharacters(in: titleRange, with: descComponents[0])
				text = text.replacingCharacters(in: artistRange, with: descComponents[1])
			}

			// Write the file
			let newPath = dir.appendingPathComponent("blog.xml")
			try! text.write(to: newPath, atomically: false, encoding: String.Encoding.utf8)
		}
	}
	
	class func createBlogByReplacingEachEntry() {

		let allSongs = YPB.realmLocal.objects(Song.self)

		let XMLSourceName = "blog with 1 song.xml"
		let postsPerFile = 48
		let songsToWrite = allSongs.count
		let songsOnBlogSoFar = 300
		
		func blogPost(for song: Song) -> String {
			var post = Blogger.eachPost
			let descComponents = song.songDescription.fixXMLEscapes().components(separatedBy: " - ")
			let replacements = [Blogger.Post.title : "\(descComponents[0]) (\(descComponents[1]))",
				Blogger.Post.artist : "",
				Blogger.Post.songNumId : Blogger.Post.songNumId + String(allSongs.index(of: song)!)]
			
			for item in replacements {
				post = post.replacingOccurrences(of: item.key, with: item.value)
			}
			return post
		}
		
		func createNewFolder(named folderName: String) {
			
			if let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first {
				let dataPath = "\(path)/\(folderName)"
				do {
					try FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: false, attributes: nil)
					print("\(folderName) folder created")
				} catch let error as NSError {
					print(error.localizedDescription);
				}
			}
		}
		
		if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
			
			let folderName = "blogs - \(postsPerFile) songs per file"
			createNewFolder(named: folderName)
			
			let origPath = dir.appendingPathComponent(XMLSourceName)
			let origText = try! String(contentsOf: origPath)
			var fullText = origText
			
			for (index, song) in allSongs.enumerated() where index < songsToWrite && index > songsOnBlogSoFar {
				fullText = fullText.replacingOccurrences(of: Blogger.footer, with: blogPost(for: song) + Blogger.footer)
				if index % postsPerFile == 0 && index != 0 {
					let fileName = "blog #\(index / postsPerFile) (\(postsPerFile) per file).xml"
					let newPath = dir.appendingPathComponent("\(folderName)/\(fileName)")
					try! fullText.write(to: newPath, atomically: false, encoding: String.Encoding.utf8)
					fullText = origText
				}
			}
			
			let finalFileNumber = Int((songsToWrite - songsOnBlogSoFar) / postsPerFile) + 1
			let fileName = "blog #\(finalFileNumber) (\(postsPerFile) per file).xml"
			let newPath = dir.appendingPathComponent("\(folderName)/\(fileName)")
			try! fullText.write(to: newPath, atomically: false, encoding: String.Encoding.utf8)
		}
	}
	
	class func createBlogForSongs() {
		var text = Blogger.header!
		let allSongs = YPB.realmLocal.objects(Song.self)
		for song in allSongs where allSongs.index(of: song)! < 3 {
			text += blogPostOLD(for: song)
		}
		text += Blogger.footer
		
		let fileName = "blog.xml" //this is the file. we will write to and read from it
		if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
			let path = dir.appendingPathComponent(fileName)
			do {
				try text.write(to: path, atomically: false, encoding: String.Encoding.utf8)
			}
			catch {
				print("Couldn't write file")
			}
		}
		
	}
	class func simplyCreateXMLWithContentsOfOldXML() {
		let origBlog = "blog-05-27-2017.xml"
		if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
			let origBlogPath = dir.appendingPathComponent(origBlog)
			let origBlogContents = try! String(contentsOf: origBlogPath)
			let newBlog = "blog.xml"
			let newBlogPath = dir.appendingPathComponent(newBlog)
			try! origBlogContents.write(to: newBlogPath, atomically: false, encoding: String.Encoding.utf8)
		}
	}
}
