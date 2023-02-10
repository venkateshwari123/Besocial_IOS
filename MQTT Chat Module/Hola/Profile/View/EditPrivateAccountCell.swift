//
//  EditPrivateAccountCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 08/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
protocol EditPrivateAccountCellDelegate {
    func switchingToPrivateAccount()
}
class EditPrivateAccountCell: UITableViewCell {

    @IBOutlet weak var switchOutlet: UISwitch!
    
    var editPrivateAccountCellDelegate: EditPrivateAccountCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    @IBAction func switchAction(_ sender: UISwitch) {
        editPrivateAccountCellDelegate?.switchingToPrivateAccount()
    }
}
