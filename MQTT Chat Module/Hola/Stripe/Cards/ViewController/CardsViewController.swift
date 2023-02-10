//
//  CardsViewController.swift
//  StripeDemo
//
//  Created by Rahul Sharma on 20/12/19.
//  Copyright © 2019 stripe. All rights reserved.


import UIKit
import Stripe
import PassKit
import RxSwift

protocol CardDelegate: class {
    func add(new card: Card)
    func delete(_ card: Card)
    func update(_ card: Card)
}

protocol CardsViewControllerDelegate {
    func rechargeSuccess()
}

extension CardDelegate {
    func delete(_ card: Card) { }
    func update(_ card: Card) { }
}

//protocol ApplePayPaymentIdDelegate: class {
//    func applePay(_ paymentId: String)
//    func didFailed(_ message: String)
//}

class CardsViewController: BaseViewController {
    
    /// Cards TableView
    @IBOutlet weak var cardsTableView: UITableView!
    
    @IBOutlet weak var addCardButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var seperatorView: UIView!
    
    /// Dispose Bag
    var disposeBag = DisposeBag()
    var screenTitle = "Select Card".localized
    /// Cards View Model
    let viewModel = CardsViewModel()
    let withdrawViewModel = WithdrawViewModel()

    var delegate: CardsViewControllerDelegate?
    
    var showContinueButton = true
    
    //MARK: - Apple Pay Variables -
    /// Apple Pay Delegate
//    weak var applePayDelegate: ApplePayPaymentIdDelegate?
    
    /// Apple Payment Response. It is boolean type. If we got success response it is true else false.
//    var applePaymentResponse = false
    
    /// Apple Pay Payment Id which we need to send server to Authorize or Charge from Apple Pay.
//    var applePayPaymentId = ""
    
    /// Apple Pay Object to store country, currency, amount and description
//    var applePay: ApplePay?
    
    //MARK: - UIView Life Cycle Methods -
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationLeftBarBackButton()
        self.title = screenTitle
        self.navigationController?.navigationBar.tintColor = .black
        Helper.showPI(string: "", showLabel: false)
        addCardButton.setTitle("Add Card".localized, for: .normal)
        addCardButton.layer.cornerRadius = addCardButton.frame.height/2
        addCardButton.titleLabel?.font = Theme.getInstance().changePasswordButtonStyle.getFont()
        addCardButton.setTitleColor(UIColor.hexStringToUIColor(hex: "49ABF3"), for: .normal)
      //  addCardButton.backgroundColor = .white
        
        addCardButton.backgroundColor = UIColor.setColor(lightMode: "#FFFFFF", darkMode: AppColourStr.descriptionLabel)

        addCardButton.layer.borderColor = UIColor.hexStringToUIColor(hex: "49ABF3").cgColor
        addCardButton.layer.borderWidth = 1
        seperatorView.backgroundColor = .setColor(lightMode: AppColourStr.lightWhite, darkMode: "#1C1C1E")
        
        continueButton.setTitle("Continue".localized, for: .normal)
        continueButton.layer.cornerRadius = continueButton.frame.height/2
        continueButton.titleLabel?.font = Theme.getInstance().changePasswordButtonStyle.getFont()
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.backgroundColor = UIColor.hexStringToUIColor(hex: "49ABF3")
        
        // get pg details
        self.withdrawViewModel.getPaymentMethods {}
        // Set Up TableView like tableView type and registering multiple cells
        setUpTableView()
        
        // Add observers for Rx variables
        addAllRxObersers()
        
        // Setup default Stripe Publish Key
        viewModel.setUpStripePublishKey()
        
        withdrawViewModel.getPaymentMethods {
            
            
        }
        
        // Get all cards from server
        viewModel.getAllCards()
        
