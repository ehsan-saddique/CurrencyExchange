//
//  MainHeaderView.swift
//  Currency Conversion
//
//  Created by Muhammad Ehsan on 09/12/2020.
//

import UIKit

protocol MainHeaderViewDelegate: class {
    func onAmountChanged(newAmount: String?)
    func onSelectCurrencyClicked()
    func onRefreshClicked()
}

class MainHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var btnSelectCurrency: UIButton!
    @IBOutlet weak var textFieldAmount: UITextField!
    @IBOutlet weak var lblLastUpdated: UILabel!
    @IBOutlet weak var btnRefresh: UIButton!
    
    public weak var delegate: MainHeaderViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        textFieldAmount.delegate = self
        addShadowAndRadius(view: cardView)
        addShadowAndRadius(view: btnSelectCurrency)
        addShadowAndRadius(view: textFieldAmount)
        
        btnRefresh.layer.cornerRadius = btnRefresh.frame.height/2
        textFieldAmount.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    public func configure(currency: DTOCurrency?, lastRefreshDate: Date?) {
        if let currency = currency {
            btnSelectCurrency.setTitle(currency.shortCode, for: .normal)
            btnSelectCurrency.setTitleColor(.black, for: .normal)
        }
        
        if let lastRefreshDate = lastRefreshDate {
            lblLastUpdated.text = "Last Updated: " + lastRefreshDate.stringValue()
        }
        else {
            lblLastUpdated.text = "Last Updated: --"
        }
    }
    
    @IBAction func btnSelectCurrencyClicked() {
        delegate?.onSelectCurrencyClicked()
    }
    
    @IBAction func btnRefreshClicked() {
        delegate?.onRefreshClicked()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        delegate?.onAmountChanged(newAmount: textFieldAmount.text)
    }
    
    private func addShadowAndRadius(view: UIView) {
        view.layer.cornerRadius = 20.0
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        view.layer.shadowRadius = 12.0
        view.layer.shadowOpacity = 0.7
    }

}

extension MainHeaderView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        switch string {
        case "0","1","2","3","4","5","6","7","8","9":
            return true
        case ".":
            let array = Array(textField.text!)
            var decimalCount = 0
            for character in array {
                if character == "." {
                    decimalCount += 1
                }
            }
            
            if decimalCount == 1 {
                return false
            } else {
                return true
            }
        default:
            let array = Array(string)
            if array.count == 0 {
                return true
            }
            return false
        }
    }
}
