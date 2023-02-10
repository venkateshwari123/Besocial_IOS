//
//  CardsViewController+UITablViewMethods.swift
//  StripeDemo
//
//  Created by Rahul Sharma on 27/12/19.
//  Copyright © 2019 stripe. All rights reserved.
//

import Foundation

extension CardsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let counts = viewModel.getNumberOfCards()
        if counts > 0{
            tableView.backgroundView = nil
            tableView.isScrollEnabled = true
        }
        else{
            setTableViewOrCollectionViewBackground(tableView: tableView, collectionView: nil, image: #imageLiteral(resourceName: "noCard"), labelText: "No Saved Cards".localized, labelWithImage: true, yPosition: self.view.center.y - 100)
            tableView.isScrollEnabled = false
        }
        // Get Number of Rows in TableView
        Helper.hidePI()
        return viewModel.getNumberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Check Cell Type
        // If it is Add New Card type then Create AddNewCardCell else CardCell
        //        if viewModel.checkCellTypeIsAddNewCard(at: indexPath.row) {
        //            if let cell = tableView.dequeueReusableCell(withIdentifier: "AddNewCardCell", for: indexPath) as? AddNewCardCell {
        //                cell.addNewCardButton.addTarget(self, action: #selector(addNewCard(sender:)), for: .touchUpInside)
        //                return cell
        //            }
        //        }
        // If cell type is not Add New Card type then check for Card Object
        // If card object got then create CardCell
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell", for: indexPath) as? CardCell else {return UITableViewCell()}
        if let card = viewModel.getCard(at: indexPath.row){
            cell.update(card, isDefault: indexPath.row == viewModel.getSelectedIndex() )
            cell.deleteCardButton.tag = indexPath.row
            cell.deleteCardButton.addTarget(self, action: #selector(deleted), for: .touchUpInside)
            cell.delegate = self
        }
        return cell
    }
    
    @objc func deleted(sender: UIButton){
        let alert = UIAlertController(title: "Delete Card".localized, message: "Are you sure you want to remove this card".localized + "?", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Yes".localized, style: .destructive, handler: { (UIAlertAction) in
            if let card = self.viewModel.getCard(at: sender.tag) {
                self.viewModel.deleteCardFromServer(card)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler: { (UIAlertAction) in
            
        }))
        if  UIApplication.getTopMostViewController()!.isKind(of: UIAlertController.self) {
            print("UIAlertController is already presented")
        }else{
            UIApplication.getTopMostViewController()?.present(alert, animated: true, completion: nil)
        }
    }
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        // Check cell type is Add New Card then can edit row should be false
//        if viewModel.checkCellTypeIsAddNewCard(at: indexPath.row) {
//            return false
//        }
//        // Check if cell for Apple Pay then can edit row should be false
//        if let card = viewModel.getCard(at: indexPath.row), card.isApplePay {
//            return false
//        }
//        // For all cards cell can edit should be true
//        return true
//    }

//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        switch editingStyle {
//        // If cell editing stype is delete then delete card
//        case .delete:
//            // Before delete card fetch card object.
//            // If card object is found then call API to delete card from server
//            // If you get success response then only delete card object from local reference
//            if let card = viewModel.getCard(at: indexPath.row) {
//                viewModel.deleteCardFromServer(card)
//            }
//        default: break
//        }
//    }
}

extension CardsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //change ui of selected cell
        viewModel.setSelectedIndex(indexPath.row)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let customView = UIView()
        customView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44)
        //customView.backgroundColor = .white
        customView.backgroundColor = UIColor.setColor(lightMode: "#FFFFFF", darkMode: AppColourStr.descriptionLabel)
        
        let label = UILabel(frame: CGRect(x: 20, y: 0, width: tableView.frame.width - 20, height: 44))
        label.text = "Saved Cards".localized
        label.font = Utility.Font.Regular.ofSize(14)
       // label.textColor = UIColor.hexStringToUIColor(hex: "#0C6F6D")
        label.textColor = UIColor.setColor(lightMode: AppColourStr.descriptionLabel, darkMode: "#FFFFFF")

        customView.addSubview(label)
        return customView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
}
