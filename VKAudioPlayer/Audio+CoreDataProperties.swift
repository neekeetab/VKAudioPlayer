//
//  Audio+CoreDataProperties.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 6/26/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Audio {

    @NSManaged var title: String?
    @NSManaged var artist: String?
    @NSManaged var dateAdded: NSDate?
    @NSManaged var id: String?

}
