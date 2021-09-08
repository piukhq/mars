//
//  ImageLoader.swift
//  binkapp
//
//  Created by Sean Williams on 08/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

final class ImageLoader: ObservableObject {
    @Published var image: Image?
    
    func retrieveImage(for membershipPlan: CD_MembershipPlan, colorScheme: ColorScheme) {
        ImageService.getImage(forPathType: .membershipPlanIcon(plan: membershipPlan), traitCollection: nil, colorScheme: colorScheme) { uiImage in
            guard let uiImage = uiImage else { return }
            self.image = Image(uiImage: uiImage)
        }
    }
}

struct RemoteImage: View {
    var image: Image?
    
    var body: some View {
        image?.resizable() ?? Image(Asset.binkLogo.name).resizable()
    }
}
