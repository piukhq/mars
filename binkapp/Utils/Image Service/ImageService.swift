//
//  ImageService.swift
//  binkapp
//
//  Created by Nick Farrant on 28/01/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit
import Disk

final class ImageService {

    typealias ImageCompletionHandler = (UIImage?) -> Void

    func retrieveImage(forPath path: String, forceRefresh: Bool = false, completion: ImageCompletionHandler) {
        
        // Are we forcing a refresh?
        if !forceRefresh {
            // Is the image in memory?
            if let cachedImage = Cache.sharedImageCache.object(forKey: path.toNSString()) {
                completion(cachedImage)
                return
            }

            // If not, is the image on disk?
            if let imageFromDisk = try? Disk.retrieve(path, from: .documents, as: UIImage.self) {
                completion(imageFromDisk)
                return
            }
        }

        // Retrieve the image from the API
        // Either the image is not stored locally, or we are forcing a refresh
        downloadImage(forPath: path, completion: completion)
    }

    private func downloadImage(forPath path: String, completion: ImageCompletionHandler) {

    }

}

extension String {
    func toNSString() -> NSString {
        return self as NSString
    }
}
