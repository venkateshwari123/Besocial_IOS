//
//  NewPostModel.swift
//  dub.ly
//
//  Created by Shivansh on 2/1/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

struct NewPostModel {
    var isEdit: Bool = false
    var postId: String?
    var caption:String = ""
    var location:String = ""
    var placeId:String = ""
    var category:CategoryListModel = CategoryListModel(modelData:[:])
    var channel:ChannelModel?
    var mediaPath:String = ""
    var cloudinaryPublicID:String = ""
    var isVideo = false
    var width:Int = 100
    var height:Int = 100
    var image:UIImage?
    var selectedAddress:AddressModel?
    var selectedAudio:Audio?
    var allowDownload = true
    var allowComment  = true
    
    var isPaid = false
    var postAmount:Int?
    
    var businessPostTypeId:String = ""
    var businessPrice:Double?
    var businessUrl:String = ""
    var businessCurrency:String = ""
    var businessButtonText:String = ""
    var businessButtonColor: String = ""
    
    
    
    
    
    
    
    
    
    
    
    
}
