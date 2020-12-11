//
//  CurrencyListCellView.swift
//  Currency Conversion
//
//  Created by Muhammad Ehsan on 09/12/2020.
//

import UIKit

class CurrencyListCellView: UITableViewCell {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var lblShortCode: UILabel!
    @IBOutlet weak var lblName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        addShadowAndRadius(view: cardView)
    }

    public func configure(currency: DTOCurrency) {
        lblShortCode.text = currency.shortCode
        lblName.text = currency.name
    }
    
    private func addShadowAndRadius(view: UIView) {
        view.layer.cornerRadius = 20.0
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        view.layer.shadowRadius = 12.0
        view.layer.shadowOpacity = 0.5
    }
    
}
