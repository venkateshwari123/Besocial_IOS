//
//  LoaderView.swift
//  Shoppd
//
//  Created by Rahul Sharma on 17/10/19.
//  Copyright © 2019 Nabeel Gulzar. All rights reserved.
//

import UIKit

class LoaderView: UIView {
    
    static let shared = LoaderView()
    
    func addSpinner(){
        DispatchQueue.main.async {
            self.frame = UIScreen.main.bounds
            self.backgroundColor = UIColor.white.withAlphaComponent(0.3)
            UIApplication.shared.keyWindow?.addSubview(self)
            self.addSpinnerView()
        }
    }
    
    func addSpinnerToView(view:UIView){
//        self.frame = view.bounds
        view.addSubview(spinnerView)
        NSLayoutConstraint.activate([
            spinnerView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            spinnerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
            spinnerView.widthAnchor.constraint(equalToConstant: 25),
            spinnerView.heightAnchor.constraint(equalToConstant: 25),
            spinnerView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 15),
            spinnerView.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor, constant: 15)
            ])
    }
    
    func removeSpinner(){
        DispatchQueue.main.async {
            self.removeFromSuperview()
        }
    }
    
    lazy var spinnerView:SpinnerView = {
        let view = SpinnerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func addSpinnerView(){
        self.addSubview(spinnerView)
        NSLayoutConstraint.activate([
            spinnerView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            spinnerView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
            spinnerView.widthAnchor.constraint(equalToConstant: 40),
            spinnerView.heightAnchor.constraint(equalToConstant: 40)
            ])
    }
    
}
