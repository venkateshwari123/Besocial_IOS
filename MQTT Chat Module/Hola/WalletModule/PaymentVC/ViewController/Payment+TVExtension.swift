//
//  Payment+TVExtension.swift
//  Yelo
//
//  Created by Rahul Sharma on 26/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//


import UIKit

extension PaymentViewController:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return paymentVM.getPaymentTypes().count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let paymentType = paymentVM.getPaymentTypes()[section]
        switch  paymentType{
        case .card:
            return cardVM.getNumberOfCards() == 0 ? 1 : cardVM.getNumberOfCards() + 1
        case .wallet:
            return 2
        case .cod:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let paymentType = paymentVM.getPaymentTypes()[indexPath.section]
        
        
        switch paymentType {
        case .card:
            let cards = cardVM.allCards()
            if indexPath.row == cards.count{ // last cell
                if let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentMethodAddButtonTVCell", for: indexPath) as? PaymentMethodAddButtonTVCell{
                    cell.configureCell(text: "   Add Card   ")
                    cell.button.addTarget(self, action: #selector(addCardAction), for: .touchUpInside)
                    return cell
                }
            }
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentMethodTableViewCell", for: indexPath) as? PaymentMethodTableViewCell{
                
                cell.configureCell(isSelected: false, text: cards[indexPath.row].last4 ?? "", type: PaymentTypes.card)
                return cell
            }
            break
        case .wallet:
            
            if indexPath.row == 1{ // last cell
                if let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentMethodAddButtonTVCell", for: indexPath) as? PaymentMethodAddButtonTVCell{
                    cell.configureCell(text: "   Add Money   ")
                    cell.button.addTarget(self, action: #selector(addMoneyAction), for: .touchUpInside)
                    return cell
                }
            }
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentMethodTableViewCell", for: indexPath) as? PaymentMethodTableViewCell{
                
                cell.configureCell(isSelected: false, text: "Your Wallet Balance:" , type: PaymentTypes.wallet)
                return cell
            }
            
            break
        case .cod:
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentMethodTableViewCell", for: indexPath) as? PaymentMethodTableViewCell{
                
                cell.configureCell(isSelected: false, text: "Your Wallet Balance:" , type: PaymentTypes.cod)
                return cell
            }
            break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let paymentType = paymentVM.getPaymentTypes()[indexPath.section]
//        if paymentType != .wallet,!(paymentType == .card && indexPath.row == 0){
//            isSelectedWallet = walletBalance >= (payableAmount ?? 0) && isSelectedWallet ? false : isSelectedWallet
//            self.selectedIndex = indexPath
//            self.tableView.reloadData()
//        }
    }
}

