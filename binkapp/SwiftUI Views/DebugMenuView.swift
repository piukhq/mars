//
//  DebugMenuView.swift
//  binkapp
//
//  Created by Nick Farrant on 14/06/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

@available(iOS 14.0, *)
struct DebugMenuView: View {
    private let hasUser = Current.userManager.hasCurrentUser
    
    var body: some View {
        List {
            Section(header: Text("Networking"), footer: Text("You will be logged out when switching environments.")) {
                PickerDebugRow(type: .environment)
            }
            
            Section(header: Text("Tools")) {
                ToggleDebugRow(title: "Allow custom bundle/client on login", defaultsKey: .allowCustomBundleClientOnLogin)
                ToggleDebugRow(title: "Response code visualiser", defaultsKey: .responseCodeVisualiser)
                ToggleDebugRow(title: "Apply in-app review rules", defaultsKey: .applyInAppReviewRules)
                
                if hasUser {
                    ToggleDebugRow(title: "LPC debug mode", defaultsKey: .lpcDebugMode)
                    NavigationDebugRow(title: "Loyalty plan colour swatches", destination: SwatchView())
                }
            }
            
            if hasUser {
                Section(header: Text("Wallet modifiers"), footer: Text("Mock the number of plans shown in the loyalty wallet prompts. App must be relaunched to reset these.")) {
                    StepperDebugRow(label: "Link prompt count", value: Current.wallet.linkPromptDebugCellCount ?? 0) { value in
                        Current.wallet.linkPromptDebugCellCount = value
                        Current.wallet.refreshLocal()
                    }
                    
                    StepperDebugRow(label: "See prompt count", value: Current.wallet.seePromptDebugCellCount ?? 0) { value in
                        Current.wallet.seePromptDebugCellCount = value
                        Current.wallet.refreshLocal()
                    }
                    
                    StepperDebugRow(label: "Store prompt count", value: Current.wallet.storePromptDebugCellCount ?? 0) { value in
                        Current.wallet.storePromptDebugCellCount = value
                        Current.wallet.refreshLocal()
                    }
                }
            }
            
            Section(footer: Text("This will immediately crash the application.")) {
                DebugRow(rowType: .forceCrash, destructive: true)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Debug menu")
    }
}

@available(iOS 14.0, *)
struct DebugRow: View {
    enum RowType: String {
        case forceCrash = "Force crash"
        
        func action() {
            switch self {
            case .forceCrash:
                SentryService.forceCrash()
            }
        }
    }
    
    let rowType: RowType
    let subtitle: String?
    let destructive: Bool
    
    init(rowType: RowType, subtitle: String? = nil, destructive: Bool = false) {
        self.rowType = rowType
        self.subtitle = subtitle
        self.destructive = destructive
    }
    
    var body: some View {
        Button(action: rowType.action, label: {
            VStack(alignment: .leading, spacing: 5) {
                Text(rowType.rawValue)
                    .foregroundColor(destructive ? .red : .black)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                }
            }
        })
    }
}

@available(iOS 14.0, *)
struct ToggleDebugRow: View {
    private let title: String
    private let subtitle: String?
    private let userDefaultsKey: UserDefaults.Keys
    
    @State private var isEnabled: Bool
    
    init(title: String, subtitle: String? = nil, defaultsKey: UserDefaults.Keys) {
        self.title = title
        self.subtitle = subtitle
        self.userDefaultsKey = defaultsKey
        self.isEnabled = Current.userDefaults.bool(forDefaultsKey: defaultsKey)
    }
    
    var body: some View {
        Toggle(isOn: $isEnabled) {
            Text(title)
                .font(.body)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.subheadline)
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: Color(.binkGradientBlueRight)))
        .onChange(of: isEnabled) { enabled in
            Current.userDefaults.set(enabled, forDefaultsKey: userDefaultsKey)
        }
    }
}

@available(iOS 14.0, *)
struct StepperDebugRow: View {
    @State private var stepperValue: Double
    
    private let label: String
    private let valueHandler: (Int) -> Void
    
    init(label: String, value: Int, handler: @escaping (Int) -> Void) {
        self.label = label
        self.stepperValue = Double(value)
        self.valueHandler = handler
    }
    
    var body: some View {
        HStack {
            Stepper(label, value: $stepperValue, in: 0...20)
                .onChange(of: stepperValue, perform: { value in
                    valueHandler(Int(value))
                })
            Text("\(Int(stepperValue))")
        }
    }
}

@available(iOS 14.0, *)
struct PickerDebugRow: View {
    enum RowType: String {
        case environment = "Select environment"
        
        var initialValue: String {
            switch self {
            case .environment:
                return APIConstants.baseURLString
            }
        }
        
        var options: [String] {
            switch self {
            case .environment:
                return EnvironmentType.allCases.map { $0.rawValue }
            }
        }
        
        func handleSelection(_ selection: String) {
            switch self {
            case .environment:
                APIConstants.changeEnvironment(environment: EnvironmentType(rawValue: selection) ?? .dev)
                NotificationCenter.default.post(name: .shouldLogout, object: nil)
            }
        }
    }
    
    private let type: RowType
    
    @State private var selection: String
    
    init(type: RowType) {
        self.type = type
        self.selection = type.initialValue
    }
    
    var body: some View {
        HStack {
            Picker(type.rawValue.capitalized, selection: $selection) {
                ForEach(type.options, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .foregroundColor(Color(.binkGradientBlueRight))
            .onChange(of: selection, perform: { value in
                type.handleSelection(value)
            })
            
            Spacer()
            
            Text(selection)
                .foregroundColor(.gray)
        }
    }
}

@available(iOS 14.0, *)
struct NavigationDebugRow<Destination: View>: View {
    let title: String
    let destination: Destination
    
    var body: some View {
        NavigationLink(title, destination: destination)
    }
}

@available(iOS 14.0, *)
struct SwatchView: View {
    private let plans: [CD_MembershipPlan] = Current.wallet.membershipPlans ?? []
    
    var body: some View {
        ScrollView {
            ForEach(plans, id: \.self) { plan in
                ZStack {
                    HStack(spacing: 0) {
                        Rectangle()
                            .foregroundColor(Color(UIColor(hexString: plan.card?.colour ?? "")))
                        
                        Rectangle()
                            .foregroundColor(Color(plan.secondaryBrandColor))
                    }
                    .frame(height: 100)
                    
                    Text(plan.account?.companyName ?? "")
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .foregroundColor(.white)
                        )
                }
            }
        }
        .navigationTitle("Secondary plan colours")
    }
}

@available(iOS 14.0, *)
struct DebugMenuView_Previews: PreviewProvider {
    static var previews: some View {
        DebugMenuView()
    }
}
