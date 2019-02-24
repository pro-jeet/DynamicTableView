//
//  Extensions.swift
//  DynamicTableView
//
//  Created by Jitesh Sharma on 22/02/19.
//  Copyright © 2019 Jitesh Sharma. All rights reserved.
//

import Foundation

public extension CodingUserInfoKey {
    // Helper property to retrieve the Core Data managed object context
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}

extension String {
    static func emptyIfNil(_ optionalString: String?) -> String {
        let text: String
        if let unwrapped = optionalString {
            text = unwrapped
        } else {
            text = ""
        }
        return text
    }
}

extension NSError {
    static func Error(_ code: Int, description: String) -> NSError {
        return NSError(domain: "com.Jitesh.DynamicTableView",
                       code: 100,
                       userInfo: [ "NSLocalizedDescription" : description ])
    }
}


