//
//  VKAudioRequestExecutor.swift
//  VKAudioPlayer
//
//  Created by Nikita Belousov on 5/24/16.
//  Copyright © 2016 Nikita Belousov. All rights reserved.
//

import Foundation
import VK_ios_sdk

// Only last added request is executed. If there are other requests, they are canceled.
// This beheviour is useful if you want to stick to VK's restrictions of maximum number of requests per second and
// not to wait while all of your previous requests to be executed (e.g. live searching). If it's essential for you to
// execute every single request and you want to stick to VK's restrictions, i reccomend to look at VKRequestScheduler

class VKAudioRequestExecutor {
    
    private let operationQueue = NSOperationQueue()
    static let sharedExecutor = VKAudioRequestExecutor()
    
    func executeRequest(request: VKRequest) {
        
        operationQueue.cancelAllOperations()
        let operation = NSBlockOperation()
        weak var opWeak = operation
        operation.addExecutionBlock({
            if opWeak != nil && opWeak!.cancelled == false {
                request.start()
            }
            usleep(timePerRequestsMilliseconds)
        })
        
        operationQueue.addOperation(operation)
    }
    
    private init() {
        operationQueue.maxConcurrentOperationCount = 1
    }
    
}