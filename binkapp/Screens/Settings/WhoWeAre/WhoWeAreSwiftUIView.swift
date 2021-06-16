//
//  WhoWeAreSwiftUIView.swift
//  binkapp
//
//  Created by Sean Williams on 15/06/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct BinkTeamMember: Identifiable {
    let id = UUID()
    let name: String
}

struct WhoWeAreSwiftUIView: View {
    enum Constants {
        static let horizontalPadding: CGFloat = 25.0
        static let cellWidth: CGFloat = UIScreen.main.bounds.width - (horizontalPadding * 2)
        static let cellHeight: CGFloat = 80
        static let cornerRadius: CGFloat = 20
        static let imageSize: CGFloat = 142
        static let textStackPadding: CGFloat = 40.0
        static let topPadding: CGFloat = 40.0
    }
    var teamMembers = [
        BinkTeamMember(name: "Paul Batty"),
        BinkTeamMember(name: "Nick Farrant"),
        BinkTeamMember(name: "Susanne King"),
        BinkTeamMember(name: "Srikalyani Kotha"),
        BinkTeamMember(name: "Marius Lobontiu"),
        BinkTeamMember(name: "Carmen Muntean"),
        BinkTeamMember(name: "Dorin Pop"),
        BinkTeamMember(name: "Karl Sigiscar"),
        BinkTeamMember(name: "Greta Simanauskaite"),
        BinkTeamMember(name: "Paul Tiritieu"),
        BinkTeamMember(name: "Sean Williams"),
        BinkTeamMember(name: "Max Woodhams")
    ]
    
    var body: some View {
        ScrollView(content: {
            VStack(alignment: .center, spacing: 0, content: {
                Image(Asset.binkIconLogo.name)
                    .resizable()
                    .frame(width: Constants.imageSize, height: Constants.imageSize)
                    .cornerRadius(Constants.cornerRadius)
                MainTextStack()
                    .padding(.top, Constants.textStackPadding)
                
                ForEach(teamMembers) { teamMember in
                    VStack(alignment: .leading, spacing: 0, content: {
                        TeamMemberRow(teamMember: teamMember)
                        Divider()
                    })
                }
                .padding(.horizontal, Constants.horizontalPadding)
            })
        })
        .padding(.top, Constants.topPadding)
        .background(Color(Current.themeManager.color(for: .viewBackground)))
    }
    
    struct TeamMemberRow: View {
        var teamMember: BinkTeamMember
        
        var body: some View {
            Text(teamMember.name)
                .frame(width: Constants.cellWidth, height: Constants.cellHeight, alignment: .leading)
                .font(.custom(UIFont.bodyTextLarge.fontName, size: UIFont.bodyTextLarge.pointSize))
        }
    }
    
    struct MainTextStack: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 3, content: {
                Text(L10n.whoWeAreTitle)
                    .font(.custom(UIFont.headline.fontName, size: Constants.horizontalPadding))
                Text(L10n.whoWeAreBody)
                    .font(.custom(UIFont.bodyTextLarge.fontName, size: UIFont.bodyTextLarge.pointSize))
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
            })
            .background(Color.clear)
            .padding(EdgeInsets(top: 0, leading: Constants.horizontalPadding, bottom: 0, trailing: Constants.horizontalPadding))
            .frame(width: UIScreen.main.bounds.width, alignment: .leading)
        }
    }
}

struct WhoWeAreSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        WhoWeAreSwiftUIView()
    }
}
