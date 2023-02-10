//
//  LanguageChooseViewController.swift
//  Do Chat
//
//  Created by Rahul Sharma on 26/06/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import UIKit
import Locksmith
class LanguageChooseViewController: UIViewController {

    
    @IBOutlet weak var languageSearchBar: UISearchBar!
    @IBOutlet weak var languageTableView: UITableView!
    @IBOutlet weak var navigationTitleLabel: UILabel!
    
    var langChooseViewModel = LanguageChooseViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUP()
        navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: "Choose your language".localized)
        self.languageTableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        
    }
    
    func setUP(){
        langChooseViewModel.getLanguages { (success, error) in
            if success{
                self.languageTableView.reloadData()
            }
        }
    }
    
    @IBAction func backButtonActn(_ sender: Any) {
            self.navigationController?.popViewController(animated: true)
    }

}

extension LanguageChooseViewController: UITableViewDelegate,UITableViewDataSource{
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return langChooseViewModel.langArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "languageCell", for: indexPath)
        cell.textLabel?.text = langChooseViewModel.langArr[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlertPopUpOfChangeLanguage(index: indexPath.row)
    }
    
    /// Show alert for delete  operation confiration from user
    func showAlertPopUpOfChangeLanguage(index:Int){
        let alert = UIAlertController(title: nil, message: Strings.changeLangMessage.localized, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Strings.ok.localized, style: .default) { (action) in
            let selectedLanguage = self.langChooseViewModel.langArr[index].code
            UserDefaults.standard.setValue(selectedLanguage, forKey: AppConstants.UserDefaults.currentLang)
            self.langChooseViewModel.chooseLanguage(name: self.langChooseViewModel.langArr[index].name, code: self.langChooseViewModel.langArr[index].code)
            Utility.setLanguageCode(lang: self.langChooseViewModel.langArr[index].code)
            Route.rootToHomeVC()
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}

