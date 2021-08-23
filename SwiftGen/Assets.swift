// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let inactiveLink = ImageAsset(name: "inactiveLink")
  internal static let inactiveView = ImageAsset(name: "inactiveView")
  internal static let amex = ImageAsset(name: "amex")
  internal static let browse = ImageAsset(name: "browse")
  internal static let loyalty = ImageAsset(name: "loyalty")
  internal static let mastercard = ImageAsset(name: "mastercard")
  internal static let visa = ImageAsset(name: "visa")
  internal static let existingSchemeIcon = ImageAsset(name: "existing_scheme_icon")
  internal static let `right` = ImageAsset(name: "right")
  internal static let scanQuick = ImageAsset(name: "scan-quick")
  internal static let neutralArrow = ImageAsset(name: "neutral_arrow")
  internal static let loyaltyScannerEnterManually = ImageAsset(name: "loyalty_scanner_enter_manually")
  internal static let loyaltyScannerError = ImageAsset(name: "loyalty_scanner_error")
  internal static let onboarding1 = ImageAsset(name: "onboarding-1")
  internal static let onboarding2 = ImageAsset(name: "onboarding-2")
  internal static let onboarding3 = ImageAsset(name: "onboarding-3")
  internal static let attention = ImageAsset(name: "attention")
  internal static let lcdFallback = ImageAsset(name: "lcd_fallback")
  internal static let mastercardlogoContainer = ImageAsset(name: "mastercardlogoContainer")
  internal static let americanexpresslogoContainer = ImageAsset(name: "americanexpresslogoContainer")
  internal static let visalogoContainer = ImageAsset(name: "visalogoContainer")
  internal static let visalogoContainerDark = ImageAsset(name: "visalogoContainerDark")
  internal static let lcdModuleIconsLinkActive = ImageAsset(name: "lcdModuleIconsLinkActive")
  internal static let lcdModuleIconsLinkError = ImageAsset(name: "lcdModuleIconsLinkError")
  internal static let lcdModuleIconsLinkInactive = ImageAsset(name: "lcdModuleIconsLinkInactive")
  internal static let lcdModuleIconsLinkPending = ImageAsset(name: "lcdModuleIconsLinkPending")
  internal static let lcdModuleIconsPointsActive = ImageAsset(name: "lcdModuleIconsPointsActive")
  internal static let lcdModuleIconsPointsError = ImageAsset(name: "lcdModuleIconsPointsError")
  internal static let lcdModuleIconsPointsInactive = ImageAsset(name: "lcdModuleIconsPointsInactive")
  internal static let lcdModuleIconsPointsLogin = ImageAsset(name: "lcdModuleIconsPointsLogin")
  internal static let lcdModuleIconsPointsLoginPending = ImageAsset(name: "lcdModuleIconsPointsLoginPending")
  internal static let lcdModuleIconsPointsPending = ImageAsset(name: "lcdModuleIconsPointsPending")
  internal static let activeLink = ImageAsset(name: "activeLink")
  internal static let activeStore = ImageAsset(name: "activeStore")
  internal static let activeView = ImageAsset(name: "activeView")
  internal static let splashIPhone12Max = ImageAsset(name: "Splash iPhone 12 Max")
  internal static let splashIPhone12 = ImageAsset(name: "Splash iPhone 12")
  internal static let joinCardCloseIcon = ImageAsset(name: "join-card-close-icon")
  internal static let cardPaymentLogoAmEx = ImageAsset(name: "cardPaymentLogoAmEx")
  internal static let cardPaymentLogoMastercard = ImageAsset(name: "cardPaymentLogoMastercard")
  internal static let cardPaymentLogoVisa = ImageAsset(name: "cardPaymentLogoVisa")
  internal static let cardPaymentSublogoAmEx = ImageAsset(name: "cardPaymentSublogoAmEx")
  internal static let cardPaymentSublogoMasterCard = ImageAsset(name: "cardPaymentSublogoMasterCard")
  internal static let cardPaymentSublogoVisa = ImageAsset(name: "cardPaymentSublogoVisa")
  internal static let iconSwipeBarcode = ImageAsset(name: "iconSwipeBarcode")
  internal static let iconSwipeDelete = ImageAsset(name: "iconSwipeDelete")
  internal static let icons8Barcode = ImageAsset(name: "icons8Barcode")
  internal static let icons8FilledTrash = ImageAsset(name: "icons8FilledTrash")
  internal static let linked = ImageAsset(name: "linked")
  internal static let login = ImageAsset(name: "login")
  internal static let loyaltyActive = ImageAsset(name: "loyaltyActive")
  internal static let loyaltyInactive = ImageAsset(name: "loyaltyInactive")
  internal static let paymentActive = ImageAsset(name: "paymentActive")
  internal static let paymentInactive = ImageAsset(name: "paymentInactive")
  internal static let settings = ImageAsset(name: "settings")
  internal static let swipeBarcode = ImageAsset(name: "swipeBarcode")
  internal static let trashIcon = ImageAsset(name: "trashIcon")
  internal static let unlinked = ImageAsset(name: "unlinked")
  internal static let activeCheck = ImageAsset(name: "active_check")
  internal static let binkIconLogo = ImageAsset(name: "bink-icon-logo")
  internal static let binkLogoChristmas = ImageAsset(name: "bink-logo-christmas")
  internal static let binkLogoForSplash = ImageAsset(name: "bink-logo-for-splash")
  internal static let binkLogo = ImageAsset(name: "bink-logo")
  internal static let checkmark = ImageAsset(name: "checkmark")
  internal static let close = ImageAsset(name: "close")
  internal static let down = ImageAsset(name: "down")
  internal static let forward = ImageAsset(name: "forward")
  internal static let fullclose = ImageAsset(name: "fullclose")
  internal static let iconCheck = ImageAsset(name: "icon-check")
  internal static let iconsChevronRight = ImageAsset(name: "iconsChevronRight")
  internal static let inactiveCheck = ImageAsset(name: "inactive_check")
  internal static let navbarIconsBack = ImageAsset(name: "navbarIconsBack")
  internal static let navbarIconsBackMask = ImageAsset(name: "navbarIconsBackMask")
  internal static let payment = ImageAsset(name: "payment")
  internal static let paymentScannerTorch = ImageAsset(name: "payment_scanner_torch")
  internal static let refresh = ImageAsset(name: "refresh")
  internal static let scanIcon = ImageAsset(name: "scan_icon")
  internal static let scannerGuide = ImageAsset(name: "scanner_guide")
  internal static let search = ImageAsset(name: "search")
  internal static let settingsNotified = ImageAsset(name: "settings-notified")
  internal static let snowflake = ImageAsset(name: "snowflake")
  internal static let add = ImageAsset(name: "add")
  internal static let cancel = ImageAsset(name: "cancel")
  internal static let up = ImageAsset(name: "up")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
}

internal extension ImageAsset.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
