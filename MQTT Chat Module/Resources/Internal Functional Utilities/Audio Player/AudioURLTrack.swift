//
//  AudioURLTrack.swift
//  AudioPlayerManager
//
//  Created by Hans Seiffert on 02.08.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

open class AudioURLTrack: AudioTrack {

	// MARK: - Properties

	open var url: URL?

	// MARK: - Initialization

	public convenience init?(urlString: String) {
		self.init(url: URL(string: urlString))
	}

	public convenience init?(url: URL?) {
		guard url != nil else {
			return nil
		}
		self.init()
		self.url = url
	}

	open class func makeTracks(of urlStrings: [String], withStartIndex startIndex: Int) -> (tracks: [AudioURLTrack], startIndex: Int) {
		return self.makeTracks(of: AudioURLTrack.convertToURLs(urlStrings), withStartIndex: startIndex)
	}

	open class func makeTracks(of urls: [URL?], withStartIndex startIndex: Int) -> (tracks: [AudioURLTrack], startIndex: Int) {
		var reducedTracks = [AudioURLTrack]()
		var reducedStartIndex = startIndex
		// Iterate through all given URLs and create the tracks
		for index in 0..<urls.count {
			let _url = urls[index]
			if let _playerItem = AudioURLTrack(url: _url) {
				reducedTracks.append(_playerItem)
			} else if (index <= startIndex && reducedStartIndex > 0) {
				// There is a problem with the URL. Ignore the URL and shift the start index if it is higher than the current index
				reducedStartIndex -= 1
			}
		}

		return (tracks: reducedTracks, startIndex: reducedStartIndex)
	}

	// MARK: - Lifecycle

	override func prepareForPlaying(_ avPlayerItem: AVPlayerItem) {
		super.prepareForPlaying(avPlayerItem)
		// Listen to the timedMetadata initialization. We can extract the meta data then
		self.playerItem?.addObserver(self, forKeyPath: Keys.timedMetadata, options: NSKeyValueObservingOptions.initial, context: nil)
	}

	override func cleanupAfterPlaying() {
		// Remove the timedMetadata observer as the AVPlayerItem will be released now
		self.playerItem?.removeObserver(self, forKeyPath: Keys.timedMetadata, context: nil)
		super.cleanupAfterPlaying()
	}

	open override func avPlayerItem() -> AVPlayerItem? {
		if let _url = self.url {
			return AVPlayerItem(url: _url)
		}

		return nil
	}

	// MARK: - Now playing info

	open override func initNowPlayingInfo() {
		super.initNowPlayingInfo()

		self.nowPlayingInfo?[MPMediaItemPropertyTitle] = self.url?.lastPathComponent as NSObject?
	}

	// MARK: - Helper

	open override func identifier() -> String? {
		if let _urlAbsoluteString = self.url?.absoluteString {
			return _urlAbsoluteString
		}
		return super.identifier()
	}

	open class func convertToURLs(_ strings: [String]) -> [URL?] {
		var urls: [URL?] = []
		for string in strings {
			urls.append(URL(string: string))
		}
		return urls
	}

	open class func firstPlayableItem(_ urls: [URL?], at startIndex: Int) -> (track: AudioURLTrack, index: Int)? {
		// Iterate through all URLs and check whether it's not nil
		for index in startIndex..<urls.count {
			if let _track = AudioURLTrack(url: urls[index]) {
				// Create the track from the first playable URL and return it.
				return (track: _track, index: index)
			}
		}
		// There is no playable URL -> reuturn nil then
		return nil
	}

	// MARK: - PRIVATE -

	fileprivate struct Keys {
		static let timedMetadata		= "timedMetadata"
	}

	fileprivate func extractMetadata() {
//        print("Extracting meta data of player item with url: \(url)")
		for metadataItem in (self.playerItem?.asset.commonMetadata ?? []) {
			if let _key = convertFromOptionalAVMetadataKey(metadataItem.commonKey) {
				switch _key {
				case convertFromAVMetadataKey(AVMetadataKey.commonKeyTitle)		: self.nowPlayingInfo?[MPMediaItemPropertyTitle] = metadataItem.stringValue as NSObject?
				case convertFromAVMetadataKey(AVMetadataKey.commonKeyAlbumName)	: self.nowPlayingInfo?[MPMediaItemPropertyAlbumTitle] = metadataItem.stringValue as NSObject?
				case convertFromAVMetadataKey(AVMetadataKey.commonKeyArtist)		: self.nowPlayingInfo?[MPMediaItemPropertyArtist] = metadataItem.stringValue as NSObject?
				case convertFromAVMetadataKey(AVMetadataKey.commonKeyArtwork)		:
					if
						let _data = metadataItem.dataValue,
						let _image = UIImage(data: _data) {
							self.nowPlayingInfo?[MPMediaItemPropertyArtwork] = self.mediaItemArtwork(from: _image)
					}
				default								: continue
				}
			}
		}
		// Inform the player about the updated meta data
		AudioPlayerManager.shared.didUpdateMetadata()
	}

	fileprivate func mediaItemArtwork(from image: UIImage) -> MPMediaItemArtwork {
		if #available(iOS 10.0, *) {
			return MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (size: CGSize) -> UIImage in
				return image
			})
		} else {
			return MPMediaItemArtwork(image: image)
		}
	}
}

// MARK: - KVO

extension AudioURLTrack {

	override open func observeValue(forKeyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
		if (forKeyPath == Keys.timedMetadata) {
			// Extract the meta data if the timedMetadata changed
			self.extractMetadata()
		}
	}
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromOptionalAVMetadataKey(_ input: AVMetadataKey?) -> String? {
	guard let input = input else { return nil }
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMetadataKey(_ input: AVMetadataKey) -> String {
	return input.rawValue
}
