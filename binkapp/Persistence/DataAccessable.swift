//
// Created by Karl Sigiscar on 2019-07-12.
// Copyright (c) 2019 Bink. All rights reserved.
//

import Foundation

/// Offers a simple interface to access and synchronize data in a framework independant way
/// Makes it easy to swap Core Data for Realm or another framework
/// Also makes it easy to mock data coming from the database

protocol DataAccessable {
    func save()
    func sync()
}
