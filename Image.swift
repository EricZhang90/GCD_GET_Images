//
//  Image.swift
//  GCD_GET_Images
//
//  Created by Eric zhang on 2017-03-26.
//  Copyright © 2017 lei zhang. All rights reserved.
//

import UIKit

private let downloadSession = URLSession(configuration: URLSessionConfiguration.ephemeral)

let imageUpdateNotification = "com.ericZhang.imageUpdate"

typealias imageDownloadCompletionClosure = (_ error :Error?) -> Void

enum ImageStatus {
    case initial
    case downloading
    case success
    case fail
}

class Image {
    
    var image: UIImage?
    var status: ImageStatus!
    
    init() {
        image = #imageLiteral(resourceName: "ImageDonwloading")
        status = .initial
    }
    
    func download(from urlString:String, handler: imageDownloadCompletionClosure?) {
        status = .downloading
        let url = URL(string: urlString)
        downloadSession.dataTask(with: url!) {
            data, response, error in
            
            if let data = data {
                self.image = UIImage(data: data)
            }
            
            if error == nil && self.image != nil {
                self.status = .success
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(rawValue:imageUpdateNotification), object: nil)
                }
            }
            else {
                self.status = .fail
                self.image = #imageLiteral(resourceName: "ImageDownloadFail")
            }

            handler?(error)
            
        }.resume()
    }
}