        // Reload tableView
//        reloadTableView()
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
        // Sometimes we go to other ViewController or AlertViewController
        // That time we remove this ViewController all Rx observer
        // To add them back we need to call addAllRxObersers
        // Add observers for Rx variables
        addAllRxObersers()
        unHideNavBar()
        setContinueButton()
        self.title = screenTitle
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Sometimes we go to other ViewController or AlertViewController
        // Need to remove all Rx observer
        // Remove all Rx observers
        removeAllRxObservers()
    }
    
    //MARK: - Supporting Functions -
    func setContinueButton() {
        if viewModel.getNumberOfCards() > 0{
            continueButton.isHidden = false
        }
        else{
            continueButton.isHidden = true
        }
        
        if !showContinueButton{
            self.continueButton.isHidden = true
        }
    }
    
    //MARK: - IBAction Methods -
    /// Add new card button action
    /// - Parameter sender: add new card button is pressed
    @IBAction func addNewCard(sender: UIButton) {
        // Open Add new card ViewController to add new card in Stripe
        openAddNewCardViewController()
    }

    @IBAction func continueButtonAction(_ sender: Any) {
        navigateToRechargeVC()
    }
    //MARK: - UI Update Methods -
    /// Set up tableView
    func setUpTableView() {
        // Making tableView single selection type to choose single card at a time
        cardsTableView.allowsMultipleSelection = false
        
        // Register all required cells
        registerCells()
    }
    
    /// Register required cells
    func registerCells() {
        // Register Card cell for Card Type data
        register(cellName:"CardCell")
        // Register Add New Card cell for Add Card type data
//        register(cellName:"AddNewCardCell")
    }
    
    /// Register cell to tableView
    /// - Parameter cellName: cell Identifier of the cell
    func register(cellName: String) {
        let cardNib = UINib(nibName: cellName, bundle: nil)
        cardsTableView.register(cardNib, forCellReuseIdentifier: cellName)
    }
    
    /// Relaod tableView in Main thread
    func reloadTableView() {
        DispatchQueue.main.async { [weak self] in
            // Check self. If it has value then update UI
            guard let self = self else { return }
            // Before reload tableView, need to confirm DataSource and Delegate.
            // Checking datasource is confirmed or not. If not then confirming it
            if self.cardsTableView.dataSource == nil {
                self.cardsTableView.dataSource = self
            }
            // Checking delegate is confirmed or not. If not then confirming it
            if self.cardsTableView.delegate == nil {
                self.cardsTableView.delegate = self
            }
            
            // Reload TableView
            self.cardsTableView.reloadData()
        }
    }
    
    //MARK: - Rx Methods -
    /// Add all Rx observers
    func addAllRxObersers() {
        addRxObserverForTableRealod()
    }
    
    /// Remove all Rx observers
    func removeAllRxObservers() {
        // Make dipose bag empty for ViewController and ViewModel
        disposeBag = DisposeBag()
        viewModel.disposeBag = DisposeBag()
    }
    
    /// Add Rx observer for reload TableView
    func addRxObserverForTableRealod() {
        // Checking isTableViewNeedReaload has already observers, if not then only subscrbing
        if !viewModel.isTableViewNeedReaload.hasObservers {
            // Subscribing isTableViewNeedReaload to get data. Data is type of boolean.
            // If it is true then need to reload tableView else nothing to do
            viewModel.isTableViewNeedReaload.subscribe(onNext: { (isReloadNeeded) in
                if isReloadNeeded {
                    self.setContinueButton()
                    self.reloadTableView()
                }
            }, onError: { (error) in
                // Logging errors of isTableViewNeedReaload in DDLog File
                print("Got an error in viewModel.isTableViewNeedReaload and error is \(error.localizedDescription)")
            }) {
                // Logging dipose event of isTableViewNeedReaload in DDLog File
                print("viewModel.isTableViewNeedReaload disposed")
            }.disposed(by: disposeBag)
        }
    }
    
    //MARK: - Navigation -
    
    /// Open Add New Card ViewController
    func openAddNewCardViewController() {
        let storyboard = UIStoryboard(name: "AddCard", bundle: nil)
        // Check userId and AddCardViewController object from identifier
        guard let userId = viewModel.getUserId(),
            let addCardVC = storyboard.instantiateViewController(withIdentifier: String(describing: AddCardViewController.self)) as? AddCardViewController else { return }
        // Pass userId to add card viewModel
        addCardVC.viewModel.setUserId(userId)
        // Confirm add card delegate to get new card details in Cards ViewController
        addCardVC.cardDelegate = self
        self.navigationController?.pushViewController(addCardVC, animated: true)
    }
    
    func navigateToRechargeVC(){
        guard let rechargeVC = UIStoryboard(name: "Recharge", bundle: nil).instantiateViewController(withIdentifier: "RechargeViewController") as? RechargeViewController else {return}
        rechargeVC.viewModel.pgLinkId = self.withdrawViewModel.pgLinkId
        rechargeVC.viewModel.selectedCard = viewModel.getCard(at: viewModel.getSelectedIndex() ?? 0)
        rechargeVC.delegate = self
        self.navigationController?.pushViewController(rechargeVC, animated: true)
    }
}



extension CardsViewController: CardDelegate {
    
    /// Add new card method
    /// - Parameter card: card object which has newly added
    func add(new card: Card) {
        // Update new card in existing card array
        if viewModel.allCards().count == 0 {
            self.viewModel.getAllCards()
        }else {
            viewModel.update(new: card)
        }
        // Update UI
        DispatchQueue.main.async {
            self.reloadTableView()
        }
    }
    
    /// Delete card method
    /// - Parameter card: card object which has deleted
    func delete(_ card: Card) {
        // Delete card from existing card array
        viewModel.delete(card)
        // Update UI
        reloadTableView()
    }
    
