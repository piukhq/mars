// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// About %@
  internal static func aboutCustomTitle(_ p1: Any) -> String {
    return L10n.tr("Localizable", "about_custom_title", String(describing: p1), fallback: "About %@")
  }
  /// About %@
  internal static func aboutMembershipPlanTitle(_ p1: Any) -> String {
    return L10n.tr("Localizable", "about_membership_plan_title", String(describing: p1), fallback: "About %@")
  }
  /// About membership
  internal static let aboutMembershipTitle = L10n.tr("Localizable", "about_membership_title", fallback: "About membership")
  /// Accept
  internal static let accept = L10n.tr("Localizable", "accept", fallback: "Accept")
  /// Confirm password
  internal static let accessFormConfirmPasswordPlaceholder = L10n.tr("Localizable", "access_form_confirm_password_placeholder", fallback: "Confirm password")
  /// Confirm password
  internal static let accessFormConfirmPasswordTitle = L10n.tr("Localizable", "access_form_confirm_password_title", fallback: "Confirm password")
  /// Passwords do not match
  internal static let accessFormConfirmPasswordValidation = L10n.tr("Localizable", "access_form_confirm_password_validation", fallback: "Passwords do not match")
  /// Enter email address
  internal static let accessFormEmailPlaceholder = L10n.tr("Localizable", "access_form_email_placeholder", fallback: "Enter email address")
  /// Email
  internal static let accessFormEmailTitle = L10n.tr("Localizable", "access_form_email_title", fallback: "Email")
  /// Incorrect email format
  internal static let accessFormEmailValidation = L10n.tr("Localizable", "access_form_email_validation", fallback: "Incorrect email format")
  /// Enter password
  internal static let accessFormPasswordPlaceholder = L10n.tr("Localizable", "access_form_password_placeholder", fallback: "Enter password")
  /// Password
  internal static let accessFormPasswordTitle = L10n.tr("Localizable", "access_form_password_title", fallback: "Password")
  /// Password should be 8 or more characters, with at least 1 uppercase, 1 lowercase and a number
  internal static let accessFormPasswordValidation = L10n.tr("Localizable", "access_form_password_validation", fallback: "Password should be 8 or more characters, with at least 1 uppercase, 1 lowercase and a number")
  /// Please add your email address below.
  internal static let addEmailSubtitle = L10n.tr("Localizable", "add_email_subtitle", fallback: "Please add your email address below.")
  /// Add email
  internal static let addEmailTitle = L10n.tr("Localizable", "add_email_title", fallback: "Add email")
  /// You can link this card to your bank cards and automatically collect points when you pay.
  internal static let addJoinScreenLinkDescription = L10n.tr("Localizable", "add_join_screen_link_description", fallback: "You can link this card to your bank cards and automatically collect points when you pay.")
  /// You cannot link this card to your payment cards yet.
  internal static let addJoinScreenLinkDescriptionInactive = L10n.tr("Localizable", "add_join_screen_link_description_inactive", fallback: "You cannot link this card to your payment cards yet.")
  /// Link
  internal static let addJoinScreenLinkTitle = L10n.tr("Localizable", "add_join_screen_link_title", fallback: "Link")
  /// You can add this card to Bink and show the onscreen barcode at the till to collect points.
  internal static let addJoinScreenStoreDescription = L10n.tr("Localizable", "add_join_screen_store_description", fallback: "You can add this card to Bink and show the onscreen barcode at the till to collect points.")
  /// Store
  internal static let addJoinScreenStoreTitle = L10n.tr("Localizable", "add_join_screen_store_title", fallback: "Store")
  /// You can see your live points balance and transaction history for this card in Bink.
  internal static let addJoinScreenViewDescription = L10n.tr("Localizable", "add_join_screen_view_description", fallback: "You can see your live points balance and transaction history for this card in Bink.")
  /// You cannot see your live points balance and transaction history for this card in Bink.
  internal static let addJoinScreenViewDescriptionInactive = L10n.tr("Localizable", "add_join_screen_view_description_inactive", fallback: "You cannot see your live points balance and transaction history for this card in Bink.")
  /// View
  internal static let addJoinScreenViewTitle = L10n.tr("Localizable", "add_join_screen_view_title", fallback: "View")
  /// There was a problem adding your loyalty card. Please try again.
  internal static let addLoyaltyCardErrorMessage = L10n.tr("Localizable", "add_loyalty_card_error_message", fallback: "There was a problem adding your loyalty card. Please try again.")
  /// Add loyalty card
  internal static let addLoyaltyCardTitle = L10n.tr("Localizable", "add_loyalty_card_title", fallback: "Add loyalty card")
  /// Add my card
  internal static let addMyCardButton = L10n.tr("Localizable", "add_my_card_button", fallback: "Add my card")
  /// Add payment card
  internal static let addPaymentCardTitle = L10n.tr("Localizable", "add_payment_card_title", fallback: "Add payment card")
  /// There was a problem adding your payment card. Please try again.
  internal static let addPaymentErrorMessage = L10n.tr("Localizable", "add_payment_error_message", fallback: "There was a problem adding your payment card. Please try again.")
  /// Error Adding Card
  internal static let addPaymentErrorTitle = L10n.tr("Localizable", "add_payment_error_title", fallback: "Error Adding Card")
  /// While your card is pending it cannot be deleted. Please try again later.
  internal static let alertViewCannotDeleteCardBody = L10n.tr("Localizable", "alert_view_cannot_delete_card_body", fallback: "While your card is pending it cannot be deleted. Please try again later.")
  /// Cannot delete
  internal static let alertViewCannotDeleteCardTitle = L10n.tr("Localizable", "alert_view_cannot_delete_card_title", fallback: "Cannot delete")
  /// Changing Sort
  internal static let alertViewChangingSort = L10n.tr("Localizable", "alert_view_changing_sort", fallback: "Changing Sort")
  /// Some of your cards have been ordered manually. Press OK to change the sort order, but please note that your manual ordering of cards will be lost.
  internal static let alertViewChangingSortBody = L10n.tr("Localizable", "alert_view_changing_sort_body", fallback: "Some of your cards have been ordered manually. Press OK to change the sort order, but please note that your manual ordering of cards will be lost.")
  /// All
  internal static let allTitle = L10n.tr("Localizable", "all_title", fallback: "All")
  /// Please enter your credentials below to add this card to your wallet.
  internal static let authScreenCustomCardDescription = L10n.tr("Localizable", "auth_screen_custom_card_description", fallback: "Please enter your credentials below to add this card to your wallet.")
  /// Please enter your %@ credentials below to add this card to your wallet.
  internal static func authScreenDescription(_ p1: Any) -> String {
    return L10n.tr("Localizable", "auth_screen_description", String(describing: p1), fallback: "Please enter your %@ credentials below to add this card to your wallet.")
  }
  /// Show this barcode in-store just like you would a physical loyalty card.
  internal static let barcodeCardDescription = L10n.tr("Localizable", "barcode_card_description", fallback: "Show this barcode in-store just like you would a physical loyalty card.")
  /// Share this number in-store or online just like you would a physical loyalty card.
  internal static let barcodeCardNumberDescription = L10n.tr("Localizable", "barcode_card_number_description", fallback: "Share this number in-store or online just like you would a physical loyalty card.")
  /// Copy
  internal static let barcodeCopyLabel = L10n.tr("Localizable", "barcode_copy_label", fallback: "Copy")
  /// Scan this barcode at the store, just like you would a physical coupon. Bear in mind that some store scanners cannot read from screens.
  internal static let barcodeCouponDescription = L10n.tr("Localizable", "barcode_coupon_description", fallback: "Scan this barcode at the store, just like you would a physical coupon. Bear in mind that some store scanners cannot read from screens.")
  /// This barcode cannot be displayed
  internal static let barcodeError = L10n.tr("Localizable", "barcode_error", fallback: "This barcode cannot be displayed")
  /// Maximise barcode
  internal static let barcodeMaximiseButton = L10n.tr("Localizable", "barcode_maximise_button", fallback: "Maximise barcode")
  /// %@ Number
  internal static func barcodeMembershipNumberTitle(_ p1: Any) -> String {
    return L10n.tr("Localizable", "barcode_membership_number_title", String(describing: p1), fallback: "%@ Number")
  }
  /// Report Issue
  internal static let barcodeReportIssueButtonTitle = L10n.tr("Localizable", "barcode_report_issue_button_title", fallback: "Report Issue")
  /// We're sorry you're experiencing an issue. Thank you for reporting it to us
  internal static let barcodeReportIssueTitle = L10n.tr("Localizable", "barcode_report_issue_title", fallback: "We're sorry you're experiencing an issue. Thank you for reporting it to us")
  /// Barcode
  internal static let barcodeSwipeTitle = L10n.tr("Localizable", "barcode_swipe_title", fallback: "Barcode")
  /// Barcode
  internal static let barcodeTitle = L10n.tr("Localizable", "barcode_title", fallback: "Barcode")
  /// Card number:
  internal static let barcodeViewTitle = L10n.tr("Localizable", "barcode_view_title", fallback: "Card number:")
  /// We can only show you cards with barcodes or vouchers
  internal static let brandsListNoSupportedCardsDescription = L10n.tr("Localizable", "brands_list_no_supported_cards_description", fallback: "We can only show you cards with barcodes or vouchers")
  /// No supported cards
  internal static let brandsListNoSupportedCardsTitle = L10n.tr("Localizable", "brands_list_no_supported_cards_title", fallback: "No supported cards")
  /// Browse brands
  internal static let browseBrandsTitle = L10n.tr("Localizable", "browse_brands_title", fallback: "Browse brands")
  /// Allow Access
  internal static let cameraDeniedAllowAccess = L10n.tr("Localizable", "camera_denied_allow_access", fallback: "Allow Access")
  /// To scan your cards, you’ll need to allow Bink access to your device’s camera.
  internal static let cameraDeniedBody = L10n.tr("Localizable", "camera_denied_body", fallback: "To scan your cards, you’ll need to allow Bink access to your device’s camera.")
  /// Enter Manually
  internal static let cameraDeniedManuallyOption = L10n.tr("Localizable", "camera_denied_manually_option", fallback: "Enter Manually")
  /// Please allow camera access
  internal static let cameraDeniedTitle = L10n.tr("Localizable", "camera_denied_title", fallback: "Please allow camera access")
  /// OK
  internal static let cameraPermissionAllowOption = L10n.tr("Localizable", "camera_permission_allow_option", fallback: "OK")
  /// We need your camera to scan loyalty cards. It will not be used for other purposes.
  internal static let cameraPermissionBody = L10n.tr("Localizable", "camera_permission_body", fallback: "We need your camera to scan loyalty cards. It will not be used for other purposes.")
  /// Don't Allow
  internal static let cameraPermissionDenyOption = L10n.tr("Localizable", "camera_permission_deny_option", fallback: "Don't Allow")
  /// Bink needs camera access
  internal static let cameraPermissionTitle = L10n.tr("Localizable", "camera_permission_title", fallback: "Bink needs camera access")
  /// Can be linked to your payment cards
  internal static let canBeLinkedDescription = L10n.tr("Localizable", "can_be_linked_description", fallback: "Can be linked to your payment cards")
  /// Cancel
  internal static let cancel = L10n.tr("Localizable", "cancel", fallback: "Cancel")
  /// %@ already linked to a different %@. Please unlink the other %@ before proceeding, but be aware this may only be possible from another application.
  internal static func cardAlreadyLinkedMessage(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
    return L10n.tr("Localizable", "card_already_linked_message", String(describing: p1), String(describing: p2), String(describing: p3), fallback: "%@ already linked to a different %@. Please unlink the other %@ before proceeding, but be aware this may only be possible from another application.")
  }
  /// This payment card is
  internal static let cardAlreadyLinkedMessagePrefix = L10n.tr("Localizable", "card_already_linked_message_prefix", fallback: "This payment card is")
  /// Already Linked
  internal static let cardAlreadyLinkedTitle = L10n.tr("Localizable", "card_already_linked_title", fallback: "Already Linked")
  /// Cannot Link
  internal static let cardCanNotLinkStatus = L10n.tr("Localizable", "card_can_not_link_status", fallback: "Cannot Link")
  /// Link now
  internal static let cardLinkNowStatus = L10n.tr("Localizable", "card_link_now_status", fallback: "Link now")
  /// Link
  internal static let cardLinkStatus = L10n.tr("Localizable", "card_link_status", fallback: "Link")
  /// Linked
  internal static let cardLinkedStatus = L10n.tr("Localizable", "card_linked_status", fallback: "Linked")
  /// Linking
  internal static let cardLinkingStatus = L10n.tr("Localizable", "card_linking_status", fallback: "Linking")
  /// One of these payment cards are
  internal static let cardsAlreadyLinkedMessagePrefix = L10n.tr("Localizable", "cards_already_linked_message_prefix", fallback: "One of these payment cards are")
  /// We have just emailed a link to %@. Click the link and you will be signed in.
  internal static func checkInboxDescription(_ p1: Any) -> String {
    return L10n.tr("Localizable", "check_inbox_description", String(describing: p1), fallback: "We have just emailed a link to %@. Click the link and you will be signed in.")
  }
  /// Check your inbox!
  internal static let checkInboxTitle = L10n.tr("Localizable", "check_inbox_title", fallback: "Check your inbox!")
  /// There was a problem communicating with the server. Please try again later.
  internal static let communicationError = L10n.tr("Localizable", "communication_error", fallback: "There was a problem communicating with the server. Please try again later.")
  /// Contact Us
  internal static let contactUsActionTitle = L10n.tr("Localizable", "contact_us_action_title", fallback: "Contact Us")
  /// Continue
  internal static let continueButtonTitle = L10n.tr("Localizable", "continue_button_title", fallback: "Continue")
  /// Enter credentials
  internal static let credentialsTitle = L10n.tr("Localizable", "credentials_title", fallback: "Enter credentials")
  /// Other card
  internal static let customCardCompanyName = L10n.tr("Localizable", "custom_card_company_name", fallback: "Other card")
  /// Enter name of store
  internal static let customCardNameAddFieldDescription = L10n.tr("Localizable", "custom_card_name_add_field_description", fallback: "Enter name of store")
  /// Store name
  internal static let customCardNameAddFieldTitle = L10n.tr("Localizable", "custom_card_name_add_field_title", fallback: "Store name")
  /// Enter card number
  internal static let customCardNumberAddFieldDescription = L10n.tr("Localizable", "custom_card_number_add_field_description", fallback: "Enter card number")
  /// Card number
  internal static let customCardNumberAddFieldTitle = L10n.tr("Localizable", "custom_card_number_add_field_title", fallback: "Card number")
  /// day
  internal static let day = L10n.tr("Localizable", "day", fallback: "day")
  /// days
  internal static let days = L10n.tr("Localizable", "days", fallback: "days")
  /// Tools
  internal static let debugMenuToolsSectionTitle = L10n.tr("Localizable", "debug_menu_tools_section_title", fallback: "Tools")
  /// Decline
  internal static let decline = L10n.tr("Localizable", "decline", fallback: "Decline")
  /// Delete
  internal static let deleteActionTitle = L10n.tr("Localizable", "delete_action_title", fallback: "Delete")
  /// Are you sure you want to delete this card?
  internal static let deleteCardConfirmation = L10n.tr("Localizable", "delete_card_confirmation", fallback: "Are you sure you want to delete this card?")
  /// Remove this card from Bink
  internal static let deleteCardMessage = L10n.tr("Localizable", "delete_card_message", fallback: "Remove this card from Bink")
  /// Delete %@
  internal static func deleteCardPlanTitle(_ p1: Any) -> String {
    return L10n.tr("Localizable", "delete_card_plan_title", String(describing: p1), fallback: "Delete %@")
  }
  /// Delete this card
  internal static let deleteCardTitle = L10n.tr("Localizable", "delete_card_title", fallback: "Delete this card")
  /// Tap to enlarge Aztec code
  internal static let detailsHeaderShowAztecCode = L10n.tr("Localizable", "details_header_show_aztec_code", fallback: "Tap to enlarge Aztec code")
  /// Tap to enlarge barcode
  internal static let detailsHeaderShowBarcode = L10n.tr("Localizable", "details_header_show_barcode", fallback: "Tap to enlarge barcode")
  /// Tap to show card number
  internal static let detailsHeaderShowCardNumber = L10n.tr("Localizable", "details_header_show_card_number", fallback: "Tap to show card number")
  /// Tap to enlarge QR code
  internal static let detailsHeaderShowQrCode = L10n.tr("Localizable", "details_header_show_qr_code", fallback: "Tap to enlarge QR code")
  /// Done
  internal static let done = L10n.tr("Localizable", "done", fallback: "Done")
  /// Use magic link
  internal static let emailMagicLink = L10n.tr("Localizable", "email_magic_link", fallback: "Use magic link")
  /// No rewards to display. Come back
  ///  after you've earned vouchers to see
  ///  your issued, redeemed or expired
  ///  rewards
  internal static let emptyRewards = L10n.tr("Localizable", "empty_rewards", fallback: "No rewards to display. Come back\n after you've earned vouchers to see\n your issued, redeemed or expired\n rewards")
  /// Localizable.strings
  ///   binkapp
  /// 
  ///   Copyright © 2019 Bink. All rights reserved.
  internal static let errorTitle = L10n.tr("Localizable", "error_title", fallback: "Error")
  /// Filters
  internal static let filtersButtonTitle = L10n.tr("Localizable", "filters_button_title", fallback: "Filters")
  /// Find and join loyalty schemes
  internal static let findAndJoinDescription = L10n.tr("Localizable", "find_and_join_description", fallback: "Find and join loyalty schemes")
  /// Find your nearest store
  internal static let findNearestStore = L10n.tr("Localizable", "find_nearest_store", fallback: "Find your nearest store")
  /// If the email address you entered is associated with a Bink account, then a password reset email will be sent.
  internal static let fogrotPasswordPopupText = L10n.tr("Localizable", "fogrot_password_popup_text", fallback: "If the email address you entered is associated with a Bink account, then a password reset email will be sent.")
  /// Please enter your email address and if it is associated with a Bink account, then a password reset email will be sent
  internal static let forgotPasswordDescription = L10n.tr("Localizable", "forgot_password_description", fallback: "Please enter your email address and if it is associated with a Bink account, then a password reset email will be sent")
  /// Incorrect Format
  internal static let formFieldValidationError = L10n.tr("Localizable", "form_field_validation_error", fallback: "Incorrect Format")
  /// Please wait while we work with the merchant to set up your card. This shouldn’t take long.
  internal static let genericPendingModuleDescription = L10n.tr("Localizable", "generic_pending_module_description", fallback: "Please wait while we work with the merchant to set up your card. This shouldn’t take long.")
  /// Request pending
  internal static let genericPendingModuleTitle = L10n.tr("Localizable", "generic_pending_module_title", fallback: "Request pending")
  /// Get a new card
  internal static let getNewCardButton = L10n.tr("Localizable", "get_new_card_button", fallback: "Get a new card")
  /// Go to site
  internal static let goToSiteButton = L10n.tr("Localizable", "go_to_site_button", fallback: "Go to site")
  /// History
  internal static let historyTitle = L10n.tr("Localizable", "history_title", fallback: "History")
  /// hour
  internal static let hour = L10n.tr("Localizable", "hour", fallback: "hour")
  /// hours
  internal static let hours = L10n.tr("Localizable", "hours", fallback: "hours")
  /// Bink is the only app where you can store and view all your loyalty programmes on your mobile, and link your everyday payment cards to automatically collect points and rewards.
  /// Through our unique technology platform, Payment Linked Loyalty, you can use your everyday payment cards to automatically collect rewards. Using Bink, you will never miss rewards opportunities from your favourite brands again.
  internal static let howItWorksDescription = L10n.tr("Localizable", "how_it_works_description", fallback: "Bink is the only app where you can store and view all your loyalty programmes on your mobile, and link your everyday payment cards to automatically collect points and rewards.\nThrough our unique technology platform, Payment Linked Loyalty, you can use your everyday payment cards to automatically collect rewards. Using Bink, you will never miss rewards opportunities from your favourite brands again.")
  /// How it works
  internal static let howItWorksTitle = L10n.tr("Localizable", "how_it_works_title", fallback: "How it works")
  /// I accept
  internal static let iAccept = L10n.tr("Localizable", "i_accept", fallback: "I accept")
  /// I decline
  internal static let iDecline = L10n.tr("Localizable", "i_decline", fallback: "I decline")
  /// Info
  internal static let infoTitle = L10n.tr("Localizable", "info_title", fallback: "Info")
  /// Issues logging in?
  internal static let issuesLoggingIn = L10n.tr("Localizable", "issues_logging_in", fallback: "Issues logging in?")
  /// Learn more about how it works
  internal static let learnMore = L10n.tr("Localizable", "learn_more", fallback: "Learn more about how it works")
  /// To keep your account safe, links are only valid for a short period of time. Tap Retry and we will send you another.
  internal static let linkExpiredDescription = L10n.tr("Localizable", "link_expired_description", fallback: "To keep your account safe, links are only valid for a short period of time. Tap Retry and we will send you another.")
  /// Link expired
  internal static let linkExpiredTitle = L10n.tr("Localizable", "link_expired_title", fallback: "Link expired")
  /// Link error
  internal static let linkModuleErrorTitle = L10n.tr("Localizable", "link_module_error_title", fallback: "Link error")
  /// To link to cards
  internal static let linkModuleToLinkToCardsMessage = L10n.tr("Localizable", "link_module_to_link_to_cards_message", fallback: "To link to cards")
  /// To %d of %d card
  internal static func linkModuleToNumberOfPaymentCardMessage(_ p1: Int, _ p2: Int) -> String {
    return L10n.tr("Localizable", "link_module_to_number_of_payment_card_message", p1, p2, fallback: "To %d of %d card")
  }
  /// To %d of %d cards
  internal static func linkModuleToNumberOfPaymentCardsMessage(_ p1: Int, _ p2: Int) -> String {
    return L10n.tr("Localizable", "link_module_to_number_of_payment_cards_message", p1, p2, fallback: "To %d of %d cards")
  }
  /// To payment cards
  internal static let linkModuleToPaymentCardsMessage = L10n.tr("Localizable", "link_module_to_payment_cards_message", fallback: "To payment cards")
  /// linked
  internal static let linkedStatusImageName = L10n.tr("Localizable", "linked_status_image_name", fallback: "linked")
  /// There was a problem loading the page, please try again later.
  internal static let loadingError = L10n.tr("Localizable", "loading_error", fallback: "There was a problem loading the page, please try again later.")
  /// Locations
  internal static let locations = L10n.tr("Localizable", "locations", fallback: "Locations")
  /// Log in failed
  internal static let logInFailedTitle = L10n.tr("Localizable", "log_in_failed_title", fallback: "Log in failed")
  /// You are seeing this because sometimes it takes a while to log in with the merchant. In the meantime please do not attempt to log in again, but you can use your card and receive your benefits as usual. After you are logged in you will be able to see your points balance.
  internal static let logInPendingDescription = L10n.tr("Localizable", "log_in_pending_description", fallback: "You are seeing this because sometimes it takes a while to log in with the merchant. In the meantime please do not attempt to log in again, but you can use your card and receive your benefits as usual. After you are logged in you will be able to see your points balance.")
  /// Log in pending
  internal static let logInPendingTitle = L10n.tr("Localizable", "log_in_pending_title", fallback: "Log in pending")
  /// Log in
  internal static let logInTitle = L10n.tr("Localizable", "log_in_title", fallback: "Log in")
  /// Log in
  internal static let login = L10n.tr("Localizable", "login", fallback: "Log in")
  /// Incorrect email/password. Please try again.
  internal static let loginError = L10n.tr("Localizable", "login_error", fallback: "Incorrect email/password. Please try again.")
  /// Forgot password
  internal static let loginForgotPassword = L10n.tr("Localizable", "login_forgot_password", fallback: "Forgot password")
  /// Issues logging in?
  internal static let loginIssues = L10n.tr("Localizable", "login_issues", fallback: "Issues logging in?")
  /// Welcome back!
  internal static let loginSubtitle = L10n.tr("Localizable", "login_subtitle", fallback: "Welcome back!")
  /// You are now logged in with %@ and will remain logged in on this device until you choose to log out.
  /// You can log out from settings.
  internal static func loginSuccesSubtitle(_ p1: Any) -> String {
    return L10n.tr("Localizable", "login_succes_subtitle", String(describing: p1), fallback: "You are now logged in with %@ and will remain logged in on this device until you choose to log out.\nYou can log out from settings.")
  }
  /// Success
  internal static let loginSuccessTitle = L10n.tr("Localizable", "login_success_title", fallback: "Success")
  /// Log in
  internal static let loginTitle = L10n.tr("Localizable", "login_title", fallback: "Log in")
  /// Continue with Email
  internal static let loginWithEmailButton = L10n.tr("Localizable", "login_with_email_button", fallback: "Continue with Email")
  /// Use a password
  internal static let loginWithPassword = L10n.tr("Localizable", "login_with_password", fallback: "Use a password")
  /// Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pellentesque, nisi ut sagittis luctus, justo orci porttitor nulla, ac ultricies sem mi quis nunc. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Curabitur placerat sagittis tortor quis vehicula. Fusce et aliquam tellus, eu semper sem. Proin eu eleifend nunc. Aliquam id lacus faucibus, euismod orci in, tempor felis. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam finibus commodo dui sit amet imperdiet. Phasellus tincidunt elementum euismod. Aliquam lobortis sapien in justo varius pulvinar. Morbi ac placerat sem. Maecenas ut auctor purus.Etiam quis blandit sapien. Nam urna quam, tempus ut massa sed, blandit ultrices neque. Sed sagittis vel quam ac interdum. Nunc tempus eros eget leo volutpat, ac sodales ex scelerisque. Aenean vel nibh lacus. Sed convallis faucibus euismod. Sed diam dui, commodo blandit tempus in, faucibus quis ligula. Integer condimentum mollis bibendum. Nullam feugiat rutrum mauris a luctus. Morbi dignissim, orci ac tempor bibendum, augue diam pharetra massa, vel commodo leo sem sed nisl. Pellentesque egestas egestas quam, nec laoreet dolor. Curabitur commodo scelerisque nisl ac mollis. Morbi egestas arcu nec convallis mollis.
  internal static let loremIpsum = L10n.tr("Localizable", "lorem_ipsum", fallback: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pellentesque, nisi ut sagittis luctus, justo orci porttitor nulla, ac ultricies sem mi quis nunc. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Curabitur placerat sagittis tortor quis vehicula. Fusce et aliquam tellus, eu semper sem. Proin eu eleifend nunc. Aliquam id lacus faucibus, euismod orci in, tempor felis. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam finibus commodo dui sit amet imperdiet. Phasellus tincidunt elementum euismod. Aliquam lobortis sapien in justo varius pulvinar. Morbi ac placerat sem. Maecenas ut auctor purus.Etiam quis blandit sapien. Nam urna quam, tempus ut massa sed, blandit ultrices neque. Sed sagittis vel quam ac interdum. Nunc tempus eros eget leo volutpat, ac sodales ex scelerisque. Aenean vel nibh lacus. Sed convallis faucibus euismod. Sed diam dui, commodo blandit tempus in, faucibus quis ligula. Integer condimentum mollis bibendum. Nullam feugiat rutrum mauris a luctus. Morbi dignissim, orci ac tempor bibendum, augue diam pharetra massa, vel commodo leo sem sed nisl. Pellentesque egestas egestas quam, nec laoreet dolor. Curabitur commodo scelerisque nisl ac mollis. Morbi egestas arcu nec convallis mollis.")
  /// Add from Photo Library
  internal static let loyaltyScannerAddPhotoFromLibraryButtonTitle = L10n.tr("Localizable", "loyalty_scanner_add_photo_from_library_button_title", fallback: "Add from Photo Library")
  /// Hold card here. It will scan automatically.
  internal static let loyaltyScannerExplainerText = L10n.tr("Localizable", "loyalty_scanner_explainer_text", fallback: "Hold card here. It will scan automatically.")
  /// Scanning disabled - please allow camera access
  internal static let loyaltyScannerExplainerTextPermissionDenied = L10n.tr("Localizable", "loyalty_scanner_explainer_text_permission_denied", fallback: "Scanning disabled - please allow camera access")
  /// Failed to detect barcode in the image, please try again
  internal static let loyaltyScannerFailedToDetectBarcode = L10n.tr("Localizable", "loyalty_scanner_failed_to_detect_barcode", fallback: "Failed to detect barcode in the image, please try again")
  /// Add Custom
  internal static let loyaltyScannerUnrecognizedBarcodeAlertAddCustomButtonText = L10n.tr("Localizable", "loyalty_scanner_unrecognized_barcode_alert_add_custom_button_text", fallback: "Add Custom")
  /// Would you like to add this to your wallet anyway?
  internal static let loyaltyScannerUnrecognizedBarcodeAlertDescription = L10n.tr("Localizable", "loyalty_scanner_unrecognized_barcode_alert_description", fallback: "Would you like to add this to your wallet anyway?")
  /// You can also type in the card details yourself.
  internal static let loyaltyScannerWidgetExplainerEnterManuallyText = L10n.tr("Localizable", "loyalty_scanner_widget_explainer_enter_manually_text", fallback: "You can also type in the card details yourself.")
  /// Please try adding the card manually.
  internal static let loyaltyScannerWidgetExplainerUnrecognizedBarcodeText = L10n.tr("Localizable", "loyalty_scanner_widget_explainer_unrecognized_barcode_text", fallback: "Please try adding the card manually.")
  /// Enter manually
  internal static let loyaltyScannerWidgetTitleEnterManuallyText = L10n.tr("Localizable", "loyalty_scanner_widget_title_enter_manually_text", fallback: "Enter manually")
  /// Unrecognised barcode
  internal static let loyaltyScannerWidgetTitleUnrecognizedBarcodeText = L10n.tr("Localizable", "loyalty_scanner_widget_title_unrecognized_barcode_text", fallback: "Unrecognised barcode")
  /// You should have received an SMS containing an auth code from Nectar, please enter this below
  internal static let lpcNectarUserInputAlertBody = L10n.tr("Localizable", "lpc_nectar_user_input_alert_body", fallback: "You should have received an SMS containing an auth code from Nectar, please enter this below")
  /// Nectar auth code
  internal static let lpcNectarUserInputAlertTitle = L10n.tr("Localizable", "lpc_nectar_user_input_alert_title", fallback: "Nectar auth code")
  /// Your %@ account balance was last updated %@. Bink will try to update this account every %@.
  internal static func lpcPointsModuleBalanceExplainerBody(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
    return L10n.tr("Localizable", "lpc_points_module_balance_explainer_body", String(describing: p1), String(describing: p2), String(describing: p3), fallback: "Your %@ account balance was last updated %@. Bink will try to update this account every %@.")
  }
  /// Your %@ account balance was last updated %@. Bink will try to update this account every %@.
  /// 
  /// A balance refresh for this card is currently in progress and will update shortly.
  internal static func lpcPointsModuleBalanceExplainerBodyRefreshRequested(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
    return L10n.tr("Localizable", "lpc_points_module_balance_explainer_body_refresh_requested", String(describing: p1), String(describing: p2), String(describing: p3), fallback: "Your %@ account balance was last updated %@. Bink will try to update this account every %@.\n\nA balance refresh for this card is currently in progress and will update shortly.")
  }
  /// Your %@ account balance was last updated %@. Bink will try to update this account every %@.
  /// 
  /// You can manually refresh your balance using the button below.
  internal static func lpcPointsModuleBalanceExplainerBodyRefreshable(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
    return L10n.tr("Localizable", "lpc_points_module_balance_explainer_body_refreshable", String(describing: p1), String(describing: p2), String(describing: p3), fallback: "Your %@ account balance was last updated %@. Bink will try to update this account every %@.\n\nYou can manually refresh your balance using the button below.")
  }
  /// %@ ago
  internal static func lpcPointsModuleBalanceExplainerBodyTimeAgo(_ p1: Any) -> String {
    return L10n.tr("Localizable", "lpc_points_module_balance_explainer_body_time_ago", String(describing: p1), fallback: "%@ ago")
  }
  /// Refresh
  internal static let lpcPointsModuleBalanceExplainerButtonTitle = L10n.tr("Localizable", "lpc_points_module_balance_explainer_button_title", fallback: "Refresh")
  /// Balance
  internal static let lpcPointsModuleBalanceExplainerTitle = L10n.tr("Localizable", "lpc_points_module_balance_explainer_title", fallback: "Balance")
  /// Would you like to log in to %@?
  internal static func magicLinkAlreadyLoggedInDescription(_ p1: Any) -> String {
    return L10n.tr("Localizable", "magic_link_already_logged_in_description", String(describing: p1), fallback: "Would you like to log in to %@?")
  }
  /// Already Logged In
  internal static let magicLinkAlreadyLoggedInTitle = L10n.tr("Localizable", "magic_link_already_logged_in_title", fallback: "Already Logged In")
  /// Get a link sent to your inbox so you can register or access your account instantly!
  /// 
  /// Note: We will send you a Magic Link
  internal static let magicLinkDescription = L10n.tr("Localizable", "magic_link_description", fallback: "Get a link sent to your inbox so you can register or access your account instantly!\n\nNote: We will send you a Magic Link")
  /// Note:
  internal static let magicLinkDescriptionNoteHighlight = L10n.tr("Localizable", "magic_link_description_note_highlight", fallback: "Note:")
  /// Magic Link is temporarily unavailable, please try again later.
  internal static let magicLinkErrorMessage = L10n.tr("Localizable", "magic_link_error_message", fallback: "Magic Link is temporarily unavailable, please try again later.")
  /// Continue with email
  internal static let magicLinkTitle = L10n.tr("Localizable", "magic_link_title", fallback: "Continue with email")
  /// Opt in to receive marketing messages.
  internal static let marketingTitle = L10n.tr("Localizable", "marketing_title", fallback: "Opt in to receive marketing messages.")
  /// Membership number
  internal static let membershipNumberTitle = L10n.tr("Localizable", "membership_number_title", fallback: "Membership number")
  /// minute
  internal static let minute = L10n.tr("Localizable", "minute", fallback: "minute")
  /// minutes
  internal static let minutes = L10n.tr("Localizable", "minutes", fallback: "minutes")
  /// %@ does not support signing up for a new loyalty account via the Bink app.
  /// 
  /// Please go to the merchant’s website to sign up for a card, then return to the Bink app and add your new card details.
  internal static func nativeJoinUnavailableDescription(_ p1: Any) -> String {
    return L10n.tr("Localizable", "native_join_unavailable_description", String(describing: p1), fallback: "%@ does not support signing up for a new loyalty account via the Bink app.\n\nPlease go to the merchant’s website to sign up for a card, then return to the Bink app and add your new card details.")
  }
  /// Sign up not supported
  internal static let nativeJoinUnavailableTitle = L10n.tr("Localizable", "native_join_unavailable_title", fallback: "Sign up not supported")
  /// your email address
  internal static let nilEmailAddress = L10n.tr("Localizable", "nil_email_address", fallback: "your email address")
  /// No
  internal static let no = L10n.tr("Localizable", "no", fallback: "No")
  /// I don't have an account
  internal static let noAccountButtonTitle = L10n.tr("Localizable", "no_account_button_title", fallback: "I don't have an account")
  /// You are currently offline. This action cannot be performed whilst offline. Please check your internet connection and try again.
  internal static let noInternetConnectionMessage = L10n.tr("Localizable", "no_internet_connection_message", fallback: "You are currently offline. This action cannot be performed whilst offline. Please check your internet connection and try again.")
  /// No matches
  internal static let noMatches = L10n.tr("Localizable", "no_matches", fallback: "No matches")
  /// Please open the Bink app on your phone to sync with your watch
  internal static let noResponseDesciption = L10n.tr("Localizable", "no_response_desciption", fallback: "Please open the Bink app on your phone to sync with your watch")
  /// No response from phone
  internal static let noResponseTitle = L10n.tr("Localizable", "no_response_title", fallback: "No response from phone")
  /// Not available
  internal static let notAvailableTitle = L10n.tr("Localizable", "not_available_title", fallback: "Not available")
  /// OK
  internal static let ok = L10n.tr("Localizable", "ok", fallback: "OK")
  /// Link your payment cards to selected loyalty cards and earn rewards and benefits automatically when you pay.
  internal static let onboardingSlide1Body = L10n.tr("Localizable", "onboarding_slide1_body", fallback: "Link your payment cards to selected loyalty cards and earn rewards and benefits automatically when you pay.")
  /// Payment linked loyalty. Magic!
  internal static let onboardingSlide1Header = L10n.tr("Localizable", "onboarding_slide1_header", fallback: "Payment linked loyalty. Magic!")
  /// Store all your loyalty cards in a single digital wallet. View your rewards and points balances any time, anywhere.
  internal static let onboardingSlide2Body = L10n.tr("Localizable", "onboarding_slide2_body", fallback: "Store all your loyalty cards in a single digital wallet. View your rewards and points balances any time, anywhere.")
  /// All your cards in one place
  internal static let onboardingSlide2Header = L10n.tr("Localizable", "onboarding_slide2_header", fallback: "All your cards in one place")
  /// Show your loyalty cards’ barcodes on screen, or collect points instantly when you pay. Whichever way, you’re always covered.
  internal static let onboardingSlide3Body = L10n.tr("Localizable", "onboarding_slide3_body", fallback: "Show your loyalty cards’ barcodes on screen, or collect points instantly when you pay. Whichever way, you’re always covered.")
  /// Never miss out
  internal static let onboardingSlide3Header = L10n.tr("Localizable", "onboarding_slide3_header", fallback: "Never miss out")
  /// You can log in to your %@ account to see your points balance. This is optional.
  internal static func onlyPointsLogInDescription(_ p1: Any) -> String {
    return L10n.tr("Localizable", "only_points_log_in_description", String(describing: p1), fallback: "You can log in to your %@ account to see your points balance. This is optional.")
  }
  /// Oops
  internal static let oops = L10n.tr("Localizable", "oops", fallback: "Oops")
  /// Open your email app
  internal static let openMailAlertTitle = L10n.tr("Localizable", "open_mail_alert_title", fallback: "Open your email app")
  /// Open %@
  internal static func openMailButtonTitle(_ p1: Any) -> String {
    return L10n.tr("Localizable", "open_mail_button_title", String(describing: p1), fallback: "Open %@")
  }
  /// Open Inbox
  internal static let openMailButtonTitleMultipleClients = L10n.tr("Localizable", "open_mail_button_title_multiple_clients", fallback: "Open Inbox")
  /// This payment card has expired
  internal static let paymentCardExpiredAlertMessage = L10n.tr("Localizable", "payment_card_expired_alert_message", fallback: "This payment card has expired")
  /// This payment card has expired
  internal static let paymentCardExpiredAlertTitle = L10n.tr("Localizable", "payment_card_expired_alert_title", fallback: "This payment card has expired")
  /// Unable to adjust link at this time, if the problem persists please contact support
  internal static let paymentCardLinkFailAlertMessage = L10n.tr("Localizable", "payment_card_link_fail_alert_message", fallback: "Unable to adjust link at this time, if the problem persists please contact support")
  /// Position your card in the frame so the card number is visible
  internal static let paymentScannerExplainerText = L10n.tr("Localizable", "payment_scanner_explainer_text", fallback: "Position your card in the frame so the card number is visible")
  /// You can also type in the card details yourself
  internal static let paymentScannerWidgetExplainerText = L10n.tr("Localizable", "payment_scanner_widget_explainer_text", fallback: "You can also type in the card details yourself")
  /// Enter Manually
  internal static let paymentScannerWidgetTitle = L10n.tr("Localizable", "payment_scanner_widget_title", fallback: "Enter Manually")
  /// The active loyalty cards below are linked to this payment card. Simply pay as usual to collect points.
  internal static let pcdActiveCardDescription = L10n.tr("Localizable", "pcd_active_card_description", fallback: "The active loyalty cards below are linked to this payment card. Simply pay as usual to collect points.")
  /// Linked cards
  internal static let pcdActiveCardTitle = L10n.tr("Localizable", "pcd_active_card_title", fallback: "Linked cards")
  /// Add card
  internal static let pcdAddCardButtonTitle = L10n.tr("Localizable", "pcd_add_card_button_title", fallback: "Add card")
  /// Your payment card has expired. Please use the “Delete this card” action below to remove it from your wallet and add your new payment card if applicable. 
  /// 
  /// If you have any concerns, please read the FAQs or you can get in touch with Bink by pressing Contact us.
  internal static let pcdExpiredCardDescription = L10n.tr("Localizable", "pcd_expired_card_description", fallback: "Your payment card has expired. Please use the “Delete this card” action below to remove it from your wallet and add your new payment card if applicable. \n\nIf you have any concerns, please read the FAQs or you can get in touch with Bink by pressing Contact us.")
  /// Payment card expired
  internal static let pcdExpiredCardTitle = L10n.tr("Localizable", "pcd_expired_card_title", fallback: "Payment card expired")
  /// Your payment card is not authorised and you cannot link any loyalty cards to start earning rewards.
  /// 
  /// Your card has failed the authorisation process or has expired. Please use the “Delete this card” action below to remove it from your wallet and re-add if required.
  /// 
  /// If you have any concerns, please read the FAQs or you can get in touch with Bink by pressing Contact us.
  internal static let pcdFailedCardDescription = L10n.tr("Localizable", "pcd_failed_card_description", fallback: "Your payment card is not authorised and you cannot link any loyalty cards to start earning rewards.\n\nYour card has failed the authorisation process or has expired. Please use the “Delete this card” action below to remove it from your wallet and re-add if required.\n\nIf you have any concerns, please read the FAQs or you can get in touch with Bink by pressing Contact us.")
  /// Payment card inactive
  internal static let pcdFailedCardTitle = L10n.tr("Localizable", "pcd_failed_card_title", fallback: "Payment card inactive")
  /// You can also add the cards below and link them to your payment cards.
  internal static let pcdOtherCardDescriptionCardsAdded = L10n.tr("Localizable", "pcd_other_card_description_cards_added", fallback: "You can also add the cards below and link them to your payment cards.")
  /// You do not have any linked loyalty cards. Add some cards to collect points.
  internal static let pcdOtherCardDescriptionNoCardsAdded = L10n.tr("Localizable", "pcd_other_card_description_no_cards_added", fallback: "You do not have any linked loyalty cards. Add some cards to collect points.")
  /// Other cards you can add
  internal static let pcdOtherCardTitleCardsAdded = L10n.tr("Localizable", "pcd_other_card_title_cards_added", fallback: "Other cards you can add")
  /// No linked cards
  internal static let pcdOtherCardTitleNoCardsAdded = L10n.tr("Localizable", "pcd_other_card_title_no_cards_added", fallback: "No linked cards")
  /// Card added: %@
  internal static func pcdPendingCardAdded(_ p1: Any) -> String {
    return L10n.tr("Localizable", "pcd_pending_card_added", String(describing: p1), fallback: "Card added: %@")
  }
  /// You cannot link any loyalty cards to start earning rewards.
  /// 
  /// Please wait for the card to be authorised. If the problem persists please read our FAQs or you can get in touch with Bink by pressing Contact us.
  internal static let pcdPendingCardDescription = L10n.tr("Localizable", "pcd_pending_card_description", fallback: "You cannot link any loyalty cards to start earning rewards.\n\nPlease wait for the card to be authorised. If the problem persists please read our FAQs or you can get in touch with Bink by pressing Contact us.")
  /// Contact us
  internal static let pcdPendingCardHyperlink = L10n.tr("Localizable", "pcd_pending_card_hyperlink", fallback: "Contact us")
  /// Payment card pending
  internal static let pcdPendingCardTitle = L10n.tr("Localizable", "pcd_pending_card_title", fallback: "Payment card pending")
  /// Ready to link
  internal static let pcdStatusTextReadyToLink = L10n.tr("Localizable", "pcd_status_text_ready_to_link", fallback: "Ready to link")
  /// You can link this card
  internal static let pcdYouCanLink = L10n.tr("Localizable", "pcd_you_can_link", fallback: "You can link this card")
  /// Pending
  internal static let pendingTitle = L10n.tr("Localizable", "pending_title", fallback: "Pending")
  /// Please try again
  internal static let pleaseTryAgainTitle = L10n.tr("Localizable", "please_try_again_title", fallback: "Please try again")
  /// Please wait
  internal static let pleaseWaitTitle = L10n.tr("Localizable", "please_wait_title", fallback: "Please wait")
  /// Add these loyalty cards and link them to your payment cards to collect rewards automatically when you pay.
  internal static let pllDescription = L10n.tr("Localizable", "pll_description", fallback: "Add these loyalty cards and link them to your payment cards to collect rewards automatically when you pay.")
  /// automatically
  internal static let pllDescriptionHighlightAutomatically = L10n.tr("Localizable", "pll_description_highlight_automatically", fallback: "automatically")
  /// Unfortunately some of your cards failed to link, please try again later.
  internal static let pllErrorMessage = L10n.tr("Localizable", "pll_error_message", fallback: "Unfortunately some of your cards failed to link, please try again later.")
  /// Error
  internal static let pllErrorTitle = L10n.tr("Localizable", "pll_error_title", fallback: "Error")
  /// Add payment cards
  internal static let pllScreenAddCardsButtonTitle = L10n.tr("Localizable", "pll_screen_add_cards_button_title", fallback: "Add payment cards")
  /// The payment cards below will be linked to your %@. Simply pay with them to collect points.
  internal static func pllScreenAddMessage(_ p1: Any) -> String {
    return L10n.tr("Localizable", "pll_screen_add_message", String(describing: p1), fallback: "The payment cards below will be linked to your %@. Simply pay with them to collect points.")
  }
  /// Add card
  internal static let pllScreenAddTitle = L10n.tr("Localizable", "pll_screen_add_title", fallback: "Add card")
  /// Card ending in %@
  internal static func pllScreenCardEnding(_ p1: Any) -> String {
    return L10n.tr("Localizable", "pll_screen_card_ending", String(describing: p1), fallback: "Card ending in %@")
  }
  /// You have not added any payment cards yet.
  internal static let pllScreenLinkMessage = L10n.tr("Localizable", "pll_screen_link_message", fallback: "You have not added any payment cards yet.")
  /// Link to payment cards
  internal static let pllScreenLinkTitle = L10n.tr("Localizable", "pll_screen_link_title", fallback: "Link to payment cards")
  /// The payment cards below are pending authorisation. You will be able to link them to your loyalty card once they've been approved.
  internal static let pllScreenPendingCardsDetail = L10n.tr("Localizable", "pll_screen_pending_cards_detail", fallback: "The payment cards below are pending authorisation. You will be able to link them to your loyalty card once they've been approved.")
  /// Pending payment cards
  internal static let pllScreenPendingCardsTitle = L10n.tr("Localizable", "pll_screen_pending_cards_title", fallback: "Pending payment cards")
  /// Add them to link this card and others.
  internal static let pllScreenSecondaryMessage = L10n.tr("Localizable", "pll_screen_secondary_message", fallback: "Add them to link this card and others.")
  /// Link to your Payment Cards
  internal static let pllTitle = L10n.tr("Localizable", "pll_title", fallback: "Link to your Payment Cards")
  /// %@%@%@ left to go!
  internal static func plrAccumulatorVoucherHeadline(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
    return L10n.tr("Localizable", "plr_accumulator_voucher_headline", String(describing: p1), String(describing: p2), String(describing: p3), fallback: "%@%@%@ left to go!")
  }
  /// Your past rewards
  internal static let plrHistorySubtitle = L10n.tr("Localizable", "plr_history_subtitle", fallback: "Your past rewards")
  /// Rewards history
  internal static let plrHistoryTitle = L10n.tr("Localizable", "plr_history_title", fallback: "Rewards history")
  /// Earned
  internal static let plrIssuedHeadline = L10n.tr("Localizable", "plr_issued_headline", fallback: "Earned")
  /// Earning
  internal static let plrLcdPointsModuleAuthTitle = L10n.tr("Localizable", "plr_lcd_points_module_auth_title", fallback: "Earning")
  /// Towards rewards
  internal static let plrLcdPointsModuleDescription = L10n.tr("Localizable", "plr_lcd_points_module_description", fallback: "Towards rewards")
  /// Collecting
  internal static let plrLcdPointsModuleTitle = L10n.tr("Localizable", "plr_lcd_points_module_title", fallback: "Collecting")
  /// spent
  internal static let plrLoyaltyCardSubtitleAccumulator = L10n.tr("Localizable", "plr_loyalty_card_subtitle_accumulator", fallback: "spent")
  /// earned
  internal static let plrLoyaltyCardSubtitleStamps = L10n.tr("Localizable", "plr_loyalty_card_subtitle_stamps", fallback: "earned")
  /// You currently don’t have any linked payment cards.
  /// You can only earn rewards by shopping with a linked payment card.
  /// Please add a card so you can start earning rewards.
  internal static let plrPaymentCardNeededBody = L10n.tr("Localizable", "plr_payment_card_needed_body", fallback: "You currently don’t have any linked payment cards.\nYou can only earn rewards by shopping with a linked payment card.\nPlease add a card so you can start earning rewards.")
  /// Payment card needed
  internal static let plrPaymentCardNeededTitle = L10n.tr("Localizable", "plr_payment_card_needed_title", fallback: "Payment card needed")
  /// Your voucher has been cancelled
  internal static let plrStampVoucherDetailCancelledHeader = L10n.tr("Localizable", "plr_stamp_voucher_detail_cancelled_header", fallback: "Your voucher has been cancelled")
  /// Your voucher has expired
  internal static let plrStampVoucherDetailExpiredHeader = L10n.tr("Localizable", "plr_stamp_voucher_detail_expired_header", fallback: "Your voucher has expired")
  /// About this voucher
  internal static let plrStampVoucherDetailInprogressHeader = L10n.tr("Localizable", "plr_stamp_voucher_detail_inprogress_header", fallback: "About this voucher")
  /// Your voucher was redeemed
  internal static let plrStampVoucherDetailRedeemedHeader = L10n.tr("Localizable", "plr_stamp_voucher_detail_redeemed_header", fallback: "Your voucher was redeemed")
  /// %@%@ stamp to go!
  internal static func plrStampVoucherHeadline(_ p1: Any, _ p2: Any) -> String {
    return L10n.tr("Localizable", "plr_stamp_voucher_headline", String(describing: p1), String(describing: p2), fallback: "%@%@ stamp to go!")
  }
  /// %@%@ stamps to go!
  internal static func plrStampVoucherHeadlinePlural(_ p1: Any, _ p2: Any) -> String {
    return L10n.tr("Localizable", "plr_stamp_voucher_headline_plural", String(describing: p1), String(describing: p2), fallback: "%@%@ stamps to go!")
  }
  /// for spending %@%@
  internal static func plrVoucherAccumulatorBurnDescription(_ p1: Any, _ p2: Any) -> String {
    return L10n.tr("Localizable", "plr_voucher_accumulator_burn_description", String(describing: p1), String(describing: p2), fallback: "for spending %@%@")
  }
  /// Spent:
  internal static let plrVoucherAccumulatorEarnValueTitle = L10n.tr("Localizable", "plr_voucher_accumulator_earn_value_title", fallback: "Spent:")
  /// on 
  internal static let plrVoucherDatePrefix = L10n.tr("Localizable", "plr_voucher_date_prefix", fallback: "on ")
  /// Expired 
  internal static let plrVoucherDetailExpiredDatePrefix = L10n.tr("Localizable", "plr_voucher_detail_expired_date_prefix", fallback: "Expired ")
  /// Your %@ has expired
  internal static func plrVoucherDetailExpiredHeader(_ p1: Any) -> String {
    return L10n.tr("Localizable", "plr_voucher_detail_expired_header", String(describing: p1), fallback: "Your %@ has expired")
  }
  /// Expires 
  internal static let plrVoucherDetailExpiresDatePrefix = L10n.tr("Localizable", "plr_voucher_detail_expires_date_prefix", fallback: "Expires ")
  /// Added 
  internal static let plrVoucherDetailIssuedDatePrefix = L10n.tr("Localizable", "plr_voucher_detail_issued_date_prefix", fallback: "Added ")
  /// Your %@ is ready!
  internal static func plrVoucherDetailIssuedHeader(_ p1: Any) -> String {
    return L10n.tr("Localizable", "plr_voucher_detail_issued_header", String(describing: p1), fallback: "Your %@ is ready!")
  }
  /// Privacy Policy
  internal static let plrVoucherDetailPrivacyButtonTitle = L10n.tr("Localizable", "plr_voucher_detail_privacy_button_title", fallback: "Privacy Policy")
  /// Redeemed 
  internal static let plrVoucherDetailRedeemedDatePrefix = L10n.tr("Localizable", "plr_voucher_detail_redeemed_date_prefix", fallback: "Redeemed ")
  /// Your %@ was redeemed
  internal static func plrVoucherDetailRedeemedHeader(_ p1: Any) -> String {
    return L10n.tr("Localizable", "plr_voucher_detail_redeemed_header", String(describing: p1), fallback: "Your %@ was redeemed")
  }
  /// Spend %@%@ with us and you'll get a %@%@ %@.
  internal static func plrVoucherDetailSubtextInprogress(_ p1: Any, _ p2: Any, _ p3: Any, _ p4: Any, _ p5: Any) -> String {
    return L10n.tr("Localizable", "plr_voucher_detail_subtext_inprogress", String(describing: p1), String(describing: p2), String(describing: p3), String(describing: p4), String(describing: p5), fallback: "Spend %@%@ with us and you'll get a %@%@ %@.")
  }
  /// Use the code above to redeem your reward. You will get a %@%@ %@ off your purchase.
  internal static func plrVoucherDetailSubtextIssued(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
    return L10n.tr("Localizable", "plr_voucher_detail_subtext_issued", String(describing: p1), String(describing: p2), String(describing: p3), fallback: "Use the code above to redeem your reward. You will get a %@%@ %@ off your purchase.")
  }
  /// Terms & Conditions
  internal static let plrVoucherDetailTandcButtonTitle = L10n.tr("Localizable", "plr_voucher_detail_tandc_button_title", fallback: "Terms & Conditions")
  /// Goal:
  internal static let plrVoucherEarnTargetValueTitle = L10n.tr("Localizable", "plr_voucher_earn_target_value_title", fallback: "Goal:")
  /// for collecting %@%@ %@
  internal static func plrVoucherStampBurnDescription(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
    return L10n.tr("Localizable", "plr_voucher_stamp_burn_description", String(describing: p1), String(describing: p2), String(describing: p3), fallback: "for collecting %@%@ %@")
  }
  /// Collected:
  internal static let plrVoucherStampEarnValueTitle = L10n.tr("Localizable", "plr_voucher_stamp_earn_value_title", fallback: "Collected:")
  /// You can log in to your %@ account to see your points balance and transaction history. This is optional.
  internal static func pointsAndTransactionsLogInDescription(_ p1: Any) -> String {
    return L10n.tr("Localizable", "points_and_transactions_log_in_description", String(describing: p1), fallback: "You can log in to your %@ account to see your points balance and transaction history. This is optional.")
  }
  /// Account exists
  internal static let pointsModuleAccountExistsStatus = L10n.tr("Localizable", "points_module_account_exists_status", fallback: "Account exists")
  /// Last checked
  internal static let pointsModuleLastChecked = L10n.tr("Localizable", "points_module_last_checked", fallback: "Last checked")
  /// Log in
  internal static let pointsModuleLogIn = L10n.tr("Localizable", "points_module_log_in", fallback: "Log in")
  /// Logging in
  internal static let pointsModuleLoggingInStatus = L10n.tr("Localizable", "points_module_logging_in_status", fallback: "Logging in")
  /// Registering card
  internal static let pointsModuleRegisteringCardStatus = L10n.tr("Localizable", "points_module_registering_card_status", fallback: "Registering card")
  /// Retry login
  internal static let pointsModuleRetryLogInStatus = L10n.tr("Localizable", "points_module_retry_log_in_status", fallback: "Retry login")
  /// Signing up
  internal static let pointsModuleSigningUpStatus = L10n.tr("Localizable", "points_module_signing_up_status", fallback: "Signing up")
  /// To see history
  internal static let pointsModuleToSeeHistory = L10n.tr("Localizable", "points_module_to_see_history", fallback: "To see history")
  /// View history
  internal static let pointsModuleViewHistoryMessage = L10n.tr("Localizable", "points_module_view_history_message", fallback: "View history")
  /// Popular
  internal static let popularTitle = L10n.tr("Localizable", "popular_title", fallback: "Popular")
  /// Privacy Policy
  internal static let ppolicyLink = L10n.tr("Localizable", "ppolicy_link", fallback: "Privacy Policy")
  /// I accept Bink's Privacy Policy
  internal static let ppolicyTitle = L10n.tr("Localizable", "ppolicy_title", fallback: "I accept Bink's Privacy Policy")
  /// Would you like to also remove stored credentials from this device?
  internal static let preferencesClearCredentialsBody = L10n.tr("Localizable", "preferences_clear_credentials_body", fallback: "Would you like to also remove stored credentials from this device?")
  /// There was a problem deleting your credentials, please try again
  internal static let preferencesClearCredentialsError = L10n.tr("Localizable", "preferences_clear_credentials_error", fallback: "There was a problem deleting your credentials, please try again")
  /// Your stored credentials have been deleted
  internal static let preferencesClearCredentialsSuccessBody = L10n.tr("Localizable", "preferences_clear_credentials_success_body", fallback: "Your stored credentials have been deleted")
  /// Success
  internal static let preferencesClearCredentialsSuccessTitle = L10n.tr("Localizable", "preferences_clear_credentials_success_title", fallback: "Success")
  /// Clear Stored Credentials
  internal static let preferencesClearCredentialsTitle = L10n.tr("Localizable", "preferences_clear_credentials_title", fallback: "Clear Stored Credentials")
  /// Receive marketing messages
  internal static let preferencesMarketingCheckbox = L10n.tr("Localizable", "preferences_marketing_checkbox", fallback: "Receive marketing messages")
  /// Make sure you’re the first to know about available rewards, offers and updates!
  /// You can opt out at any time.
  internal static let preferencesPrompt = L10n.tr("Localizable", "preferences_prompt", fallback: "Make sure you’re the first to know about available rewards, offers and updates!\nYou can opt out at any time.")
  /// offers
  internal static let preferencesPromptHighlightOffers = L10n.tr("Localizable", "preferences_prompt_highlight_offers", fallback: "offers")
  /// rewards
  internal static let preferencesPromptHighlightRewards = L10n.tr("Localizable", "preferences_prompt_highlight_rewards", fallback: "rewards")
  /// updates!
  internal static let preferencesPromptHighlightUpdates = L10n.tr("Localizable", "preferences_prompt_highlight_updates", fallback: "updates!")
  /// Cannot retrieve your preferences at the moment. Please try again later.
  internal static let preferencesRetrieveFail = L10n.tr("Localizable", "preferences_retrieve_fail", fallback: "Cannot retrieve your preferences at the moment. Please try again later.")
  /// Make sure you’re the first to know about available rewards, offers and updates!
  internal static let preferencesScreenDescription = L10n.tr("Localizable", "preferences_screen_description", fallback: "Make sure you’re the first to know about available rewards, offers and updates!")
  /// We can't update your preferences at the moment. Please try again later.
  internal static let preferencesUpdateFail = L10n.tr("Localizable", "preferences_update_fail", fallback: "We can't update your preferences at the moment. Please try again later.")
  /// Preferences Updated
  internal static let preferencesUpdated = L10n.tr("Localizable", "preferences_updated", fallback: "Preferences Updated")
  /// Press for directions
  internal static let pressForDirections = L10n.tr("Localizable", "press_for_directions", fallback: "Press for directions")
  /// Privacy Policy
  internal static let privacyPolicy = L10n.tr("Localizable", "privacy_policy", fallback: "Privacy Policy")
  /// Your recent transaction history
  internal static let recentTransactionHistorySubtitle = L10n.tr("Localizable", "recent_transaction_history_subtitle", fallback: "Your recent transaction history")
  /// Open App Store
  internal static let recommendedAppUpdateAppStoreAction = L10n.tr("Localizable", "recommended_app_update_app_store_action", fallback: "Open App Store")
  /// Maybe later
  internal static let recommendedAppUpdateMaybeLaterAction = L10n.tr("Localizable", "recommended_app_update_maybe_later_action", fallback: "Maybe later")
  /// Get the latest version of the Bink app.
  internal static let recommendedAppUpdateMessage = L10n.tr("Localizable", "recommended_app_update_message", fallback: "Get the latest version of the Bink app.")
  /// Skip this version
  internal static let recommendedAppUpdateSkipVersionAction = L10n.tr("Localizable", "recommended_app_update_skip_version_action", fallback: "Skip this version")
  /// App Update Available
  internal static let recommendedAppUpdateTitle = L10n.tr("Localizable", "recommended_app_update_title", fallback: "App Update Available")
  /// Register card
  internal static let registerCardTitle = L10n.tr("Localizable", "register_card_title", fallback: "Register card")
  /// Registration failed.
  internal static let registerFailed = L10n.tr("Localizable", "register_failed", fallback: "Registration failed.")
  /// Register
  internal static let registerGcTitle = L10n.tr("Localizable", "register_gc_title", fallback: "Register")
  /// Fill out the form below to get a new %@ and start collecting rewards
  internal static func registerGhostCardDescription(_ p1: Any) -> String {
    return L10n.tr("Localizable", "register_ghost_card_description", String(describing: p1), fallback: "Fill out the form below to get a new %@ and start collecting rewards")
  }
  /// Register your card
  internal static let registerGhostCardTitle = L10n.tr("Localizable", "register_ghost_card_title", fallback: "Register your card")
  /// Sometimes it takes a while to register with your merchant.
  /// In the meantime please do not attempt to register your card again. You can use your card and receive your benefits as normal.
  /// After registration has been completed you will be able to see your points balance.
  internal static let registerPendingDescription = L10n.tr("Localizable", "register_pending_description", fallback: "Sometimes it takes a while to register with your merchant.\nIn the meantime please do not attempt to register your card again. You can use your card and receive your benefits as normal.\nAfter registration has been completed you will be able to see your points balance.")
  /// Register Ghost card pending
  internal static let registerPendingTitle = L10n.tr("Localizable", "register_pending_title", fallback: "Register Ghost card pending")
  /// All it takes is an email and password.
  internal static let registerSubtitle = L10n.tr("Localizable", "register_subtitle", fallback: "All it takes is an email and password.")
  /// Sign up with email
  internal static let registerTitle = L10n.tr("Localizable", "register_title", fallback: "Sign up with email")
  /// Registration failed
  internal static let registrationFailedTitle = L10n.tr("Localizable", "registration_failed_title", fallback: "Registration failed")
  /// Please go to the merchant’s website to join this scheme. You can then come back and add your card.
  internal static let registrationUnavailableDescription = L10n.tr("Localizable", "registration_unavailable_description", fallback: "Please go to the merchant’s website to join this scheme. You can then come back and add your card.")
  /// Registration unavailable
  internal static let registrationUnavailableTitle = L10n.tr("Localizable", "registration_unavailable_title", fallback: "Registration unavailable")
  /// Retry
  internal static let retryTitle = L10n.tr("Localizable", "retry_title", fallback: "Retry")
  /// Scan a card you already have
  internal static let scanACardDescription = L10n.tr("Localizable", "scan_a_card_description", fallback: "Scan a card you already have")
  /// Scan and link your payment card
  internal static let scanAndLinkDescription = L10n.tr("Localizable", "scan_and_link_description", fallback: "Scan and link your payment card")
  /// Quickly add a card you already have
  internal static let scanButtonSubtitle = L10n.tr("Localizable", "scan_button_subtitle", fallback: "Quickly add a card you already have")
  /// Scan loyalty card
  internal static let scanButtonTitle = L10n.tr("Localizable", "scan_button_title", fallback: "Scan loyalty card")
  /// Search
  internal static let search = L10n.tr("Localizable", "search", fallback: "Search")
  /// Is my Data Secure?
  internal static let securityAndPrivacyAlertTitle = L10n.tr("Localizable", "security_and_privacy_alert_title", fallback: "Is my Data Secure?")
  /// Bink takes the security of your information extremely seriously and uses a range of best in class methods to protect your information.
  /// 
  /// Bink is a registered PCI Level 1 Service Provider for the protection of sensitive first party data and personally identifiable information.
  internal static let securityAndPrivacyDescription = L10n.tr("Localizable", "security_and_privacy_description", fallback: "Bink takes the security of your information extremely seriously and uses a range of best in class methods to protect your information.\n\nBink is a registered PCI Level 1 Service Provider for the protection of sensitive first party data and personally identifiable information.")
  /// How we protect your data
  internal static let securityAndPrivacyMessage = L10n.tr("Localizable", "security_and_privacy_message", fallback: "How we protect your data")
  /// Security and privacy
  internal static let securityAndPrivacyTitle = L10n.tr("Localizable", "security_and_privacy_title", fallback: "Security and privacy")
  /// Add these loyalty cards to see your points and rewards in real time in the Bink app.
  internal static let seeDescription = L10n.tr("Localizable", "see_description", fallback: "Add these loyalty cards to see your points and rewards in real time in the Bink app.")
  /// See your balance
  internal static let seeTitle = L10n.tr("Localizable", "see_title", fallback: "See your balance")
  /// Account deletion is irreversible, are you sure you want to delete your account?
  internal static let settingsDeleteAccountActionSubtitle = L10n.tr("Localizable", "settings_delete_account_action_subtitle", fallback: "Account deletion is irreversible, are you sure you want to delete your account?")
  /// Delete Account
  internal static let settingsDeleteAccountActionTitle = L10n.tr("Localizable", "settings_delete_account_action_title", fallback: "Delete Account")
  /// Account deletion failed, please contact us
  internal static let settingsDeleteAccountFailedAlertMessage = L10n.tr("Localizable", "settings_delete_account_failed_alert_message", fallback: "Account deletion failed, please contact us")
  /// Account deletion is successful
  internal static let settingsDeleteAccountSuccessAlertMessage = L10n.tr("Localizable", "settings_delete_account_success_alert_message", fallback: "Account deletion is successful")
  /// Previous Updates
  internal static let settingsPreviousUpdates = L10n.tr("Localizable", "settings_previous_updates", fallback: "Previous Updates")
  /// Release Notes
  internal static let settingsPreviousUpdatesSubtitle = L10n.tr("Localizable", "settings_previous_updates_subtitle", fallback: "Release Notes")
  /// Get in touch with Bink
  internal static let settingsRowContactSubtitle = L10n.tr("Localizable", "settings_row_contact_subtitle", fallback: "Get in touch with Bink")
  /// Contact us
  internal static let settingsRowContactTitle = L10n.tr("Localizable", "settings_row_contact_title", fallback: "Contact us")
  /// Delete my account
  internal static let settingsRowDeleteAccountTitle = L10n.tr("Localizable", "settings_row_delete_account_title", fallback: "Delete my account")
  /// Frequently asked questions
  internal static let settingsRowFaqsSubtitle = L10n.tr("Localizable", "settings_row_faqs_subtitle", fallback: "Frequently asked questions")
  /// FAQs
  internal static let settingsRowFaqsTitle = L10n.tr("Localizable", "settings_row_faqs_title", fallback: "FAQs")
  /// Feature flags
  internal static let settingsRowFeatureflagsTitle = L10n.tr("Localizable", "settings_row_featureflags_title", fallback: "Feature flags")
  /// Find out more about Bink
  internal static let settingsRowHowitworksSubtitle = L10n.tr("Localizable", "settings_row_howitworks_subtitle", fallback: "Find out more about Bink")
  /// How it works
  internal static let settingsRowHowitworksTitle = L10n.tr("Localizable", "settings_row_howitworks_title", fallback: "How it works")
  /// Log out
  internal static let settingsRowLogoutTitle = L10n.tr("Localizable", "settings_row_logout_title", fallback: "Log out")
  /// Preferences
  internal static let settingsRowPreferencesTitle = L10n.tr("Localizable", "settings_row_preferences_title", fallback: "Preferences")
  /// Privacy policy
  internal static let settingsRowPrivacypolicyTitle = L10n.tr("Localizable", "settings_row_privacypolicy_title", fallback: "Privacy policy")
  /// Rate this app
  internal static let settingsRowRateappTitle = L10n.tr("Localizable", "settings_row_rateapp_title", fallback: "Rate this app")
  /// How we protect your data
  internal static let settingsRowSecuritySubtitle = L10n.tr("Localizable", "settings_row_security_subtitle", fallback: "How we protect your data")
  /// Security and privacy
  internal static let settingsRowSecurityTitle = L10n.tr("Localizable", "settings_row_security_title", fallback: "Security and privacy")
  /// Terms and conditions
  internal static let settingsRowTermsandconditionsTitle = L10n.tr("Localizable", "settings_row_termsandconditions_title", fallback: "Terms and conditions")
  /// Theme
  internal static let settingsRowThemeTitle = L10n.tr("Localizable", "settings_row_theme_title", fallback: "Theme")
  /// About
  internal static let settingsSectionAboutTitle = L10n.tr("Localizable", "settings_section_about_title", fallback: "About")
  /// Account
  internal static let settingsSectionAccountTitle = L10n.tr("Localizable", "settings_section_account_title", fallback: "Account")
  /// Appearance
  internal static let settingsSectionAppearanceTitle = L10n.tr("Localizable", "settings_section_appearance_title", fallback: "Appearance")
  /// Beta
  internal static let settingsSectionBetaTitle = L10n.tr("Localizable", "settings_section_beta_title", fallback: "Beta")
  /// Only accessible on debug builds
  internal static let settingsSectionDebugSubtitle = L10n.tr("Localizable", "settings_section_debug_subtitle", fallback: "Only accessible on debug builds")
  /// Debug
  internal static let settingsSectionDebugTitle = L10n.tr("Localizable", "settings_section_debug_title", fallback: "Debug")
  /// Legal
  internal static let settingsSectionLegalTitle = L10n.tr("Localizable", "settings_section_legal_title", fallback: "Legal")
  /// Support and feedback
  internal static let settingsSectionSupportTitle = L10n.tr("Localizable", "settings_section_support_title", fallback: "Support and feedback")
  /// Cancel
  internal static let settingsThemeCancelTitle = L10n.tr("Localizable", "settings_theme_cancel_title", fallback: "Cancel")
  /// Dark
  internal static let settingsThemeDarkTitle = L10n.tr("Localizable", "settings_theme_dark_title", fallback: "Dark")
  /// Light
  internal static let settingsThemeLightTitle = L10n.tr("Localizable", "settings_theme_light_title", fallback: "Light")
  /// System
  internal static let settingsThemeSystemTitle = L10n.tr("Localizable", "settings_theme_system_title", fallback: "System")
  /// Settings
  internal static let settingsTitle = L10n.tr("Localizable", "settings_title", fallback: "Settings")
  /// Who we are
  internal static let settingsWhoWeAreTitle = L10n.tr("Localizable", "settings_who_we_are_title", fallback: "Who we are")
  /// For some brands, we do not automatically display a barcode
  /// if you add your loyalty card manually (without scanning). This
  /// is because we cannot guarantee it will work in store.
  /// 
  /// **Press here** to show barcode anyway
  internal static let showBarcodeBody = L10n.tr("Localizable", "show_barcode_body", fallback: "For some brands, we do not automatically display a barcode\nif you add your loyalty card manually (without scanning). This\nis because we cannot guarantee it will work in store.\n\n**Press here** to show barcode anyway")
  /// Showing Barcode
  internal static let showBarcodeTitle = L10n.tr("Localizable", "show_barcode_title", fallback: "Showing Barcode")
  /// Show Locations
  internal static let showLocations = L10n.tr("Localizable", "show_locations", fallback: "Show Locations")
  /// Sign up
  internal static let signUpButtonTitle = L10n.tr("Localizable", "sign_up_button_title", fallback: "Sign up")
  /// Sign up failed
  internal static let signUpFailedTitle = L10n.tr("Localizable", "sign_up_failed_title", fallback: "Sign up failed")
  /// Fill out the form below to get a new %@ and start collecting rewards
  internal static func signUpNewCardDescription(_ p1: Any) -> String {
    return L10n.tr("Localizable", "sign_up_new_card_description", String(describing: p1), fallback: "Fill out the form below to get a new %@ and start collecting rewards")
  }
  /// Sign up for %@
  internal static func signUpNewCardTitle(_ p1: Any) -> String {
    return L10n.tr("Localizable", "sign_up_new_card_title", String(describing: p1), fallback: "Sign up for %@")
  }
  /// Sometimes it takes a while to sign up with your merchant.
  /// In the meantime please do not attempt to sign up again. You can use your card and receive your benefits as normal.
  /// After the sign up has been completed you will be able to see your points balance.
  internal static let signUpPendingDescription = L10n.tr("Localizable", "sign_up_pending_description", fallback: "Sometimes it takes a while to sign up with your merchant.\nIn the meantime please do not attempt to sign up again. You can use your card and receive your benefits as normal.\nAfter the sign up has been completed you will be able to see your points balance.")
  /// Sign up pending
  internal static let signUpPendingTitle = L10n.tr("Localizable", "sign_up_pending_title", fallback: "Sign up pending")
  /// Copied card number
  internal static let snackbarMessageCopiedCardNumber = L10n.tr("Localizable", "snackbar_message_copied_card_number", fallback: "Copied card number")
  /// Sign in with Apple failed.
  internal static let socialTandcsSiwaError = L10n.tr("Localizable", "social_tandcs_siwa_error", fallback: "Sign in with Apple failed.")
  /// One last step...
  internal static let socialTandcsSubtitle = L10n.tr("Localizable", "social_tandcs_subtitle", fallback: "One last step...")
  /// Terms and conditions
  internal static let socialTandcsTitle = L10n.tr("Localizable", "social_tandcs_title", fallback: "Terms and conditions")
  /// There was a problem authenticating you. Please try again.
  internal static let somethingWentWrongDescription = L10n.tr("Localizable", "something_went_wrong_description", fallback: "There was a problem authenticating you. Please try again.")
  /// Something went wrong
  internal static let somethingWentWrongTitle = L10n.tr("Localizable", "something_went_wrong_title", fallback: "Something went wrong")
  /// Sort Order
  internal static let sortOrder = L10n.tr("Localizable", "sort_order", fallback: "Sort Order")
  /// Connection error. Please try again.
  internal static let sslPinningFailureText = L10n.tr("Localizable", "ssl_pinning_failure_text", fallback: "Connection error. Please try again.")
  /// Error
  internal static let sslPinningFailureTitle = L10n.tr("Localizable", "ssl_pinning_failure_title", fallback: "Error")
  /// Add these loyalty cards to store your barcode in Bink and always have it on your phone. No more plastic!
  internal static let storeDescription = L10n.tr("Localizable", "store_description", fallback: "Add these loyalty cards to store your barcode in Bink and always have it on your phone. No more plastic!")
  /// Store your barcode
  internal static let storeTitle = L10n.tr("Localizable", "store_title", fallback: "Store your barcode")
  /// %@ build %@
  internal static func supportMailAppVersion(_ p1: Any, _ p2: Any) -> String {
    return L10n.tr("Localizable", "support_mail_app_version", String(describing: p1), String(describing: p2), fallback: "%@ build %@")
  }
  /// 
  /// 
  /// 
  /// 
  /// The below information will help us with with your query, please don’t change it.
  /// Bink ID: %@
  /// Version: %@
  /// iOS Version: %@
  internal static func supportMailBody(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
    return L10n.tr("Localizable", "support_mail_body", String(describing: p1), String(describing: p2), String(describing: p3), fallback: "\n\n\n\nThe below information will help us with with your query, please don’t change it.\nBink ID: %@\nVersion: %@\niOS Version: %@")
  }
  /// No Mail accounts set up, please email us directly: support@bink.com
  internal static let supportMailNoEmailAppsBody = L10n.tr("Localizable", "support_mail_no_email_apps_body", fallback: "No Mail accounts set up, please email us directly: support@bink.com")
  /// No email app installed
  internal static let supportMailNoEmailAppsTitle = L10n.tr("Localizable", "support_mail_no_email_apps_title", fallback: "No email app installed")
  /// Bink App Support
  internal static let supportMailSubject = L10n.tr("Localizable", "support_mail_subject", fallback: "Bink App Support")
  /// Please read the Bink Privacy Policy for further details of how your data will be processed
  internal static let tandcsDescription = L10n.tr("Localizable", "tandcs_description", fallback: "Please read the Bink Privacy Policy for further details of how your data will be processed")
  /// Terms and Conditions
  internal static let tandcsLink = L10n.tr("Localizable", "tandcs_link", fallback: "Terms and Conditions")
  /// I agree to Bink's Terms and Conditions
  internal static let tandcsTitle = L10n.tr("Localizable", "tandcs_title", fallback: "I agree to Bink's Terms and Conditions")
  /// I authorise Mastercard, Visa and American Express to monitor activity on my payment card to determine when I have made a qualifying transaction, and for Mastercard, Visa and American Express to share such transaction details with Bink to enable my card-linked offer(s) and target offers that may be of interest to me. 
  /// 
  /// For information about Bink’s privacy practices please see Bink’s Privacy Policy. You may opt-out of transaction monitoring on the payment card(s) you entered at any time by deleting your payment card from your Bink wallet.
  internal static let termsAndConditionsDescription = L10n.tr("Localizable", "terms_and_conditions_description", fallback: "I authorise Mastercard, Visa and American Express to monitor activity on my payment card to determine when I have made a qualifying transaction, and for Mastercard, Visa and American Express to share such transaction details with Bink to enable my card-linked offer(s) and target offers that may be of interest to me. \n\nFor information about Bink’s privacy practices please see Bink’s Privacy Policy. You may opt-out of transaction monitoring on the payment card(s) you entered at any time by deleting your payment card from your Bink wallet.")
  /// Terms and conditions
  internal static let termsAndConditionsTitle = L10n.tr("Localizable", "terms_and_conditions_title", fallback: "Terms and conditions")
  /// To be implemented
  internal static let toBeImplementedMessage = L10n.tr("Localizable", "to_be_implemented_message", fallback: "To be implemented")
  /// Go to merchant site
  internal static let toMerchantSiteButton = L10n.tr("Localizable", "to_merchant_site_button", fallback: "Go to merchant site")
  /// %@ does not support displaying your transaction history in the Bink app.
  /// 
  /// You can view your history and balance on the merchant’s website.
  internal static func transactionHistoryNotSupportedDescription(_ p1: Any) -> String {
    return L10n.tr("Localizable", "transaction_history_not_supported_description", String(describing: p1), fallback: "%@ does not support displaying your transaction history in the Bink app.\n\nYou can view your history and balance on the merchant’s website.")
  }
  /// Transaction history not supported
  internal static let transactionHistoryNotSupportedTitle = L10n.tr("Localizable", "transaction_history_not_supported_title", fallback: "Transaction history not supported")
  /// Transaction history
  internal static let transactionHistoryTitle = L10n.tr("Localizable", "transaction_history_title", fallback: "Transaction history")
  /// No transactions to display since adding your card to Bink
  /// In some cases transactions take longer to update
  internal static let transactionHistoryUnavailableDescription = L10n.tr("Localizable", "transaction_history_unavailable_description", fallback: "No transactions to display since adding your card to Bink\nIn some cases transactions take longer to update")
  /// Transaction history
  internal static let transactionHistoryUnavailableTitle = L10n.tr("Localizable", "transaction_history_unavailable_title", fallback: "Transaction history")
  /// Please open the Bink app on your phone to login to your wallet
  internal static let unauthenticatedStateDescription = L10n.tr("Localizable", "unauthenticated_state_description", fallback: "Please open the Bink app on your phone to login to your wallet")
  /// You are not logged in
  internal static let unauthenticatedStateTitle = L10n.tr("Localizable", "unauthenticated_state_title", fallback: "You are not logged in")
  /// Payment Linked Loyalty (PLL) allows customers’ payment cards to be securely linked to loyalty programmes, enabling every customer to be identified and rewarded every time they shop.
  /// This is currently not available for this merchant.
  internal static let unlinkablePllDescription = L10n.tr("Localizable", "unlinkable_pll_description", fallback: "Payment Linked Loyalty (PLL) allows customers’ payment cards to be securely linked to loyalty programmes, enabling every customer to be identified and rewarded every time they shop.\nThis is currently not available for this merchant.")
  /// Payment Linked Loyalty unavailable
  internal static let unlinkablePllTitle = L10n.tr("Localizable", "unlinkable_pll_title", fallback: "Payment Linked Loyalty unavailable")
  /// unlinked
  internal static let unlinkedStatusImageName = L10n.tr("Localizable", "unlinked_status_image_name", fallback: "unlinked")
  /// Add these loyalty cards and link them to your payment cards to collect rewards automatically when you pay.
  internal static let walletPromptLinkBody = L10n.tr("Localizable", "wallet_prompt_link_body", fallback: "Add these loyalty cards and link them to your payment cards to collect rewards automatically when you pay.")
  /// Link to your payment cards
  internal static let walletPromptLinkTitle = L10n.tr("Localizable", "wallet_prompt_link_title", fallback: "Link to your payment cards")
  /// More coming soon!
  internal static let walletPromptMoreComingSoon = L10n.tr("Localizable", "wallet_prompt_more_coming_soon", fallback: "More coming soon!")
  /// Collect rewards automatically for select loyalty cards by linking them to your payment cards.
  internal static let walletPromptPayment = L10n.tr("Localizable", "wallet_prompt_payment", fallback: "Collect rewards automatically for select loyalty cards by linking them to your payment cards.")
  /// Add these loyalty cards to see your points and rewards balances in real time.
  internal static let walletPromptSeeBody = L10n.tr("Localizable", "wallet_prompt_see_body", fallback: "Add these loyalty cards to see your points and rewards balances in real time.")
  /// See your points balances
  internal static let walletPromptSeeTitle = L10n.tr("Localizable", "wallet_prompt_see_title", fallback: "See your points balances")
  /// Add these loyalty cards to store their barcodes so you'll always have them on your phone when you need them.
  internal static let walletPromptStoreBody = L10n.tr("Localizable", "wallet_prompt_store_body", fallback: "Add these loyalty cards to store their barcodes so you'll always have them on your phone when you need them.")
  /// Store your barcodes
  internal static let walletPromptStoreTitle = L10n.tr("Localizable", "wallet_prompt_store_title", fallback: "Store your barcodes")
  /// Something went wrong.
  internal static let wentWrong = L10n.tr("Localizable", "went_wrong", fallback: "Something went wrong.")
  /// Magic Link
  internal static let whatIsMagicLinkHyperlink = L10n.tr("Localizable", "what_is_magic_link_hyperlink", fallback: "Magic Link")
  /// Below is a list of people that have been instrumental in developing the app you now hold in your hands.
  internal static let whoWeAreBody = L10n.tr("Localizable", "who_we_are_body", fallback: "Below is a list of people that have been instrumental in developing the app you now hold in your hands.")
  /// Who we are
  internal static let whoWeAreTitle = L10n.tr("Localizable", "who_we_are_title", fallback: "Who we are")
  /// Yes
  internal static let yes = L10n.tr("Localizable", "yes", fallback: "Yes")
  /// First name
  internal static let zendeskIdentityPromptFirstName = L10n.tr("Localizable", "zendesk_identity_prompt_first_name", fallback: "First name")
  /// Last name
  internal static let zendeskIdentityPromptLastName = L10n.tr("Localizable", "zendesk_identity_prompt_last_name", fallback: "Last name")
  /// Please enter your contact details
  internal static let zendeskIdentityPromptMessage = L10n.tr("Localizable", "zendesk_identity_prompt_message", fallback: "Please enter your contact details")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
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
