//
//  ImageService.swift
//  binkapp
//
//  Created by Nick Farrant on 28/01/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit
import Disk
import DeepDiff

final class ImageService {

    // TODO: force refresh after plan refresh

    typealias ImageCompletionHandler = (UIImage?) -> Void

    enum PathType {
        case membershipPlanImage(plan: CD_MembershipPlan, imageType: ImageType)
    }

    fileprivate func retrieveImage(forPathType pathType: PathType, forceRefresh: Bool = false, policy: StorageUtility.ExpiryPolicy, completion: @escaping ImageCompletionHandler) {

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
        downloadImage(forPath: imagePath, withPolicy: policy, completion: completion)
    }

    private func path(forType type: PathType) -> String? {
        switch type {
        case .membershipPlanImage(let plan, let imageType):
            guard let url = plan.image(of: imageType)?.url else { return nil }
            return url
        }
    }

    private func downloadImage(forPath path: String, withPolicy policy: StorageUtility.ExpiryPolicy, completion: @escaping ImageCompletionHandler) {
        Current.apiManager.getImage(fromUrlString: path) { (image, error) in
            guard let downloadedImage = image else {
                completion(nil)
                return
            }
            completion(downloadedImage)

            // Store the downloaded image to disk and fail silently
            try? Disk.save(downloadedImage, to: .caches, as: path)

            // Store the downloaded image to local memory
            Cache.sharedImageCache.setObject(downloadedImage, forKey: path.toNSString())

            // Add object to sharedStoredObjects, and save to disk
            let storedObject = StorageUtility.StoredObject(objectPath: path, storedDate: Date(), policy: policy)
            StorageUtility.addStoredObject(storedObject)
        }
    }
    
    /// Retrieve an image returned in a completion handler
    static func getImage(forPathType pathType: ImageService.PathType, policy: StorageUtility.ExpiryPolicy = .week, completion: @escaping (UIImage?) -> Void) {
        let imageService = ImageService()
        imageService.retrieveImage(forPathType: pathType, policy: policy) { retrievedImage in
            completion(retrievedImage)
        }
    }
}

extension UIImageView {
    func setImage(forPathType pathType: ImageService.PathType, withPlaceholderImage placeholder: UIImage? = nil, forceRefresh: Bool = false, policy: StorageUtility.ExpiryPolicy = .week, animated: Bool = false) {
        image = placeholder

        let imageService = ImageService()
        imageService.retrieveImage(forPathType: pathType, policy: policy) { [weak self] retrievedImage in
            if let self = self, animated {
                UIView.transition(with: self,
                duration: 0.3,
                options: .transitionCrossDissolve,
                animations: { self.image = retrievedImage },
                completion: nil)
            } else {
                self?.image = retrievedImage
            }
        }
    }
}

/// A utility class to handle the expiration of objects stored to disk. When an object is
final class StorageUtility {
    fileprivate static var sharedStoredObjects = [StoredObject]()
    fileprivate static let sharedStoredObjectsKey = "sharedStoredObjects"

    enum ExpiryPolicy: Int, Codable {
        case week = 7
        case month = 30
        case year = 365
    }

    fileprivate struct StoredObject: Codable {
        let objectPath: String
        let storedDate: Date
        let policy: ExpiryPolicy

        var isExpired: Bool {
            return expiryDate < Date()
        }

        private var expiryDate: Date {
            return Calendar.current.date(byAdding: .day, value: +policy.rawValue, to: storedDate) ?? Date()
        }
    }

    static func start() {
        let storedObjectsOnDisk = try? Disk.retrieve(sharedStoredObjectsKey, from: .applicationSupport, as: [StoredObject].self)
        guard let storedObjects = storedObjectsOnDisk else { return }
        sharedStoredObjects = storedObjects

        purgeExpiredStoredObjects()
    }

    fileprivate static func addStoredObject(_ object: StoredObject) {
        // Check we aren't already storing this object
        let storedObjectPaths = sharedStoredObjects.map {
            $0.objectPath
        }
        guard !storedObjectPaths.contains(object.objectPath) else { return }
        sharedStoredObjects.append(object)
        print(sharedStoredObjects)
        try? Disk.save(sharedStoredObjects, to: .applicationSupport, as: StorageUtility.sharedStoredObjectsKey)
    }

    private static func purgeExpiredStoredObjects() {
        let validStoredObjects = sharedStoredObjects.filter { !$0.isExpired }
        sharedStoredObjects = validStoredObjects
        try? Disk.save(sharedStoredObjects, to: .applicationSupport, as: StorageUtility.sharedStoredObjectsKey)
    }

    static func refreshPlanImages() {
        // Get all plan images from core data
        var planImages: [CD_MembershipPlanImage] = []
        Current.database.performTask { context in
            let images = context.fetchAll(CD_MembershipPlanImage.self)
            planImages = images
        }

        // Get urls from plan images
        let planImageUrls = planImages.map { $0.url ?? "" }

        // Get urls from stored objects
        let storedObjectUrls = sharedStoredObjects.map { $0.objectPath }

        // Diff two collections
        let changes = diff(old: storedObjectUrls, new: planImageUrls)

        // We are left with a collection of urls that were stored but not found in the latest plan refresh
        // These will be marked as deletions and can be removed
        let deletions = changes.compactMap {
            $0.delete
        }
        let deletionIds = deletions.map {
            $0.index
        }

        deletionIds.forEach {
            sharedStoredObjects.remove(at: $0)
        }
        try? Disk.save(sharedStoredObjects, to: .applicationSupport, as: StorageUtility.sharedStoredObjectsKey)
    }
}
