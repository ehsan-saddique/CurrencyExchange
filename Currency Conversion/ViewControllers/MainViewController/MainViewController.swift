//
//  MainViewController.swift
//  Currency Conversion
//
//  Created by Muhammad Ehsan on 09/12/2020.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var mainViewModel: MainViewModel!
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MainHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "MainHeaderView")
        tableView.register(UINib(nibName: "MainExchangeCellView", bundle: nil), forCellReuseIdentifier: "MainExchangeCellView")
        initDependencies()
        hideKeyboardWhenTappedOutside()
        
        timer = Timer.scheduledTimer(timeInterval: 30*60, target: self, selector: #selector(refreshLiveRates), userInfo: nil, repeats: true)
        timer?.fire()
        
//        print("Document directory = \(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])")
    }
    
    private func initDependencies() {
        let networkHandler = NetworkHandler()
        let coreDataHandler = CoreDataHandler.shared
        let databaseHandler = DatabaseHandler(coreDataHandler: coreDataHandler)
        mainViewModel = MainViewModel(delegate: self, currencyRepository: CurrencyRepository(networkHandler: networkHandler, databaseHandler: databaseHandler))
    }
    
    //MARK: Timer
    
    @objc private func refreshLiveRates() {
        if let lastRefreshDate = UserDefaults.standard.lastRefreshDate {
            let minsTilLastRefresh: Int = Int(Date().timeIntervalSince(lastRefreshDate) / 60)
            if minsTilLastRefresh >= 30 {
                mainViewModel.getLiveRates()
            }
        }
        else {
            mainViewModel.getLiveRates()
        }
        
    }

}

//MARK: UITableView

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainViewModel.exchangeRates.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 380
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MainHeaderView") as! MainHeaderView
        header.delegate = self
        header.configure(currency: mainViewModel.selectedCurrency, lastRefreshDate: UserDefaults.standard.lastRefreshDate)
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainExchangeCellView", for: indexPath) as! MainExchangeCellView
        let exchange = mainViewModel.exchangeRates[indexPath.row]
        cell.configure(exchange: exchange)
        return cell
    }
}

//MARK: MainHeaderViewDelegate

extension MainViewController: MainHeaderViewDelegate {
    
    func onRefreshClicked() {
        mainViewModel.getLiveRates()
    }
    
    func onSelectCurrencyClicked() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let curencyListVC = storyBoard.instantiateViewController(withIdentifier: "CurrencyListViewController") as! CurrencyListViewController
        curencyListVC.modalPresentationStyle = .automatic
        curencyListVC.delegate = self
        self.present(curencyListVC, animated: true, completion: nil)
    }
    
    func onAmountChanged(newAmount: String?) {
        mainViewModel.selectedAmount = newAmount
        mainViewModel.convertCurrency()
    }
    
}

//MARK: MainViewModelDelegate

extension MainViewController: MainViewModelDelegate {
    func didFetchExchangeRates() {
        UserDefaults.standard.lastRefreshDate = Date()
        
        if mainViewModel.selectedCurrency != nil, mainViewModel.selectedAmount != nil {
            mainViewModel.convertCurrency()
        }
        else {
            tableView.reloadData()
        }
    }
    
    func didFailToFetchRates(reason: String) {
        showAlert(withTitle: "Failure", message: reason)
    }
    
    func didUpdateExchangeRates() {
        tableView.reloadData()
    }
    
    func didFailToConvertCurrency(reason: String) {
        showAlert(withTitle: "Error", message: reason)
    }
    
    
}

//MARK: CurrencyListViewControllerDelegate

extension MainViewController: CurrencyListViewControllerDelegate {
    
    func didSelect(currency: DTOCurrency) {
        tableView.reloadData()
        mainViewModel.selectedCurrency = currency
        mainViewModel.convertCurrency()
    }
}

