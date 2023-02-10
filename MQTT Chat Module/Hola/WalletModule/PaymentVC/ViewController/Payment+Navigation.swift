//
//  Payment+Navigation.swift
//  Yelo
//
//  Created by Rahul Sharma on 26/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import Foundation


extension PaymentViewController {
    
    
    func navigateToAddCardVC(){
        let storyboard = UIStoryboard(name: "AddCard", bundle: nil)
        // Check userId and AddCardViewController object from identifier
        guard let addCardVC = storyboard.instantiateViewController(withIdentifier: String(describing: AddCardViewController.self)) as? AddCardViewController else { return }
        
        addCardVC.viewModel.setUserId(Utility.getUserid() ?? "")
        
        addCardVC.cardDelegate = self
        self.navigationController?.pushViewController(addCardVC, animated: true)
    }
    
    func navigateToRechargeVC(){
        
    }
    
    func navigateToSuccessVC(){
        
    }
}

extension PaymentViewController: CardDelegate {
    func add(new card: Card) {
        cardsVM.update(new: card)
        tableView.reloadData()
    }
}
