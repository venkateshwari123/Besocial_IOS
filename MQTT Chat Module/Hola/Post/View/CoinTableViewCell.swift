//
//  CoinTableViewCell.swift
//  PicoAdda
//
//  Created by 3Embed on 20/10/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import Foundation
import UIKit

protocol CoinCellDelegate {
    func switchTap(isOn:Bool,amount:String)
    func coinSelected(amount: String)
}
class CoinTableViewCell: UITableViewCell {
   
    @IBOutlet weak var amountTf: UITextField!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var chooseYourCoinLbl: UILabel!
    @IBOutlet weak var coinCollection: UICollectionView!
    @IBOutlet weak var switchPaidPost: UISwitch!
    @IBOutlet weak var paidPostLbl: UILabel!
    var amountList = [Int]()
    var delegate : CoinCellDelegate?
    override func awakeFromNib() {
       super.awakeFromNib()
        paidPostLbl.text = "Paid Post".localized
        amountLbl.text = "Amount".localized
        chooseYourCoinLbl.text = "Choose your coin".localized
       // Initialization code
//        coinCollection.reloadData()
   }
   
   override func setSelected(_ selected: Bool, animated: Bool) {
       super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
   }
    
    @IBAction func onSwitchTap(_ sender: Any) {
        delegate?.switchTap(isOn: switchPaidPost.isOn, amount: self.amountTf.text ?? "")
    }
}
//MARK:- CollectionView DataSource
extension CoinTableViewCell:UICollectionViewDataSource{
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return amountList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoinCollectionViewCell", for: indexPath) as! CoinCollectionViewCell
        if amountTf.text! == "\(amountList[indexPath.row])"{
            cell.bgView.layer.borderColor = UIColor.hexStringToUIColor(hex: "#0C6F6D").cgColor
            cell.bgView.layer.borderWidth = 1
        }
        else{
            cell.bgView.layer.borderColor = #colorLiteral(red: 0.9386680722, green: 0.9387995601, blue: 0.9386265874, alpha: 1)
            cell.bgView.layer.borderWidth = 0
        }
        cell.lblAmount?.text = "\(amountList[indexPath.row])"
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        amountTf.text = "\(amountList[indexPath.row])"
        delegate?.coinSelected(amount: amountTf.text ?? "")
        coinCollection.reloadData()
    }
}

//MARK:- CollectionView Delegate FlowLayout
extension CoinTableViewCell:UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           return CGSize(width: 75, height: 50)
       }
}
class CoinCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lblAmount: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
