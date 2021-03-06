//
//  HomeViewController.swift
//  DynamicTableView
//
//  Created by Jitesh Sharma on 21/02/19.
//  Copyright © 2019 Jitesh Sharma. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import NVActivityIndicatorView

/**
 ## Feature Support
 
 This class works as a Root View Controller for windows. It supports:
 
 - Data rendering provided by HomeViewControllerPresenter Class.
 - Has Table view to show data
 
 */



class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Constants
    
    //Used as Cell Identifier for HomeTableViewCell
    let cellIdendifier: String = "InfoModelTableViewCell"
    let notificationIdendifierReloadCell: String = "reloadCell"
    let notificationIdendifierRefreshControl: String = "refreshControl"
    let serviceUrlForViewController: String = "http://surya-interview.appspot.com/list"
    let errorTitle: String = "ERROR !"
    let errorMessageForNoInternet: String = "⚠️ No Internet Connection"
    let errorMessageForNoServiceFailure: String = "⚠️ Something Went Wrong!"
    let errorMessageForNoData: String = "⚠️ No Data Available!"
    let notificationUserInfoKeyCell: String = "cell"
    
    private let viewControllerPresenter = ViewControllerPresenter(serviceString: "http://surya-interview.appspot.com/list")//(serviceString: , p)
    
    // MARK: - UI Components
    let tableView = UITableView()
    var refreshControl: UIRefreshControl!
    var activityIndicator: NVActivityIndicatorView!
    
    // MARK: - Variables
    
    //Used to store "Row" type data to be loaded on HomeTableViewCell
    lazy var infoModelArray: Array<ItemViewModel> = {
        return []
    }()
    
    // MARK: - UI Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding observer to keep track of image aync call to update that particular cell
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadCell(_:)), name: NSNotification.Name(rawValue: notificationIdendifierReloadCell), object: nil)
        // Adding observer to keep track if internet is not comnnected then refresh control should end refreshing without blocking main thread
        NotificationCenter.default.addObserver(self, selector: #selector(self.endrefreshing(_:)), name: NSNotification.Name(rawValue: notificationIdendifierRefreshControl), object: nil)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.addSubview(tableView)
        // Setting constraints for tableView
        setTableConstraints()
        
        // Setting DataSource and Delegate for tableView
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
        // Adding refresh control to call service and reload data in tableView
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.loadAndRefreshDataFromService), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: cellIdendifier)
        
        loadAndRefreshDataFromService()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    // Method for adding activityIndicator for loading
    func setupActivityIndicator() {
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: view.bounds.size.width/2-25, y: view.bounds.size.height/2-25, width: 50, height: 50))
        activityIndicator.type = . circleStrokeSpin
        activityIndicator.color = .darkGray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    // Method for adding constraints for tableView
    func setTableConstraints() {
        
        // Adding constraints for tableView
        tableView.topAnchor.constraint(equalTo:view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo:view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo:view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo:view.bottomAnchor).isActive = true
        
    }
    
    // Method for ending refresh after No internet alert is presented so that main thread should not interupted.
    // This method is called from Notification
    
    @objc func endrefreshing(_ notification: NSNotification ) {
        
        if self.refreshControl.isRefreshing {
            
            self.refreshControl.endRefreshing()
            infoModelArray = []
            self.tableView.reloadData()
            self.tableView.scrollsToTop = true
        }
    }
    
    // Method for reloading Cell after image gets downloaded.
    // This method is called from Notification
    
    @objc func reloadCell(_ notification: NSNotification ) {
        
        if let notify = notification.userInfo {
            
            if let currentCell = notify[notificationUserInfoKeyCell] {
                
                guard let indexPath = self.tableView.indexPath(for: (currentCell as? HomeTableViewCell)!) else {
                    // Note, this is to make sure, cell to reload is still in visible rect
                    return
                }
                tableView.reloadRows(at: [indexPath], with: .automatic)
                if let activityIndicator = activityIndicator {
                    activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    
    // Method for Calling for service to get data for table view.
    @objc func loadAndRefreshDataFromService() {
        
        if viewControllerPresenter.loadInitialItemsFromDB() != nil {
           let infoModelArrays: [ItemViewModel]? = viewControllerPresenter.loadInitialItemsFromDB()
            if let infoModelArrays = infoModelArrays {
                infoModelArray = infoModelArrays
                DispatchQueue.main.async {
                    if let activityIndicator = self.activityIndicator {
                        activityIndicator.stopAnimating()
                    }
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    self.tableView.layoutSubviews()
                    self.tableView.layoutIfNeeded()
                }
            }
        }
        // Checking if internet connection is available.
        if (NetworkReachabilityManager()?.isReachable == false) {
            
            // Displaying Alert if No internet connection.
            let presenter = AlertPresenter(
                alertMessage: self.errorMessageForNoInternet,
                alertTitle: self.errorTitle
            )
            presenter.displaAlert(in: self)
            return
            
        } else {
            
            _ = (activityIndicator != nil) ? activityIndicator.startAnimating() : setupActivityIndicator()
            
            self.refreshControl.beginRefreshing()
            self.getDataFromService { [weak self] (isSuccess, arr) in
                if isSuccess {
                    guard let weakSelf = self else{
                        return
                    }
                    guard let arr = arr else{
                        return
                    }
                    weakSelf.infoModelArray = arr
                    
                    // Reloading TableView to update data received from service in table view
                    // Using Main thread to update the UI
                    
                    DispatchQueue.main.async {
                        
                        if let activityIndicator = weakSelf.activityIndicator {
                            activityIndicator.stopAnimating()
                        }
                        weakSelf.tableView.reloadData()
                        weakSelf.refreshControl.endRefreshing()
                        weakSelf.tableView.layoutSubviews()
                        weakSelf.tableView.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Method for Calling for service to get data.
    func getDataFromService (completionHandler: @escaping CompletionHandler) {
        
        viewControllerPresenter.attachedController(controler: self)
        viewControllerPresenter.getDataFromService(completionHandler: {[weak self] (status, rows) in
            if let weekSelf = self {
                weekSelf.viewControllerPresenter.detachController()
                if status {
                    if (rows?.count)! > 0 {
                        // Using Main thread to update the UI
                        DispatchQueue.main.async {
                            weekSelf.title = "Home Title"
                        }
                        // The happy scenarios if Data is Available.
                        completionHandler(status, rows)
                        
                    } else {
                        // Displaying Alert if No Data Available.
                        DispatchQueue.main.async {
                            weekSelf.refreshControl.endRefreshing()
                            let presenter = AlertPresenter(
                                alertMessage: weekSelf.errorMessageForNoData,
                                alertTitle: weekSelf.errorTitle
                            )
                            presenter.displaAlert(in: weekSelf)
                            return
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        // Displaying Alert if service calls fails Available.
                        weekSelf.refreshControl.endRefreshing()
                        let presenter = AlertPresenter(
                            alertMessage: weekSelf.errorMessageForNoServiceFailure,
                            alertTitle: weekSelf.errorTitle
                        )
                        presenter.displaAlert(in: weekSelf)
                        return
                    }
                }
            }
        })
        
    }
}

// Extension for UITableViewDelegate, UITableViewDataSource
extension HomeViewController {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdendifier, for: indexPath) as! HomeTableViewCell
        cell.row = self.infoModelArray[indexPath.row]
        cell.layoutSubviews()
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.infoModelArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
