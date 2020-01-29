//
//  ImageService.swift
//  binkapp
//
//  Created by Nick Farrant on 28/01/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit
import Disk
import Alamofire
import AlamofireImage

final class ImageService {

    typealias ImageCompletionHandler = (UIImage?) -> Void

    enum PathType {
        case membershipPlanImage(plan: CD_MembershipPlan, imageType: ImageType)
    }

    fileprivate func retrieveImage(forPathType pathType: PathType, forceRefresh: Bool = false, completion: @escaping ImageCompletionHandler) {

        guard let imagePath = path(forType: pathType) else { return }

        // Are we forcing a refresh?
        if !forceRefresh {
            // Is the image in memory?
            if let cachedImage = Cache.sharedImageCache.object(forKey: imagePath.toNSString()) {
                completion(cachedImage)
                return
            }

            // If not, is the image on disk?
            if let imageFromDisk = try? Disk.retrieve(imagePath, from: .caches, as: UIImage.self) {
                completion(imageFromDisk)

                // Promote the image to local memory
                Cache.sharedImageCache.setObject(imageFromDisk, forKey: imagePath.toNSString())
                return
            }
        }

        // Retrieve the image from the API
        // Either the image is not stored locally, or we are forcing a refresh
        downloadImage(forPath: imagePath, completion: completion)
    }

    private func path(forType type: PathType) -> String? {
        switch type {
        case .membershipPlanImage(let plan, let imageType):
            guard let url = plan.image(of: imageType)?.url else { return nil }
            return url
        }
    }

    private func downloadImage(forPath path: String, completion: @escaping ImageCompletionHandler) {
        Current.apiManager.getImage(fromUrlString: path) { (image, error) in
            guard let downloadedImage = image else {
                completion(nil)
                return
            }
            completion(downloadedImage)

            // Store the downloaded image to Disk and fail silently
            try? Disk.save(downloadedImage, to: .caches, as: path)

            // Store the downloaded image to local memory
            Cache.sharedImageCache.setObject(downloadedImage, forKey: path.toNSString())

            // Add object to sharedStoredObjects
            let storedObject = StorageUtility.StoredObject(objectPath: path, storedDate: Date(), policy: .month)
            StorageUtility.sharedStoredObjects.append(storedObject)
            try? Disk.save(StorageUtility.sharedStoredObjects, to: .applicationSupport, as: "sharedStoredObjects")
        }
    }

}

extension UIImageView {
    // TODO: Set policy here, or default to 30 days
    func setImage(forPathType pathType: ImageService.PathType, withPlaceholderImage placeholder: UIImage? = nil, forceRefresh: Bool = false) {
        image = placeholder

        let imageService = ImageService()
        imageService.retrieveImage(forPathType: pathType) { [weak self] retrievedImage in
            self?.image = retrievedImage
        }
    }
}

final class StorageUtility {
    static var sharedStoredObjects = [StoredObject]()

    static func start() {
        let storedObjectsOnDisk = try? Disk.retrieve("sharedStoredObjects", from: .applicationSupport, as: [StoredObject].self)
        guard let storedObjects = storedObjectsOnDisk else { return }
        sharedStoredObjects = storedObjects

        purgeExpiredStoredObjects()
    }

    static private func purgeExpiredStoredObjects() {
        // TODO: Implement this
    }

    enum ExpiryPolicy: Int, Codable {
        case week = 7
        case month = 30
        case year = 365
    }

    struct StoredObject: Codable {
        let objectPath: String
        let storedDate: Date
        let policy: ExpiryPolicy

        var expiryDate: Date? {
            return Calendar.current.date(byAdding: .day, value: +policy.rawValue, to: storedDate)
        }
    }
}
