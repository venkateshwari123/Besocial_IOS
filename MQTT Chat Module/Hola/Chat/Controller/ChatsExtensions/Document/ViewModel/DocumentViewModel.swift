//
//  DocumentViewModel.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 20/12/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit

protocol documentDelegate {
    func didPickDocument(docUrl:URL)
}

class DocumentViewModel: NSObject {
    
    var chatObj:ChatViewController?
    var delegate:documentDelegate?
    
    init(_ chatob:ChatViewController ) {
      self.chatObj = chatob
    }
    
    func openDocumentView(){
        
        let document = UIDocumentMenuViewController.init(documentTypes: ["public.text"], in: .import)
        document.delegate = self
        self.chatObj?.present(document, animated: true, completion: nil)
    }
}


extension DocumentViewModel:UIDocumentMenuDelegate,UIDocumentPickerDelegate{
    
    
    func documentMenuWasCancelled(_ documentMenu: UIDocumentMenuViewController) {
        
    }
    
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        
        let docPicker = UIDocumentPickerViewController.init(documentTypes: ["public.image", "public.audio", "public.movie", "public.text", "public.item", "public.content", "public.source-code"], in: .import)
        docPicker.delegate = self
        self.chatObj?.present(docPicker, animated: true, completion: nil)
    }
    
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        delegate?.didPickDocument(docUrl: url)
    }
    
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        //chatObj?.dismiss(animated: true, completion: nil)
    }
    
}
