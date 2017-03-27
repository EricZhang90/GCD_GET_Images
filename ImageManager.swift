//
//  ImageManager.swift
//  GCD_GET_Images
//
//  Created by Eric zhang on 2017-03-26.
//  Copyright © 2017 lei zhang. All rights reserved.
//

import Foundation


private let _sharedManager = ImageManager()
private let concurrentImageQueueLabel = "com.ericzhang.concurrentImageQueueLabel"

class ImageManager {
    class var sharedManager: ImageManager {
        return _sharedManager
    }
    
    private var _images = [Image]()
    
    fileprivate let concurrentImageQueue =
        DispatchQueue(label: concurrentImageQueueLabel,
                      attributes: .concurrent)
    
    var images : [Image] {
        get {
            var imagesCopy: [Image]!
            concurrentImageQueue.sync {
                imagesCopy = self._images
            }
            return imagesCopy
        }
    }
    
    func addImage(_ image:Image) {
        concurrentImageQueue.async( flags: .barrier){
            self._images.append(image)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(rawValue:imageUpdateNotification), object: nil)
            }
        }
    }
    
    func deleteAllImages() {
        concurrentImageQueue.async( flags: .barrier){
            self._images.removeAll()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(rawValue:imageUpdateNotification), object: nil)
            }
        }
    }
    
    func downloadImages(from ulrStrings: [String], hanlder: imageDownloadCompletionClosure?) {
        var storedError: Error?
        let downloadGroup = DispatchGroup()
        
        for urlString in ulrStrings {
            downloadGroup.enter()
            let image = Image()
            self.addImage(image)
            image.download(from: urlString) {
                err in
                if err != nil {
                    storedError = err
                }
                downloadGroup.leave()
            }
        }
        
        downloadGroup.notify(queue: DispatchQueue.main) {
            hanlder?(storedError)
        }
    }
}








