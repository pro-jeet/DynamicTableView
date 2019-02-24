//
//  Presenter.swift
//  DynamicTableView
//
//  Created by Jitesh Sharma on 21/02/19.
//  Copyright © 2019 Jitesh Sharma. All rights reserved.
//

import Foundation
import Alamofire
import SwiftKeychainWrapper
import CoreData

struct AlertPresenter {

    let alertMessage: String?
    // The title of the button to accept the confirmation
    let alertTitle: String?
    // The title of the button to reject the confirmation
    let okTitle = "OK"
    // A closure to be run when the user taps one of the
    // alert's buttons.

    // Common Method for displaying alert takes message and title as input.
    func displaAlert(in viewController: UIViewController) {

        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okTitle, style: .default, handler: { alert in
            NotificationCenter.default.post(name: Notification.Name("refreshControl"), object: nil)
        }))

        viewController.present(alert, animated: true)
    }
}

class ViewControllerPresenter {

    private var serviceString = String()
    weak private var controller : UIViewController?
    private static let entityName = "Item"
    private var fetchItemsCompletionBlock: FetchItemsCompletionBlock?
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "DynamicTableView")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    init(serviceString: String) {
        self.serviceString = serviceString
    }

    func attachedController (controler: UIViewController){
        controller = controler
    }

    func detachController() {
        controller = nil
    }
    
    func getItemsFromDB() -> [Item]? {
        let managedObjectContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Item>(entityName: ViewControllerPresenter.entityName)
        do {
            let users = try managedObjectContext.fetch(fetchRequest)
            return users
        } catch let error {
            print(error)
            return nil
        }
    }
    
    func loadInitialItemsFromDB() -> [ItemViewModel]? {
        guard let itemFromDB = getItemsFromDB() else {
            return nil
        }
        let itemViewModels = ViewControllerPresenter.initViewModels(itemFromDB)
        return itemViewModels as? [ItemViewModel]
    }
    
    func fetchItems(_ completionBlock: @escaping FetchItemsCompletionBlock) {
        fetchItemsCompletionBlock = completionBlock
    }
    
    func parse(_ jsonData: Data) -> Bool {

        do {
            guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext") else {
                fatalError("Failed to retrieve context")
            }

            // Parse JSON data
            let managedObjectContext = persistentContainer.viewContext
            let decoder = JSONDecoder()
            decoder.userInfo[codingUserInfoKeyManagedObjectContext] = managedObjectContext
            // Create Fetch Request
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
            
            // Create Batch Delete Request
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try managedObjectContext.execute(batchDeleteRequest)
                
            } catch {
                // Error Handling
                return false
            }
            _ = try decoder.decode(HomeModel.self, from: jsonData)
            try managedObjectContext.save()

            return true
        } catch let error {
            print(error)
            return false
        }
    }
    
    static func initViewModels(_ item: [Item?]) -> [ItemViewModel?] {
        return item.map { item in
            if let item = item {
                return ItemViewModel(item: item)
            } else {
                return nil
            }
        }
    }
    
    func getDataFromService(completionHandler: @escaping CompletionHandler) {

        // Alamofire request for calling service.
        // Called in asyn global queue.
        
        guard let retrievedString: String = KeychainWrapper.standard.string(forKey: KeyChainEmailKey) else {
            completionHandler(false, nil)
            return
        }
        let params: [String : Any] = ["emailId" : retrievedString]
        Alamofire.request(serviceString, method: .post, parameters: params, encoding: JSONEncoding.default).validate().responseJSON(queue: DispatchQueue.global(), options:
            .mutableContainers, completionHandler: {[weak self] response in
                guard let weekSelf = self else { return }
                if let jsonData = response.data {
                    
                    if weekSelf.parse(jsonData) {
                        if let items = weekSelf.getItemsFromDB() {
                            let newItems = ViewControllerPresenter.initViewModels(items)
                            DispatchQueue.main.async {
                                completionHandler(true, newItems as? [ItemViewModel])
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            weekSelf.fetchItemsCompletionBlock?(false, NSError.Error(0, description: "JSON parsing error"))
                        }
                    }
                }
        })
    }

}



