//
//  AddCardViewController.swift
//  StripeDemo
//
//  Created by Rahul Sharma on 22/12/19.
//  Copyright © 2019 stripe. All rights reserved.
//

import UIKit
import Stripe
import PassKit
import RxSwift

class AddCardViewController: BaseViewController {
    
    /// Enter email to add card process label
//    @IBOutlet weak var enterEmailLabel: UILabel!
    
    /// Email textField to fill user details
//    @IBOutlet weak var emailTextField: UITextField!
    
    /// Enter card details to add card process label
//    @IBOutlet weak var enterCardLabel: UILabel!
    
    /// Card TextField which is type STPPaymentCardTextField, which create by Stripe SDk
    /// All validation are already applied in that.
    @IBOutlet weak var cardTextField: STPPaymentCardTextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    /// Add Card Button outlet
    @IBOutlet weak var addCardButton: UIButton!
    @IBOutlet weak var bottomConstraintSaveButton: NSLayoutConstraint!
    @IBOutlet weak var customView: UIView!
    
    /// Dispose Bag
    var disposeBag = DisposeBag()
    
    /// ViewModel for Add Card ViewController
    let viewModel = AddCardViewModel()
    
    /// Card Delegate to inform other controller card is added successfully or not
    weak var cardDelegate: CardDelegate?
    
    // MARK: - UILife Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationLeftBarBackButton()
        setUp()
        addTapGesture()
        // Set Up intent for add card
        viewModel.setUpIntent()
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
    
    override func viewWillAppear(_ animated: Bool) {
        // Add all Rx observers
        addAllRxObersers()
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Remove all Rx observers
        removeAllRxObservers()
        deregisterFromKeyboardNotifications()
    }
    
    var isEnableCard:Bool = false{
        didSet{
            addCardButton.isEnabled = isEnableCard
            addCardButton.backgroundColor = isEnableCard ? UIColor.hexStringToUIColor(hex: "49ABF3") : UIColor.setColor(lightMode: AppColourStr.disableCard, darkMode: AppColourStr.darkGrayColor)
        }
    }
    
    func setUp(){
        
        self.title = "Add Card".localized
        addCardButton.layer.cornerRadius = addCardButton.frame.height/2
        addCardButton.clipsToBounds = true
        addCardButton.titleLabel?.font = Theme.getInstance().changePasswordButtonStyle.getFont()
        addCardButton.setTitle("Save".localized, for: .normal)
        addCardButton.setTitleColor(.white, for: .normal)
        cardTextField.postalCodeEntryEnabled = false
        cardTextField.delegate = self
        isEnableCard = false
    }
    func addTapGesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        customView.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }

    // MARK: - Rx Methods -
    
    /// Add all Rx observers
    func addAllRxObersers() {
        // Rx observer for Add Card API response
        addRxObserverForCard()
    }
    
    /// Remove all Rx observers
    func removeAllRxObservers() {
        // Make empty dipose bags
        disposeBag = DisposeBag()
        viewModel.disposeBag = DisposeBag()
    }
    
    /// Rx observer for Add Card API response
    func addRxObserverForCard() {
        if !viewModel.card.hasObservers {
            viewModel.card.subscribe(onNext: { [weak self] (response) in
                guard let self = self else { return }
                
                if response.status {
                    // Get card details from response and send to other ViewController
                    if let data = response.response["data"] as? [String: Any] {
                        let card = Card(data)
                        self.cardDelegate?.add(new: card)
                    }
                    // Move back to previous ViewController
                    self.navigationController?.popViewController(animated: true)
                }
                // Display alert ViewController for success or error
//                self.displayAlert(title: response.status ? "Message" : "Alert", message: response.message ?? "")
                
                }, onError: { (error) in
                    // Logging error of add card in DDLog file
                    print("Got an error in Add Card and error is \(error.localizedDescription)")
            }) {
                // Logging dispose event of stripeAPI.card in DDLog file
                print("stripeAPI.card completed")
            }.disposed(by: disposeBag)
        }
    }
    
    /// Display alert viewcontroller
    /// - Parameters:
    ///   - title: title of AlertController
    ///   - message: message of AlertController
    func displayAlert(title: String, message: String?) {
        // Confirming UI updation happen on Main Queue
        DispatchQueue.main.async {
            // Alert ViewController present to user
            let alert = UIAlertController(title: title, message: message ?? "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK".localized, style: .cancel))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension AddCardViewController: STPAuthenticationContext {
    
    /// Add card button action
    @IBAction func addCardButtonAction() {
        // Get client secret intent key
        guard let setupIntentClientSecret = viewModel.getSetupIntentClientSecret() else { return }
         // Collect card details
        let cardParams = cardTextField.cardParams
        
        // Collect the customer's email to know which customer the PaymentMethod belongs to.
        let billingDetails = STPPaymentMethodBillingDetails()
//        billingDetails.email = emailTextField.text
        
        // Create SetupIntent confirm parameters with the above
        let paymentMethodParams = STPPaymentMethodParams(card: cardParams, billingDetails: billingDetails, metadata: nil)
        let setupIntentParams = STPSetupIntentConfirmParams(clientSecret: setupIntentClientSecret)
        setupIntentParams.paymentMethodParams = paymentMethodParams
        
        // Complete the setup
        let paymentHandler = STPPaymentHandler.shared()
        Helper.showPI(_message: "")
        paymentHandler.confirmSetupIntent(withParams: setupIntentParams, authenticationContext: self) {[weak self] status, setupIntent, error in
            guard let self = self else { return }
            // Check status and update UI
            switch status {
            case .failed:
                self.displayAlert(title: "Setup failed".localized, message: error?.localizedDescription)
                
            case .canceled:
                self.displayAlert(title: "Setup canceled".localized, message: error?.localizedDescription)
                
            case .succeeded:
                // If payment Id is created, then add card in Stripe using payment Id
                if let paymentId = setupIntent?.paymentMethodID {
                    self.viewModel.addCard(paymentId)
                }
//                self.cardDelegate?.add(new: Card)
//                self.navigationController?.popViewController(animated: true)
                
            @unknown default:
                fatalError()
                break
            }
        }
    }
    
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
}

extension AddCardViewController: STPPaymentCardTextFieldDelegate{
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        isEnableCard = textField.isValid
    }
}
