//
//  LoadingScreen.swift
//  binkapp
//
//  Created by Max Woodhams on 22/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class LoadingScreen: UIViewController {
    init() {
        super.init(nibName: "LoadingScreen", bundle: Bundle(for: LoadingScreen.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
