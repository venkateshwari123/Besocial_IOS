//
//  DoodleViewModel.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 17/12/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit

class DoodleViewModel: NSObject {

    var chatObj: ChatViewController?
    
    init (_ chatob: ChatViewController){
        chatObj = chatob
    }
    
    
    func OpenDoodleView(){
        
        let storty = UIStoryboard.init(name:AppConstants.StoryBoardIds.chat, bundle: nil)
        let nav =   storty.instantiateViewController(withIdentifier: "doodleNavigationView") as? UINavigationController
         let shareView =   nav?.topViewController as! DoodleViewController
        shareView.delegate = self.chatObj
        nav?.modalPresentationStyle = .fullScreen
        chatObj?.present(nav!, animated: true, completion: nil)
    }
    

}
