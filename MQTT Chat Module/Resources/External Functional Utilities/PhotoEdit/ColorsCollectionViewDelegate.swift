//
//  ColorsCollectionViewDelegate.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 5/1/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

class ColorsCollectionViewDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var colorDelegate : ColorDelegate?
    
    /**
     Array of Colors that will show while drawing or typing
     */
    var colors = [UIColor.black,
                  UIColor.darkGray,
                  UIColor.gray,
                  UIColor.lightGray,
                  UIColor.white,
                  UIColor.blue,
                  UIColor.green,
                  UIColor.red,
                  UIColor.yellow,
                  UIColor.orange,
                  UIColor.purple,
                  UIColor.cyan,
                  UIColor.brown,
                  UIColor.magenta]
    
    override init() {
        super.init()
    }
    
    var stickersViewControllerDelegate : StickersViewControllerDelegate?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        colorDelegate?.didSelectColor(color: colors[indexPath.item])
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCollectionViewCell", for: indexPath) as! ColorCollectionViewCell
        cell.colorView.backgroundColor = colors[indexPath.item]
        return cell
    }
    
}

class FontTypeTableviewDelegate: NSObject,UITableViewDelegate,UITableViewDataSource{
    
    var fontsArray = ["Parry Hotter","EutemiaI-Italic","akaDora","Metal Macabre","NewUnicodeFont","Libertango","Godfather","Helvetica","Arial","Scriptina","Waltograph"]
    var fontNamesArray = ["Parry Hotter","Eutemia","Aka Dora","Metal Macabre","Grinched","Libertango","The GodFather v2","Helvetica","Arial","Scriptina","Waltograph"]
    
    
    
    override init() {
        super.init()
    }
    
    var fontDelegate : fontTypeDelegate?
    
    
    func fontname(fontTitle:String) -> UIFont{
        return UIFont(name: fontTitle, size: 20) ?? UIFont()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fontsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FontTypeTableViewCell", for: indexPath) as! FontTypeTableViewCell
        let availableFonts = fontname(fontTitle: fontsArray[indexPath.row])
        cell.fontTypeLabel.font = availableFonts
        cell.fontTypeLabel.text = fontNamesArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let availableFonts = fontname(fontTitle: fontsArray[indexPath.row])
        fontDelegate?.didSelectFont(font: availableFonts)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 30, y: 0, width: tableView.frame.size.width, height: 70))
        view.backgroundColor = .clear
        let label = UILabel(frame: CGRect(x: 60, y: 30, width: tableView.frame.size.width - 60, height: 40))
        label.text = "   " + "Select".localized + " " + "font".localized
        label.font = UIFont.systemFont(ofSize: 24)
        view.addSubview(label)
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        70
    }
}
