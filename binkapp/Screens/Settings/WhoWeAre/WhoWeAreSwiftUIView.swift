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
                    .frame(width: 142.0, height: 142.0)
                    .cornerRadius(20)
                MainTextStack()
                    .padding(.top, 40.0)
                
                ForEach(teamMembers) { teamMember in
                    VStack(alignment: .leading, spacing: 0, content: {
                        TeamMemberRow(teamMember: teamMember)
                        Divider()
                    })
                }
                .padding(.horizontal, 25.0)
            })
        })
        .padding(.top, 10.0)
    }
    
    struct TeamMemberRow: View {
        var teamMember: BinkTeamMember
        
        var body: some View {
            Text(teamMember.name)
                .frame(width: .infinity, height: 80, alignment: .leading)
                .font(.custom(UIFont.bodyTextLarge.fontName, size: UIFont.bodyTextLarge.pointSize))
        }
    }
    
    struct MainTextStack: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 3, content: {
                Text(L10n.whoWeAreTitle)
                    .font(.custom(UIFont.headline.fontName, size: 25.0))
                Text(L10n.whoWeAreBody)
                    .font(.custom(UIFont.bodyTextLarge.fontName, size: UIFont.bodyTextLarge.pointSize))
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
            })
            .background(Color.white)
            .padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 25))
            .frame(width: UIScreen.main.bounds.width, alignment: .leading)
        }
    }
}

struct WhoWeAreSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        WhoWeAreSwiftUIView()
    }
}
