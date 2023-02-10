//
//  DownloadDocumentViewController.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 26/02/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import UIKit
import QuickLook
class DownloadDocumentViewController: UIViewController,UIDocumentInteractionControllerDelegate,URLSessionDelegate {

    @IBOutlet weak var tblFileList: UITableView!
    var docMVMObj : DocumentMessageViewModal!
    let fileNames = [String]()
    var fileURLs = [NSURL]()
    let quickLookController = QLPreviewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
//        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backGround")
//        backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)\
        configureTableView()
      if let fileURL = docMVMObj.getFileURL() {
         let url:URL = URL(string: fileURL)!
        DispatchQueue.main.async {
            Helper.showPI(_message: " Downloading".localized + "... ")
        }
        
        loadFileAsync(url: url) { (path, error) in
//            print(path)
            DispatchQueue.main.async {
            Helper.hidePI()
            }
            
            if error == nil {
//                var formattedPath = path?.replace(target: "docx", withString: ".docx")
//            var formattedPath = path?.replace(target: "docx", withString: ".docx")
                let pathUrl = NSURL(fileURLWithPath: path!)
                
                self.fileURLs.append(pathUrl)
                DispatchQueue.main.async {
                self.tblFileList.reloadData()
                }
                
             }
            
            
            print("Downloaded")
        }
    }
    }
    
    // MARK: Custom Methods
    
    func configureTableView() {
        tblFileList.delegate = self
        tblFileList.dataSource = self
        tblFileList.register(UINib(nibName: "FileListCell", bundle: nil), forCellReuseIdentifier: "idCellFile")
        tblFileList.tableFooterView = UIView()
        tblFileList.reloadData()
    }
    
    
    func loadFileAsync(url: URL, completion: @escaping (String?, Error?) -> Void)
    {
    let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    
    let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)

    if FileManager().fileExists(atPath: destinationUrl.path)
    {
    completion(destinationUrl.path, nil)
    }
    else
    {
    let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    let task = session.dataTask(with: request, completionHandler:
    {
    data, response, error in
    if error == nil
    {
    if let response = response as? HTTPURLResponse
    {
    if response.statusCode == 200
    {
    if let data = data
    {
    if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
    {
    completion(destinationUrl.path, error)
    }
    else
    {
    completion(destinationUrl.path, error)
    }
    }
    else
    {
    completion(destinationUrl.path, error)
    }
    }
    }
    }
    else
    {
    completion(destinationUrl.path, error)
    }
    })
    task.resume()
    }
    }
}
//    func readwrite() {
//         // Do any additional setup after loading the view.
//
//        if let fileURL = docMVMObj.getFileURL() {
//
////                    let url:URL = URL(string: fileURL)!
//                    let url = URL(string: fileURL)
//
//                           let task = URLSession.shared.downloadTask(with: url!) { (urlresponse, response, error) in
//
//                               guard let orginalUrl = urlresponse else {return}
//
//                               do {
//                                   //get path to directory
//                                   let path = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//                                   //Giving name to file
//                                   let newUrl = path.appendingPathComponent("myTextFile")
//                                   //Move file from old to new url
//                                   try FileManager.default.moveItem(at: orginalUrl, to: newUrl)
//                               } catch {
//                                print(error.localizedDescription); return}
//                           }
//                           task.resume()
//                }
//
//
//
//        //READING AND WRITING
//        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
//
//        do {
//            let fileUrls = try FileManager.default.contentsOfDirectory(at: path!, includingPropertiesForKeys: nil)
//
//            //Read the text
//            let textContent = try String(contentsOf: fileUrls[0], encoding: .utf8)
//            print (textContent)
//
//            //Write text
//            let newText = textContent + " Here is some more text for you."
//            try newText.write(to: fileUrls[0], atomically: false, encoding: .utf8)
//
//            //Reading a second time
//            //Read the text
//            let textContent2 = try String(contentsOf: fileUrls[0], encoding: .utf8)
//            print (textContent2)
//
//        } catch {print ("ERROR")}
//    }
//
//    func startDownLoad() {
//
//        if let fileURL = docMVMObj.getFileURL() {
//
//            let url:URL = URL(string: fileURL)!
//            downloadTask = backgroundSession.downloadTask(with: url)
//            downloadTask.resume()
//        }
//    }
//
//    // 1
//    func urlSession(_ session: URLSession,
//                        downloadTask: URLSessionDownloadTask,
//                        didFinishDownloadingTo location: URL){
//
//    let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
//    let documentDirectoryPath:String = path[0]
//    let fileManager = FileManager()
//
//    let destinationURLForFile = URL(fileURLWithPath: documentDirectoryPath.appendingFormat("/file.docx"))
//
//    if fileManager.fileExists(atPath: destinationURLForFile.path){
//         showFileWithPath(path: destinationURLForFile.path)
//        }
//    else{
//          do {
//               try fileManager.moveItem(at: location, to: destinationURLForFile)
//               // show file
//               showFileWithPath(path: destinationURLForFile.path)
//          }catch{
//               print("An error occurred while moving file to destination url")
//          }
//       }
//    }
//    // 2
////    func urlSession(_ session: URLSession,
////                   downloadTask: URLSessionDownloadTask,
////                   didWriteData bytesWritten: Int64,
////                   totalBytesWritten: Int64,
////                   totalBytesExpectedToWrite: Int64){
//////       progressView.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
////    }
////
////
//    func showFileWithPath(path: String){
//        let isFileFound:Bool? = FileManager.default.fileExists(atPath: path)
//        if isFileFound == true{
//            let viewer = UIDocumentInteractionController(url: URL(fileURLWithPath: path))
//            viewer.delegate = self
//            viewer.presentPreview(animated: true)
//        }
//    }
////
//    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController
//    {
//        return self
//    }
////
//    func urlSession(_ session: URLSession,
//                     task: URLSessionTask,
//                     didCompleteWithError error: Error?){
//       downloadTask = nil
////       progressView.setProgress(0.0, animated: true)
//       if (error != nil) {
//           print(error!.localizedDescription)
//       }else{
//           print("The task finished transferring data successfully")
//       }
//    }
//
//
//    @IBAction func pause(sender: AnyObject) {
//            if downloadTask != nil{
//                downloadTask.suspend()
//            }
//    }
//    @IBAction func resume(sender: AnyObject) {
//            if downloadTask != nil{
//                downloadTask.resume()
//            }
//    }
//    @IBAction func cancel(sender: AnyObject) {
//            if downloadTask != nil{
//                downloadTask.cancel()
//            }
//    }

extension DownloadDocumentViewController:  UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileURLs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idCellFile", for: indexPath as IndexPath)
        cell.textLabel?.text = self.docMVMObj.getDocTypeText()
        cell.detailTextLabel?.text = self.docMVMObj.getFileName()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      //  if QLPreviewController.canPreview(fileURLs[indexPath.row]) {
        
            quickLookController.currentPreviewItemIndex = indexPath.row
            navigationController?.pushViewController(quickLookController, animated: true)
      //  }
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
    
}

extension DownloadDocumentViewController: QLPreviewControllerDataSource
{
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return fileURLs.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return fileURLs[index]
    }
    
    
}
