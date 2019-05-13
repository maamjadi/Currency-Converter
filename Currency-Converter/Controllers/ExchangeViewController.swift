//
//  ConverterViewController.swift
//  Currency-Converter
//
//  Created by Amin Amjadi on 10/11/18.
//  Copyright © 2018 Amin Amjadi. All rights reserved.
//

import UIKit

class ExchangeViewController: UIViewController {
    
    @IBOutlet weak var firstCurrency: UIButton!
    @IBOutlet weak var firstAmount: UIButton!
    @IBOutlet weak var secondCurrency: UIButton!
    @IBOutlet weak var secondAmount: UIButton!
    @IBOutlet weak var centerArrowBorder: UIView!
    @IBOutlet weak var centerArrowImageView: UIImageView!
    @IBOutlet var currenciesTableView: UITableView!
    @IBOutlet weak var dimView: UIVisualEffectView!
    
    //if reverseArrowDirection is true, it will change to up
    private var reverseArrowDirection = false
    private var numberHasSet: Bool = false
    private var changetheCurrency: Int?
    private var currenciesArray = [String]() {
        didSet {
            currenciesTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currenciesTableView.delegate = self
        currenciesTableView.dataSource = self
        
        setupUI()
        setupData()
        setupGestures()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animateArrow()
    }
    
    private func setupGestures() {
        let tapToDismiss = UITapGestureRecognizer(target: self, action: #selector(dimissCurrenciesTableView(_:)))
        dimView.addGestureRecognizer(tapToDismiss)
        
        let tapToSwap = UITapGestureRecognizer(target: self, action: #selector(swapTheCurrencies(_:)))
        centerArrowImageView.addGestureRecognizer(tapToSwap)
    }
    
    private func setupUI() {
        dimView.isHidden = true
        dimView.alpha = 0
        centerArrowBorder.layer.cornerRadius = centerArrowBorder.frame.width / 2
        centerArrowImageView.layer.cornerRadius = centerArrowImageView.frame.width / 2
    }
    
    private func setupData() {
        RateHandler.shared.getCurrencies { (success, currencies) in
            self.currenciesArray = currencies
        }
        firstCurrency.setTitle(getDevicesCurrencyCode(), for: .normal)
        convertValue()
    }
    
    private func getDevicesCurrencyCode() -> String {
        let locale = Locale.current
        return locale.currencyCode!
    }
    
    private func convertValue() {
        guard let firstCurrencyTitle = firstCurrency.currentTitle, let secondCurrencyTitle = secondCurrency.currentTitle else {
            return
        }
        var first = firstCurrencyTitle
        var second = secondCurrencyTitle
        var amountStr = firstAmount.currentTitle!
        var convertedAmountBtn = secondAmount
        
        //checking to see if the direction of the conversion is opposite
        if reverseArrowDirection {
            first = secondCurrencyTitle
            second = firstCurrencyTitle
            amountStr = secondAmount.currentTitle!
            convertedAmountBtn = firstAmount
        }
        
        if let doubleAmount = Double(amountStr) {
            //calling convert function of rate handler to get converted value
            RateHandler.shared.convert(amount: doubleAmount, firstCurrency: first, secondCurrency: second) { (success, err, convertedDouble) in
                if let error = err {
                    //presenting an alert dialog in case there will an error
                    let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                convertedAmountBtn?.setTitle(String(describing: convertedDouble), for: .normal)
            }
        }
    }
    
    @objc
    private func swapTheCurrencies(_ sender: UITapGestureRecognizer?) {
        let tempCurr = firstCurrency.currentTitle
        
        //to handle 360 deg. rotation of the arrow, for each directions of the arrow
        var firstTransformDeg: CGFloat = .pi
        var secondTransformDeg: CGFloat = 2 * .pi
        if reverseArrowDirection {
            firstTransformDeg = 2 * .pi
            secondTransformDeg = 3 * .pi
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.centerArrowImageView.transform = CGAffineTransform(rotationAngle: firstTransformDeg)
            self.firstCurrency.isHidden = true
            self.secondCurrency.isHidden = true
            self.firstCurrency.setTitle(self.secondCurrency.currentTitle, for: .normal)
            self.secondCurrency.setTitle(tempCurr, for: .normal)
        })
        UIView.animate(withDuration: 0.2, delay: 0.15, options: .curveEaseIn, animations: {
            self.centerArrowImageView.transform = CGAffineTransform(rotationAngle: secondTransformDeg)
            self.convertValue()
            self.firstCurrency.isHidden = false
            self.secondCurrency.isHidden = false
        })
    }
    
    @objc
    private func dimissCurrenciesTableView(_ sender: UITapGestureRecognizer?) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            self.dimView.alpha = 0
            self.currenciesTableView.transform = CGAffineTransform(scaleX: 0.01, y: 0.005)
        }, completion: {(success) in
            self.currenciesTableView.removeFromSuperview()
            self.dimView.isHidden = true
        })
    }
    
    @IBAction func firstCurrAction(_ sender: Any) {
        changetheCurrency = 0
        showCurrenciesTableView()
    }
    
    @IBAction func secondCurrAction(_ sender: Any) {
        changetheCurrency = 1
        showCurrenciesTableView()
    }
    
    private func showCurrenciesTableView() {
        currenciesTableView.center = self.view.center
        currenciesTableView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        currenciesTableView.layer.cornerRadius = 10
        self.view.addSubview(currenciesTableView)
        currenciesTableView.clipsToBounds = true
        
        self.dimView.isHidden = false
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: [], animations: {
            self.dimView.alpha = 0.4
            self.currenciesTableView.transform = .identity
        })
    }
    
    private func animateArrow() {
        if numberHasSet {
            var transformation = CGAffineTransform.identity
            if reverseArrowDirection {
                transformation = CGAffineTransform(rotationAngle: .pi)
            }
            
            UIView.animate(withDuration: 0.2, animations: {
                self.centerArrowImageView.transform = transformation
            })
            numberHasSet = false
        }
    }
    
    @IBAction func firstCurrNumericVC(_ sender: UIButton) {
        reverseArrowDirection = false
        performSegue(withIdentifier: "numbericSegue", sender: sender)
    }
    
    @IBAction func secondCurrNumbericVC(_ sender: UIButton) {
        reverseArrowDirection = true
        performSegue(withIdentifier: "numbericSegue", sender: sender)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? NumericViewController {
            controller.numberSetter = self
            guard let theButton = sender as? UIButton else {
                return
            }
            if theButton.titleLabel?.textColor == UIColor(named: "DarkColor") {
                controller.defaultColorTheme = true
            } else {
                controller.defaultColorTheme = false
            }
        }
    }
}

extension ExchangeViewController: NumberSetterProtocol {
    func set(num: String) {
        numberHasSet = true
        if !(reverseArrowDirection) {
            firstAmount.setTitle(num, for: .normal)
        } else {
            secondAmount.setTitle(num, for: .normal)
        }
        convertValue()
    }
}

extension ExchangeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currenciesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath)
        cell.textLabel?.text = currenciesArray[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let theBtnCurrency = changetheCurrency, let theCurrency = currenciesTableView.cellForRow(at: indexPath)?.textLabel?.text else {
            return
        }
        if theBtnCurrency == 0 {
            firstCurrency.setTitle(theCurrency, for: .normal)
        }
        else if theBtnCurrency == 1 {
            secondCurrency.setTitle(theCurrency, for: .normal)
        }
        convertValue()
        dimissCurrenciesTableView(nil)
    }
}
