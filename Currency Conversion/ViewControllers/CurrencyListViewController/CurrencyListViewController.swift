//
//  CurrencyListViewController.swift
//  Currency Conversion
//
//  Created by Muhammad Ehsan on 09/12/2020.
//

import UIKit

protocol CurrencyListViewControllerDelegate: class {
    func didSelect(currency: DTOCurrency)
}

class CurrencyListViewController: UIViewController, UISearchControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    private var viewModel: CurrencyListViewModel!
    private let searchController = UISearchController(searchResultsController: nil)
    
    public weak var delegate: CurrencyListViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CurrencyListCellView", bundle: nil), forCellReuseIdentifier: "CurrencyListCellView")
        isModalInPresentation = true
        emptyView.isHidden = true

        initDependencies()
        initSearchController()
        viewModel.getAllCurrencies()
    }
    
    private func initDependencies() {
        let networkHandler = NetworkHandler()
        let coreDataHandler = CoreDataHandler.shared
        let databaseHandler = DatabaseHandler(coreDataHandler: coreDataHandler)
        viewModel = CurrencyListViewModel(delegate: self, currencyRepository: CurrencyRepository(networkHandler: networkHandler, databaseHandler: databaseHandler))
    }
    
    private func initSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.barStyle = .default
        searchController.searchBar.placeholder = "Search Currencies"
        
        searchController.searchBar.delegate = self
        searchController.searchBar.isTranslucent = true
        searchController.searchBar.alpha = 1
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.barTintColor = UIColor.clear
        
        tableView.tableHeaderView = searchController.searchBar

    }
    
    @IBAction func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }

}

//MARK: UITableView

extension CurrencyListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.currencies.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyListCellView", for: indexPath) as! CurrencyListCellView
        let currency = viewModel.currencies[indexPath.row]
        cell.configure(currency: currency)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currency = viewModel.currencies[indexPath.row]
        delegate?.didSelect(currency: currency)
        searchController.isActive = false
        dismissController()
    }
    
}

//MARK: UISearchResultsUpdating

extension CurrencyListViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            viewModel.searchCurrencies(searchText: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.getAllCurrencies()
    }
}

//MARK: CurrencyListViewModelDelegate

extension CurrencyListViewController: CurrencyListViewModelDelegate {
    func didFailToFetchCurrencies(reason: String) {
        showAlert(withTitle: "Failure", message: reason)
        if viewModel.currencies.isEmpty && !searchController.isActive {
            emptyView.isHidden = false
        }
        else {
            tableView.reloadData()
        }
    }
    
    func onCurrencyListUpdated() {
        if viewModel.currencies.isEmpty && !searchController.isActive {
            emptyView.isHidden = false
        }
        else {
            tableView.reloadData()
        }
    }
}
