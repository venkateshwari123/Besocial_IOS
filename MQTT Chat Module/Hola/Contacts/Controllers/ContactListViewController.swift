//
//  ViewController.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 08/07/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import SwiftyJSON

class ContactListViewController: UIViewController {
    
    @IBOutlet weak var tableViewOutlet: UITableView!
    @IBOutlet weak var cancelBtnOutlet: UIButton!
    
    var userLists:[Contact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelBtnOutlet.setTitle("Cancel".localized, for: .normal)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Contact.getAllUsers { (contactsArray) in
            self.userLists.removeAll()
            self.userLists.append(contentsOf: contactsArray)
            self.tableViewOutlet.reloadData()
        }
    }
    
    /*
     Bug Name:- network handling
     Fix Date:- 20/04/21
     Fix By  :- Nikunj C
     Description of Fix:- check connectivity and show popup for no internet
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Helper.checkConnectionAvaibility(view: self.view)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cellSelected(withRow row: Int) {
        let contactObj = self.userLists[row]
        self.performSegue(withIdentifier: "openChatController", sender: contactObj)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let controller = segue.destination as? ChatViewController {
//            guard let favoriteObj = sender as? Contacts else { return }
//            controller.favoriteObj = favoriteObj
//        }
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ContactListViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell") as! UserTableViewCell
        cell.userDetails = self.userLists[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.cellSelected(withRow: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userLists.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
