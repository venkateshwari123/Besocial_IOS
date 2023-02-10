
//
//  AudioListViewController.swift
//  dub.ly
//
//  Created by DINESH GUPTHA on 12/18/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Locksmith
import AVKit

extension AudioListViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.hotSongsBtn.isSelected {
            return self.audioList.count
        } else {
            return self.allFavouriteAudios.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var respAudio:Audio
        if self.hotSongsBtn.isSelected {
            respAudio = self.audioList[indexPath.row]
        } else {
            respAudio = self.allFavouriteAudios[indexPath.row]
        }
        
        let audioCell =  tableView.dequeueReusableCell(withIdentifier:"AudioListTableViewCell") as! AudioListTableViewCell
        audioCell.setuSoundDetails(audio: respAudio)
        if(selectedAudioID == respAudio.id) {
            audioCell.dubBtn.isHidden = false
            audioCell.dubBtmheightConstraint.constant = 55.0
            if audioPlayer != nil {
                if(audioPlayer!.isPlaying) {
                    audioCell.playButton.isSelected = true
                } else {
                    audioCell.playButton.isSelected = false
                }
            }
        } else {
            audioCell.playButton.isSelected = false
            audioCell.dubBtn.isHidden = true
            audioCell.dubBtmheightConstraint.constant = 0.0
            self.view.layoutIfNeeded()
        }
        
        audioCell.favouriteBtn.isSelected = respAudio.isFavourite
        
        audioCell.dubBtn.tag = indexPath.row
        audioCell.playButton.tag = indexPath.row
        audioCell.favouriteBtn.tag = indexPath.row
        return audioCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedAudio:Audio
        if self.hotSongsBtn.isSelected {
            
            selectedAudio = self.audioList[indexPath.row]
        } else {
            selectedAudio = self.allFavouriteAudios[indexPath.row]
        }
        
        if(selectedAudio.id == selectedAudioID) {
            if audioPlayer != nil {
                if audioPlayer!.isPlaying {
                    audioPlayer?.pause()
                } else {
                    audioPlayer?.play()
                }
            }
        } else {
            selectedAudioID = selectedAudio.id
            audioPlayer?.pause()
            playSelectedSound(selectedAudio:selectedAudio)
        }
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var respAudio:Audio
        if self.hotSongsBtn.isSelected {
            respAudio = self.audioList[indexPath.row]
        } else {
            respAudio = self.allFavouriteAudios[indexPath.row]
        }
        
        if(selectedAudioID == respAudio.id) {
            print("height: 140 at index: \(indexPath.row)\n\n\n")
            return 140
        }
        print("height: 90 at index: \(indexPath.row)\n\n\n")
        return 90
    }
    
    func saveAudioAndDismiss(selectedAudio:Audio) {
        if let audioUrl = URL(string: selectedAudio.url) {
            
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            print(destinationUrl)
            
            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
                
                DispatchQueue.main.async {
                    self.delegate?.selectedAudio(selectedAudio:selectedAudio)
                    self.dismiss(animated: true, completion: nil)
                }
                
                // if the file doesn't exist
            } else {
                
                // you can use NSURLSession.sharedSession to download the data asynchronously
                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else { return }
                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        print("File moved to documents folder")
                        DispatchQueue.main.async {
                            self.delegate?.selectedAudio(selectedAudio:selectedAudio)
                            self.dismiss(animated: true, completion: nil)
                        }
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }).resume()
            }
        }
        
    }
    
    func downloadFileFromURL(selectedAudio:Audio){
        let url = URL(string: selectedAudio.url)
        let session = URLSession.shared
        let task = session.dataTask(with:url!) { (data, response, error) -> Void in
            DispatchQueue.main.async {
                self.delegate?.selectedAudio(selectedAudio:selectedAudio)
                self.dismiss(animated: true, completion: nil)
            }
        }
        task.resume()
    }
}


extension AudioListViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allAudioCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let audioCatCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioCategoryCollectionViewCell", for: indexPath) as! AudioCategoryCollectionViewCell
        let respCategory = allAudioCategories[indexPath.row]
        audioCatCell.categoryName.text = respCategory.categoryName
        audioCatCell.categoryImageView?.setImageOn(imageUrl: respCategory.categoryImageUrl, defaultImage:#imageLiteral(resourceName: "defaultPicture"))
        return audioCatCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = self.view.frame.size.width - 20
        return CGSize(width:totalWidth/4,height:totalWidth/4)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.audioPlayer?.pause()
        let audioListVc = self.storyboard?.instantiateViewController(withIdentifier: "AudioListViewController") as! AudioListViewController
        audioListVc.isAudioListForCategory = true
        audioListVc.delegate = delegate
        audioListVc.audioCategory = allAudioCategories[indexPath.row]
        self.navigationController?.pushViewController(audioListVc, animated: true)
    }
}
