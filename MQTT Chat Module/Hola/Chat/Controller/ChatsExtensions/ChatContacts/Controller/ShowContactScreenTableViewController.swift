//
//  ShowContactScreenTableViewController.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 14/12/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit

protocol ShowContactScreenDelegate {
    func didCancelCliked()
    func didSendCliked()
}

class ShowContactScreenTableViewController: UITableViewController {
    
    var mobileNumber:[String] = []
    var typeLable:[String] = []
    var name:String?
    var delegate:ShowContactScreenDelegate?
    
    @IBOutlet weak var cancelBtnOutlet: UIBarButtonItem!
    @IBOutlet weak var sendBtnOutlet: UIBarButtonItem!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        cancelBtnOutlet.title = "Cancel".localized
        sendBtnOutlet.title = "Send".localized
    }

    @IBAction func cancelCliked(_ sender: Any) {
        
        delegate?.didCancelCliked()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendCliked(_ sender: Any) {
        delegate?.didSendCliked()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return mobileNumber.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewheader = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: 60))
        let label = UILabel.init(frame: CGRect.init(x: 50 , y: 20, width: self.view.frame.size.width - 50, height: 40))
        label.text = name
        label.font = UIFont.systemFont(ofSize: 18)
        viewheader.addSubview(label)
        return viewheader
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShareContactcell", for: indexPath) as! ShareContactcell
        cell.phoneLabel.text = typeLable[indexPath.row]
        cell.phoneNumber.text = mobileNumber[indexPath.row] 
        return cell
    }
}
