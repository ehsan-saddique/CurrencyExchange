//
//  MainExchangeCellView.swift
//  Currency Conversion
//
//  Created by Muhammad Ehsan on 09/12/2020.
//

import UIKit

class MainExchangeCellView: UITableViewCell {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var lblShortCode: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblExchangeRate: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        addShadowAndRadius(view: cardView)
    }

    public func configure(exchange: DTOExchange) {
        lblShortCode.text = exchange.destinationCurrencyCode
        lblName.text = exchange.destinationCurrencyName
        
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        if exchange.exchangeRate.isLess(than: 1) {
            formatter.maximumFractionDigits = 4
        }
        lblExchangeRate.text = formatter.string(from: exchange.exchangeRate as NSDecimalNumber)
    }
    
    private func addShadowAndRadius(view: UIView) {
        view.layer.cornerRadius = 20.0
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        view.layer.shadowRadius = 12.0
        view.layer.shadowOpacity = 0.5
    }
    
}
