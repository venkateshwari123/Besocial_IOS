//
//  SaveCollectionViewModel.swift
//  Starchat
//
//  Created by 3Embed on 30/07/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class SaveCollectionViewModel: NSObject {
    
    private let api: SavedCollectionAPI
    
    //MARK: - Events
    var didError: ((CustomErrorStruct) -> Void)?
    var didUpdateDict : (([String : Any]) -> Void)?
    var didUpdate: (([SavedCollectionModel],[BookMark]) -> Void)?
    var didUpdateBookmarks: (([BookMark]) -> Void)?
    var didUpdateCollection: (([Collection]) -> Void)?
    
    
    
    init(api:SavedCollectionAPI) {
        self.api = api
    }
    
    func getUserCollections(offset : Int) {
        self.api.getSavedCollections(offset) { (collections, error) in
            if let collections = collections {
                if let didUpdate = self.didUpdate {
                    var arrPosts : [SavedCollectionModel] = []
                    var arrBookmarks : [BookMark] = []
                    if let dict = collections as? [String : Any]{
                        if var jsonPosts = dict["data"] as? [[String : Any]]{
                            if jsonPosts.count > 0{
                                if let jsonBookmarks = jsonPosts[0]["images"] as? [String]{
                                    jsonBookmarks.forEach({ (obj) in
                                        let savedBookmark = BookMark.init(image: obj)
                                        arrBookmarks.append(savedBookmark)
                                    })
                                }
                                jsonPosts.removeFirst()
                            }
                            jsonPosts.forEach({ (obj) in
                                let savedObj = SavedCollectionModel.init(modelData: obj)
                                arrPosts.append(savedObj)
                            })
                        }
//                        if let jsonBookmarks = dict["posts"] as? [[String : Any]]{
//                            jsonBookmarks.forEach({ (obj) in
//                                let savedBookmark = BookMark.init(modelData: obj)
//                                arrBookmarks.append(savedBookmark)
//                            })
//                        }
                    }
                    didUpdate(arrPosts, arrBookmarks)
                }
            } else {
                if let error = error, let didError = self.didError {
                    didError(error)
                }
            }
        }
    }
    
    func addBookmark(_ bookmark : String) {
        self.api.addPostToBookmarks(bookmark) { (collections, error) in
            if let collections = collections {
                if let didUpdate = self.didUpdateDict {
                    didUpdate(collections as! [String : Any])
                }
            } else {
                if let error = error, let didError = self.didError {
                    
                    didError(error)
                }
            }
        }
    }
    
    func removeBookmark(_ bookmark : String) {
        self.api.removePostFromBookmarks(bookmark) { (collections, error) in
            if let collections = collections {
                if let didUpdate = self.didUpdateDict {
                    didUpdate(collections as! [String : Any])
                }
            } else {
                if let error = error, let didError = self.didError {
                    didError(error)
                }
            }
        }
    }
    
    func getUserBookmarks() {
        self.api.getBookmarkedPosts() { (collections, error) in
            if let collections = collections {
                if let didUpdate = self.didUpdateBookmarks {
                    var arrPosts : [BookMark] = []
                    if let jsonPosts = collections as? [[String : Any]]{
                        jsonPosts.forEach({ (obj) in
                            let savedObj = BookMark.init(modelData: obj)
                            arrPosts.append(savedObj)
                        })
                    }
                    didUpdate(arrPosts)
                }
            } else {
                if let error = error, let didError = self.didError {
                    if error.code == 204 {
                        if let didUpdate = self.didUpdateBookmarks {
                        didUpdate([])
                        }
                    }
                    didError(error)
                }
            }
        }
    }
    
    func getUserBookmarksToAddinCollection(collectionId : String) {
        self.api.getBookmarkedPostsToAdd(collectionId) { (collections, error) in
            if let collections = collections {
                if let didUpdate = self.didUpdateBookmarks {
                    var arrPosts : [BookMark] = []
                    if let jsonPosts = collections as? [[String : Any]]{
                        jsonPosts.forEach({ (obj) in
                            let savedObj = BookMark.init(modelData: obj)
                            arrPosts.append(savedObj)
                        })
                    }
                    didUpdate(arrPosts)
                }
            } else {
                if let error = error, let didError = self.didError {
                    didError(error)
                }
            }
        }
    }
    
    func getCollectionDetails(_ collectionId : String) {
        self.api.getCollectionDetails(collectionId) { (collectionObj, error) in
            if let collection = collectionObj {
                if let didUpdate = self.didUpdateCollection {
                    var arrPosts : [Collection] = []
                    if let jsonPosts = collection as? [[String : Any]]{
                        jsonPosts.forEach({ (obj) in
                            let savedObj = Collection.init(modelData: obj)
                            arrPosts.append(savedObj)
                        })
                    }
                    didUpdate(arrPosts)
                }
            } else {
                if let error = error, let didError = self.didError {
                    didError(error)
                }
            }
        }
    }
    
    func createCollection(_ coverImage : String, collectionName : String, postIds : [String]) {
        self.api.createNewCollection(coverImage, collectionName: collectionName, postIds: postIds) { (response, error) in
            if let response = response {
                if let didUpdate = self.didUpdateDict {
                    didUpdate(response as! [String : Any])
                }
            } else {
                if let error = error, let didError = self.didError {
                    didError(error)
                }
            }
        }
    }
    
    func addPostsToCollection(_ collectionId : String, postIds : [String]) {
        self.api.addPostsToCollection(collectionId, postIds: postIds) { (response, error) in
            if let response = response {
                if let didUpdate = self.didUpdateDict {
                    didUpdate(response as! [String : Any])
                }
            } else {
                if let error = error, let didError = self.didError {
                    didError(error)
                }
            }
        }
    }
    
    func editCollection(_ coverImage : String, collectionName : String, collectionId : String) {
        self.api.editCollection(coverImage, collectionName: collectionName, collectionId: collectionId) { (response, error) in
            if let response = response {
                if let didUpdate = self.didUpdateDict {
                    didUpdate(response as! [String : Any])
                }
            } else {
                if let error = error, let didError = self.didError {
                    didError(error)
                }
            }
        }
    }
    
    func deleteCollection(_ collectionId : String) {
        self.api.deleteCollection(collectionId) { (response, error) in
            if let response = response {
                if let didUpdate = self.didUpdateDict {
                    didUpdate(response as! [String : Any])
                }
            } else {
                if let error = error, let didError = self.didError {
                    didError(error)
                }
            }
        }
    }
    
}
