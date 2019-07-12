//
// Created by Karl Sigiscar on 2019-07-12.
// Copyright (c) 2019 Bink. All rights reserved.
//

/// Offers a simple interface to access and synchronize data in a framework independent way
/// Makes it easy to swap Core Data for Realm or another framework
/// Also makes it easy to mock data coming from the database

protocol DataAccessible {
    func save()
    func sync()
}
