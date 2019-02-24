//
//  Item.swift
//  DynamicTableView
//
//  Created by Jitesh Sharma on 21/02/19.
//  Copyright © 2019 Jitesh Sharma. All rights reserved.
//

import Foundation
import CoreData

@objc(Item)
class Item: NSManagedObject, Codable {
    
    enum CodingKeys: String, CodingKey {
        case emailID = "emailId"
        case lastName
        case imageURL = "imageUrl"
        case firstName
    }
    
    // MARK: - Core Data Managed Object
    @NSManaged var emailID: String?
    @NSManaged var lastName: String?
    @NSManaged var imageURL: String?
    @NSManaged var firstName: String?
    
    // MARK: - Decodable
    required convenience init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Item", in: managedObjectContext) else {
                fatalError("Failed to decode Item")
        }
        
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.emailID = try container.decodeIfPresent(String.self, forKey: .emailID)
        self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        self.firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        self.imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(emailID, forKey: .emailID)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(imageURL, forKey: .imageURL)
    }
}

struct HomeModel: Decodable {
    let items: [Item]
}

struct ItemViewModel: Codable {
    let emailID, lastName: String?
    let imageURL: String?
    let firstName: String?

    init(item: Item) {
        
        // emailID
        emailID = String.emptyIfNil(item.emailID)
        
        // lastName
        lastName = String.emptyIfNil(item.lastName)
        
        // firstName
        firstName = String.emptyIfNil(item.firstName)
        
        // imageURL
        imageURL = String.emptyIfNil(item.imageURL)
    }
}

extension ItemViewModel: Equatable {}

func ==(lhs: ItemViewModel, rhs: ItemViewModel) -> Bool {
    return lhs.emailID == rhs.emailID &&
        lhs.firstName == rhs.firstName &&
        lhs.imageURL == rhs.imageURL &&
        lhs.lastName == rhs.lastName
}

