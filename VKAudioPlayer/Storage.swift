//
//  Storage.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 7/18/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation
import Cache

extension String {
    
    func base64() -> String {
        guard let data = self.dataUsingEncoding(NSUTF8StringEncoding) else { return self }
        return data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    }
}


class Storage: DiskStorage {
    
    func fileName(key: String) -> String {
        return key.base64()
    }
    
    func filePath(key: String) -> String {
        return "\(path)/\(fileName(key))"
    }
    
    func objectIsCached(key: String) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(self.filePath(key))
    }
    
    static let sharedStorage = Storage(name: "Storage")
    
}
