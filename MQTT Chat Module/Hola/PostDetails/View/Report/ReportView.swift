//
//  ReportView.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 26/11/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

protocol ReportViewDelegate: class{
    func reportSelectedAtIndex(index: Int)
    func onDismissView()
}

class ReportView: UIView {

    @IBOutlet weak var reportMainView: UIView!
    
    @IBOutlet weak var reportContentView: UIView!
    @IBOutlet weak var reportTableView: UITableView!
    @IBOutlet weak var reportViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var backView: UIView!

    @IBOutlet weak var reportTitleLabel: UILabel!
    
    
    var reportReasonsArray = [String](){
        didSet{
            self.setReportView()
        }
    }
    var postId = ""
    var delegate: ReportViewDelegate?
    
    var reportTitle = "Report".localized
    static let nibName = "ReportView"
    static let cellIdentifier = "Cell"
    
    override init(frame: CGRect){
        super.init(frame:frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    
    private func commonInit(){
        
        Bundle.main.loadNibNamed(ReportView.nibName, owner: self, options: nil)
        reportMainView.frame = bounds
        reportMainView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth,UIView.AutoresizingMask.flexibleHeight]
        reportContentView.layer.cornerRadius = 5.0
        reportContentView.clipsToBounds = true
        addSubview(reportMainView)
        
        
        let tapgester = UITapGestureRecognizer.init(target: self, action: #selector(tapCliked))
        backView.addGestureRecognizer(tapgester)
    }
    
    private func setReportView(){
        var viewHeight: CGFloat = CGFloat(40 + self.reportReasonsArray.count * 50)
        if viewHeight > (self.frame.size.height - 50){
            viewHeight = self.frame.size.height - 50
        }
        reportTitleLabel.text = reportTitle
        self.reportViewHeightConstraint.constant = viewHeight
        self.layoutIfNeeded()
    }
    
    
    @objc func tapCliked() {
//        self.removeFromSuperview()
        self.popDownAnimation { (finished) in
            self.delegate?.onDismissView()
        }
    }

}

extension ReportView: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reportReasonsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: ReportView.cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: ReportView.cellIdentifier)
        }
        cell?.textLabel?.text = self.reportReasonsArray[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.reportSelectedAtIndex(index: indexPath.row)
    }
}
