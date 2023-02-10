//
//  WalletAlertViewController.swift
//  Yelo
//
//  Created by Rahul Sharma on 24/04/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit
protocol WalletAlertVCDelegate {
    func typeSelected(type: WalletViewModel.type)
}

class WalletAlertViewController: BaseViewController{
    
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var customViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertHideButton: UIButton!
    
    let alertVM = WalletAlertViewModel()
    var delegate : WalletAlertVCDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    func setup() {
        self.view.backgroundColor = .clear
        customView.makeCornerRadious(readious: 5)
        customView.clipsToBounds = true
        
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.animateBackground()
        }
        
        customViewHeightConstraint.constant = CGFloat(60 * alertVM.typeName.count)
    }
    
    @IBAction func alertHideButtonAction(_ sender: Any) {
        animateOutBackground()
    }
}

extension WalletAlertViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alertVM.typeName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AlertTVCell", for: indexPath) as? AlertTVCell else {return UITableViewCell()}
        cell.configureCell(typeName: alertVM.typeName[indexPath.row].title, isSelected: alertVM.selectedType == alertVM.typeName[indexPath.row].title)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.typeSelected(type: alertVM.typeName[indexPath.row])
        animateOutBackground()
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc func animateBackground() {
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        }
    }
    
    @objc func animateOutBackground() {
        UIView.animate(withDuration: 0.15, animations: {
            self.view.backgroundColor = .clear
        }) { (done) in
            if done{
                self.dismiss(animated: true)
            }
        }
    }
}