    /// Update card method
    /// - Parameter card: card object which has update
    func update(_ card: Card) {
        viewModel.update(new: card)
        reloadTableView()
    }
}

extension CardsViewController: CardCellDelegate{
    func deletePressed() {
        
    }
}

extension CardsViewController: RechargeViewControllerDelegate{
    func rechargeSuccess() {
        delegate?.rechargeSuccess()
    }
}


// MARK: - APPLE PAY -
//extension CardsViewController {
//    // Start Apple pay procee
//    func openApplePay() {        
//        /// Apple Pay required details object
//        let applePay = ApplePay(country: "IN", currency: "INR", title: "Final Amount", amount: 108.00)
//        self.applePay = applePay
//        // Apple Pay process
//        self.applePayButtonAction(applePay)
//    }
//    
//    func applePayButtonAction(_ applePay: ApplePay) {
//        let supportedNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex, PKPaymentNetwork.discover]
//        PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: supportedNetworks)
//
//        // Create PKPaymentRequest object
//        let paymentRequest = PKPaymentRequest()
//        paymentRequest.merchantIdentifier = "merchant.com.3embed.demo.applepay"
//        paymentRequest.merchantCapabilities = PKMerchantCapability.capability3DS
//        paymentRequest.countryCode = applePay.countryCode
//        paymentRequest.currencyCode = applePay.currencyCode
//        let testNSNumber: NSDecimalNumber = NSDecimalNumber(value: applePay.payAmount)
//        paymentRequest.paymentSummaryItems = [PKPaymentSummaryItem(label: applePay.payTitle, amount:testNSNumber)]
//        paymentRequest.supportedNetworks =  supportedNetworks
//        
//        // Present Apple Pay payment sheet
//        if Stripe.canSubmitPaymentRequest(paymentRequest),
//            let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) {
//            paymentAuthorizationViewController.delegate = self
//            self.present(paymentAuthorizationViewController, animated: true)
//        } else {
//            // There is a problem with your Apple Pay configuration
//            // Check Apple Pay Configuration
//            // You may did mistake in Configauration or you may missed to add card in wallet.
//            // First check Apple wallet has card or not. If not add card and try again
//            // If still you are getting configuration issue then check Merchant Id is selected in Xcode
//            // Then check certificate is created in Merchant Id
//            // If certificates is already there then confirm that certificate is uploaded on Stripe Account or not.
//            // If not upload App_pay.cer to Stripe account
//            // Still getting configuration issue then create new merchant id, because sometime Xcode caches wrong data related your apple pay
//            // Then go to stripe account, Go to Create new app. Download stripe.certSigningRequest file.
//            // Then go to Apple account and try to create new Apple Pay certificate using stripe.certSigningRequest file
//            // Then download apple_pay.cer and upload same on Stripe account.
//            // Add Card in Apple Wallet
//            // And retry again
//        }
//    }
//}

//extension CardsViewController: PKPaymentAuthorizationViewControllerDelegate, STPAuthenticationContext {
//    
//    func authenticationPresentingViewController() -> UIViewController {
//        return self
//    }
//    
//    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler: @escaping (PKPaymentAuthorizationResult) -> Void) {
//        // Convert the PKPayment into a PaymentMethod
//        STPAPIClient.shared().createPaymentMethod(with: payment) { (paymentMethod: STPPaymentMethod?, error: Error?) in
//            guard let paymentMethod = paymentMethod, error == nil else {
//                // Present error to customer...
//                self.applePaymentResponse = false
//                return
//            }
//            // Send the token identifier to your server to create a Charge...
//            // If the server responds successfully, set self.paymentSucceeded to YES
//            if let applePay = self.applePay {
//                // If you got payment Id you can call charge API or you can call Booking API and pass Payment Id
//                // If you are calling Booking API then you need to pass two params in Booking parameter
//                // 1. paymentId - paymentMethod.stripeId
//                // 2. paymentType - ApplePay
//                // If you are using Apple API to recharge Wallet then also need to pass above two points paymentId and paymentType in API.
//                self.viewModel.chargeApplePay(paymentMethod.stripeId, and: applePay) { (isSuccess, error) in
//                    if isSuccess {
//                        
//                        self.applePaymentResponse = true
//                        handler(PKPaymentAuthorizationResult(status: .success, errors: nil))
//                    } else if let error = error {
//                        // Present error to customer...
//                        self.applePaymentResponse = true
//                        handler(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
//                    }
//                }
//            }
//        }
//    }
//     
//    
//    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
//        // Dismiss payment authorization view controller
//        dismiss(animated: true, completion: {
//            if self.applePaymentResponse {
//                // Apple Payment done. Update UI as per requirement
//                self.applePayDelegate?.applePay( self.applePayPaymentId)
//            } else {
//                // Present error to customer...
//                self.applePayDelegate?.didFailed("Apple Pay approval is failed")
//            }
//        })
//    }
//}
