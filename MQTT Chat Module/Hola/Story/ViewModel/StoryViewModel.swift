//
//  StoryViewModel.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 09/02/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import Foundation
class StoryViewModel {
    
    var offset: Int = -20
    let limit: Int = 20

    var storyViewersListArray = [storyViewedUser]()
    
    /// To get post service response
    ///
    /// - Parameters:
    ///   - strUrl: posts string url
    ///   - complitation: complitation handle
    func getStoryViewersList(storyId: String,strUrl: String, complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        self.offset = offset + 20
        Helper.showPI()
        let api = SocialAPI()
        let url = strUrl + "?storyId=\(storyId)&skip=\(offset)&limit=\(limit)"
        api.getSocialData(withURL: url, params: [:]) { (response, error) in
            if let result = response as? [Any]{
                self.setDataInStoryWatchedListModel(modeldataArray: result)
                complitation(true, nil, false)
            }else if let error = error{
                print(error.localizedDescription)
                self.offset = self.offset - 20
                if error.code == 204{
                    complitation(false, error, false)
                }else{
                    complitation(false, error, true)
                }
            }
            Helper.hidePI()
        }
    }
    
    /// To set data in category list model array
    ///
    /// - Parameter modeldataArray: model data array to set in model
    private func setDataInStoryWatchedListModel(modeldataArray: [Any]){
        if offset == 0{
            self.storyViewersListArray.removeAll()
        }
        for modelData in modeldataArray{
            guard let data = modelData as? [String : Any] else{return}
            let storyViewModel = storyViewedUser(userDetails: data)
            self.storyViewersListArray.append(storyViewModel)
        }
    }
    
}
