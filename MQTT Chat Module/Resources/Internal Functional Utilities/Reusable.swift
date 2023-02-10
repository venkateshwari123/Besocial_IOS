//
//  Reusable.swift
//  Shoppd
//
//  Created by Rahul Sharma on 19/08/19.
//  Copyright © 2019 Nabeel Gulzar. All rights reserved.
//
import UIKit

protocol Reusable: class {
    static var reuseIdentifier:String { get }
    static var nib:UINib? { get }
}

extension Reusable{
    static var reuseIdentifier:String {
        return String(describing: self)
    }
    static var nib:UINib? {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
}

extension UITableViewCell{
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
}

extension UITableView{
    func resizeTableFooter(){
        if let footerView = tableFooterView {
            footerView.setNeedsLayout()
            footerView.layoutIfNeeded()
            let height = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var frame = footerView.frame
            frame.size.height = height
            footerView.frame = frame
            tableFooterView = footerView
        }
    }
}


/// Reusable Code For TableView Cell
extension UITableViewCell:Reusable{
}

extension UITableView{
    func registerReusableCell<T:UITableViewCell>(_: T.Type){
        if let nib = T.nib{
            self.register(nib, forCellReuseIdentifier: T.reuseIdentifier)
        }else{
            self.register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
        }
    }
    func dequeReusableCell<T:UITableViewCell>(withIdentifier:String, indexPath index:IndexPath)->T{
        guard let cell = self.dequeueReusableCell(withIdentifier: withIdentifier, for: index) as? T else{
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }
}

/// Reusable code for CollectionViewCell
extension UICollectionViewCell:Reusable{}

extension UICollectionView{
    
    func registerReusableCell<T:UICollectionViewCell>(_: T.Type){
        if let nib = T.nib{
            self.register(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
        }else{
            self.register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    
    func dequeReusableCell<T:UICollectionViewCell>(withIdentifier:String,indexPath index:IndexPath)->T{
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: index) as? T else{
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }
}

/// Reusable Code For StoryBoard Instantiation
protocol Storyboarded {
    static func instantiate(storyBoardName name:String) -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate(storyBoardName name:String) -> Self {
        let storyboard = UIStoryboard(name: name, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! Self
    }
}

extension UIViewController:Storyboarded{}
