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
    typealias ImageCompletionHandler = (UIImage?) -> Void

    enum PathType {
        case membershipPlanIcon(plan: CD_MembershipPlan)
        case membershipPlanHero(plan: CD_MembershipPlan)
        case membershipPlanAlternativeHero(plan: CD_MembershipPlan)
        case membershipPlanTier(card: CD_MembershipCard)
        case membershipPlanOfferTile(url: String)
    }
    
    /// Retrieve an image returned in a completion handler
    static func getImage(forPathType pathType: PathType, policy: StorageUtility.ExpiryPolicy = .week, traitCollection: UITraitCollection?, completion: @escaping (UIImage?) -> Void) {
        let imageService = ImageService()
        imageService.retrieveImage(forPathType: pathType, policy: policy, traitCollection: traitCollection) { retrievedImage in
            completion(retrievedImage)
        }
    }
    
    static func getImageFromDevice(forPathType pathType: PathType) -> UIImage? {
        let imageService = ImageService()
        guard let imagePath = imageService.path(forType: pathType, traitCollection: .current) else { return nil }
        
        // Is the image available in our cache?
        if let cachedImage = Cache.sharedImageCache.object(forKey: imagePath.toNSString()) {
            return cachedImage
        }

        // If not, is the image on disk?
        if let imageFromDisk = try? Disk.retrieve(imagePath, from: .caches, as: UIImage.self) {
            // Promote the image to local memory
            Cache.sharedImageCache.setObject(imageFromDisk, forKey: imagePath.toNSString())
            
            return imageFromDisk
        }
        
        return nil
    }
    
    fileprivate func retrieveImage(forPathType pathType: PathType, forceRefresh: Bool = false, policy: StorageUtility.ExpiryPolicy, traitCollection: UITraitCollection? = nil, completion: @escaping ImageCompletionHandler) {
        guard let imagePath = path(forType: pathType, traitCollection: traitCollection) else { return }

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

    private func path(forType type: PathType, traitCollection: UITraitCollection?) -> String? {
        var image: CD_BaseImage? = CD_BaseImage()
        
        switch type {
        case .membershipPlanIcon(let plan):
            image = plan.image(ofType: .icon)
        case .membershipPlanHero(let plan):
            image = plan.image(ofType: .hero)
        case .membershipPlanAlternativeHero(let plan):
            image = plan.image(ofType: .alternativeHero)
        case .membershipPlanTier(let card):
            /// If we have a tier image, return that, otherwise return hero
            image = card.image(ofType: .tier) ?? card.membershipPlan?.image(ofType: .hero)
        case .membershipPlanOfferTile(let url):
            return url
        }
        
        let url: String?
        
        switch Current.themeManager.currentTheme.type {
        case .light:
            url = image?.imageUrl
        case .dark:
            url = image?.darkModeImageUrl ?? image?.imageUrl
        case .system:
            switch traitCollection?.userInterfaceStyle {
            case .light:
                url = image?.imageUrl
            case .dark:
                url = image?.darkModeImageUrl ?? image?.imageUrl
            default:
                url = image?.imageUrl
            }
        }
        
        return url
    }
 

    private func downloadImage(forPath path: String, withPolicy policy: StorageUtility.ExpiryPolicy, completion: @escaping ImageCompletionHandler) {
        Current.apiClient.getImage(fromUrlString: path) { (result, _) in
            switch result {
            case .success(let image):
                completion(image)

                // Store the downloaded image to disk and fail silently
                try? Disk.save(image, to: .caches, as: path)

                // Store the downloaded image to local memory
                Cache.sharedImageCache.setObject(image, forKey: path.toNSString())

                // Add object to sharedStoredObjects, and save to disk
                let storedObject = StorageUtility.StoredObject(objectPath: path, storedDate: Date(), policy: policy)
                StorageUtility.addStoredObject(storedObject)
            case .failure:
                completion(nil)
            }
        }
    }
}

extension UIImageView {
    func setImage(forPathType pathType: ImageService.PathType, withPlaceholderImage placeholder: UIImage? = nil, forceRefresh: Bool = false, policy: StorageUtility.ExpiryPolicy = .week, animated: Bool = false) {
        image = placeholder

        let imageService = ImageService()
        imageService.retrieveImage(forPathType: pathType, policy: policy, traitCollection: traitCollection) { [weak self] retrievedImage in
            if let self = self, animated {
                UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: { self.image = retrievedImage }, completion: nil)
            } else {
                self?.image = retrievedImage
            }
        }
    }
    
    func setImage(forPaymentCardFirstSix firstSix: String) {
        var isDarkMode = false
        switch Current.themeManager.currentTheme.type {
        case .dark:
            isDarkMode = true
        case .system:
            if traitCollection.userInterfaceStyle == .dark { isDarkMode = true }
        default:
            break
        }
        
        var paymentCardProviderImageName: String
        switch PaymentCardType.type(from: firstSix) {
        case .visa:
            paymentCardProviderImageName = "visalogoContainer\(isDarkMode ? "Dark" : "")"
        case .amex:
            paymentCardProviderImageName = "americanexpresslogoContainer"
        case .mastercard:
            paymentCardProviderImageName = "mastercardlogoContainer"
        default: return
        }
        
        self.image = UIImage(named: paymentCardProviderImageName)
    }
}

/// A utility class to handle the expiration of objects stored to disk. When an object is
enum StorageUtility {
    fileprivate static var sharedStoredObjects: [StoredObject] = []
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
        try? Disk.save(sharedStoredObjects, to: .applicationSupport, as: StorageUtility.sharedStoredObjectsKey)
    }

    private static func purgeExpiredStoredObjects() {
        // We don't want to remove any stored object if we are offline
        guard Current.apiClient.networkIsReachable else {
            return
        }

        let validStoredObjects = sharedStoredObjects.filter { !$0.isExpired }
        let expiredStoredObjects = sharedStoredObjects.filter { $0.isExpired }

        // Purge on disk
        expiredStoredObjects.forEach {
            try? Disk.remove($0.objectPath, from: .caches)
        }

        // Purge object references
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
        let planImageUrls = planImages.map { $0.imageUrl ?? "" }

        // Get urls from stored objects
        let storedObjectUrls = sharedStoredObjects.map { $0.objectPath }

        // Diff two collections
        let changes = diff(old: storedObjectUrls, new: planImageUrls)

        // We are left with a collection of urls that were stored but not found in the latest plan refresh
        // These will be marked as deletions and can be removed
        let deletions = changes.compactMap {
            $0.delete
        }

        deletions.forEach {
            if sharedStoredObjects.indices.contains($0.index) {
                sharedStoredObjects.remove(at: $0.index)
                try? Disk.remove($0.item, from: .caches)
            }
        }
        try? Disk.save(sharedStoredObjects, to: .applicationSupport, as: StorageUtility.sharedStoredObjectsKey)
    }
}
