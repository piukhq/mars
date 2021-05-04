// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// About %@
  internal static func aboutCustomTitle(_ p1: Any) -> String {
    return L10n.tr("Localizable", "about_custom_title", String(describing: p1))
  }
  /// About %@
  internal static func aboutMembershipPlanTitle(_ p1: Any) -> String {
    return L10n.tr("Localizable", "about_membership_plan_title", String(describing: p1))
  }
  /// About membership
  internal static let aboutMembershipTitle = L10n.tr("Localizable", "about_membership_title")
  /// Accept
  internal static let accept = L10n.tr("Localizable", "accept")
  /// Confirm password
  internal static let accessFormConfirmPasswordPlaceholder = L10n.tr("Localizable", "access_form_confirm_password_placeholder")
  /// Confirm password
  internal static let accessFormConfirmPasswordTitle = L10n.tr("Localizable", "access_form_confirm_password_title")
  /// Passwords do not match
  internal static let accessFormConfirmPasswordValidation = L10n.tr("Localizable", "access_form_confirm_password_validation")
  /// Enter email address
  internal static let accessFormEmailPlaceholder = L10n.tr("Localizable", "access_form_email_placeholder")
  /// Email
  internal static let accessFormEmailTitle = L10n.tr("Localizable", "access_form_email_title")
  /// Incorrect email format
  internal static let accessFormEmailValidation = L10n.tr("Localizable", "access_form_email_validation")
  /// Enter password
  internal static let accessFormPasswordPlaceholder = L10n.tr("Localizable", "access_form_password_placeholder")
  /// Password
  internal static let accessFormPasswordTitle = L10n.tr("Localizable", "access_form_password_title")
  /// Password should be 8 or more characters, with at least 1 uppercase, 1 lowercase and a number
  internal static let accessFormPasswordValidation = L10n.tr("Localizable", "access_form_password_validation")
  /// Please add your email address below.
  internal static let addEmailSubtitle = L10n.tr("Localizable", "add_email_subtitle")
  /// Add email
  internal static let addEmailTitle = L10n.tr("Localizable", "add_email_title")
  /// You can link this card to your bank cards and automatically collect points when you pay.
  internal static let addJoinScreenLinkDescription = L10n.tr("Localizable", "add_join_screen_link_description")
  /// You cannot link this card to your payment cards yet.
  internal static let addJoinScreenLinkDescriptionInactive = L10n.tr("Localizable", "add_join_screen_link_description_inactive")
  /// Link
  internal static let addJoinScreenLinkTitle = L10n.tr("Localizable", "add_join_screen_link_title")
  /// You can add this card to Bink and show the onscreen barcode at the till to collect points.
  internal static let addJoinScreenStoreDescription = L10n.tr("Localizable", "add_join_screen_store_description")
  /// Store
  internal static let addJoinScreenStoreTitle = L10n.tr("Localizable", "add_join_screen_store_title")
  /// You can see your live points balance and transaction history for this card in Bink.
  internal static let addJoinScreenViewDescription = L10n.tr("Localizable", "add_join_screen_view_description")
  /// You cannot see your live points balance and transaction history for this card in Bink.
  internal static let addJoinScreenViewDescriptionInactive = L10n.tr("Localizable", "add_join_screen_view_description_inactive")
  /// View
  internal static let addJoinScreenViewTitle = L10n.tr("Localizable", "add_join_screen_view_title")
  /// Add loyalty card
  internal static let addLoyaltyCardTitle = L10n.tr("Localizable", "add_loyalty_card_title")
  /// Add my card
  internal static let addMyCardButton = L10n.tr("Localizable", "add_my_card_button")
  /// Add payment card
  internal static let addPaymentCardTitle = L10n.tr("Localizable", "add_payment_card_title")
  /// There was a problem adding your payment card. Please try again.
  internal static let addPaymentErrorMessage = L10n.tr("Localizable", "add_payment_error_message")
  /// Error Adding Card
  internal static let addPaymentErrorTitle = L10n.tr("Localizable", "add_payment_error_title")
  /// All
  internal static let allTitle = L10n.tr("Localizable", "all_title")
  /// Please enter your %@ credentials below to add this card to your wallet
  internal static func authScreenDescription(_ p1: Any) -> String {
    return L10n.tr("Localizable", "auth_screen_description", String(describing: p1))
  }
  /// Scan this barcode at the store, just like you would a physical loyalty card. Bear in mind that some store scanners cannot read from screens.
  internal static let barcodeCardDescription = L10n.tr("Localizable", "barcode_card_description")
  /// Show this card number in-store just like you would a physical loyalty card.
  internal static let barcodeCardNumberDescription = L10n.tr("Localizable", "barcode_card_number_description")
  /// Scan this barcode at the store, just like you would a physical coupon. Bear in mind that some store scanners cannot read from screens.
  internal static let barcodeCouponDescription = L10n.tr("Localizable", "barcode_coupon_description")
  /// This barcode cannot be displayed
  internal static let barcodeError = L10n.tr("Localizable", "barcode_error")
  /// Maximise barcode
  internal static let barcodeMaximiseButton = L10n.tr("Localizable", "barcode_maximise_button")
  /// Barcode
  internal static let barcodeSwipeTitle = L10n.tr("Localizable", "barcode_swipe_title")
  /// Barcode:
  internal static let barcodeTitle = L10n.tr("Localizable", "barcode_title")
  /// Card number:
  internal static let barcodeViewTitle = L10n.tr("Localizable", "barcode_view_title")
  /// Browse brands
  internal static let browseBrandsTitle = L10n.tr("Localizable", "browse_brands_title")
  /// Allow Access
  internal static let cameraDeniedAllowAccess = L10n.tr("Localizable", "camera_denied_allow_access")
  /// To scan your cards, you’ll need to allow Bink access to your device’s camera.
  internal static let cameraDeniedBody = L10n.tr("Localizable", "camera_denied_body")
  /// Enter Manually
  internal static let cameraDeniedManuallyOption = L10n.tr("Localizable", "camera_denied_manually_option")
  /// Please allow camera access
  internal static let cameraDeniedTitle = L10n.tr("Localizable", "camera_denied_title")
  /// OK
  internal static let cameraPermissionAllowOption = L10n.tr("Localizable", "camera_permission_allow_option")
  /// We need your camera to scan loyalty cards. It will not be used for other purposes.
  internal static let cameraPermissionBody = L10n.tr("Localizable", "camera_permission_body")
  /// Don't Allow
  internal static let cameraPermissionDenyOption = L10n.tr("Localizable", "camera_permission_deny_option")
  /// Bink needs camera access
  internal static let cameraPermissionTitle = L10n.tr("Localizable", "camera_permission_title")
  /// Can be linked to your payment cards
  internal static let canBeLinkedDescription = L10n.tr("Localizable", "can_be_linked_description")
  /// Cancel
  internal static let cancel = L10n.tr("Localizable", "cancel")
  /// %@ already linked to a different %@. Please unlink the other %@ before proceeding, but be aware this may only be possible from another application.
  internal static func cardAlreadyLinkedMessage(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
    return L10n.tr("Localizable", "card_already_linked_message", String(describing: p1), String(describing: p2), String(describing: p3))
  }
  /// This payment card is
  internal static let cardAlreadyLinkedMessagePrefix = L10n.tr("Localizable", "card_already_linked_message_prefix")
  /// Already Linked
  internal static let cardAlreadyLinkedTitle = L10n.tr("Localizable", "card_already_linked_title")
  /// Cannot Link
  internal static let cardCanNotLinkStatus = L10n.tr("Localizable", "card_can_not_link_status")
  /// Link now
  internal static let cardLinkNowStatus = L10n.tr("Localizable", "card_link_now_status")
  /// Link
  internal static let cardLinkStatus = L10n.tr("Localizable", "card_link_status")
  /// Linked
  internal static let cardLinkedStatus = L10n.tr("Localizable", "card_linked_status")
  /// Linking
  internal static let cardLinkingStatus = L10n.tr("Localizable", "card_linking_status")
  /// Card number:
  internal static let cardNumberTitle = L10n.tr("Localizable", "card_number_title")
  /// One of these payment cards are
  internal static let cardsAlreadyLinkedMessagePrefix = L10n.tr("Localizable", "cards_already_linked_message_prefix")
  /// There was a problem communicating with the server. Please try again later.
  internal static let communicationError = L10n.tr("Localizable", "communication_error")
  /// Continue
  internal static let continueButtonTitle = L10n.tr("Localizable", "continue_button_title")
  /// Enter credentials
  internal static let credentialsTitle = L10n.tr("Localizable", "credentials_title")
  /// day
  internal static let day = L10n.tr("Localizable", "day")
  /// days
  internal static let days = L10n.tr("Localizable", "days")
  /// Tools
  internal static let debugMenuToolsSectionTitle = L10n.tr("Localizable", "debug_menu_tools_section_title")
  /// Decline
  internal static let decline = L10n.tr("Localizable", "decline")
  /// Are you sure you want to delete this card?
  internal static let deleteCardConfirmation = L10n.tr("Localizable", "delete_card_confirmation")
  /// Remove this card from Bink
  internal static let deleteCardMessage = L10n.tr("Localizable", "delete_card_message")
  /// Delete %@
  internal static func deleteCardPlanTitle(_ p1: Any) -> String {
    return L10n.tr("Localizable", "delete_card_plan_title", String(describing: p1))
  }
  /// Delete this card
  internal static let deleteCardTitle = L10n.tr("Localizable", "delete_card_title")
  /// Delete
  internal static let deleteSwipeTitle = L10n.tr("Localizable", "delete_swipe_title")
  /// Tap to enlarge Aztec code
  internal static let detailsHeaderShowAztecCode = L10n.tr("Localizable", "details_header_show_aztec_code")
  /// Tap to enlarge barcode
  internal static let detailsHeaderShowBarcode = L10n.tr("Localizable", "details_header_show_barcode")
  /// Tap to show card number
  internal static let detailsHeaderShowCardNumber = L10n.tr("Localizable", "details_header_show_card_number")
  /// Tap to enlarge QR code
  internal static let detailsHeaderShowQrCode = L10n.tr("Localizable", "details_header_show_qr_code")
  /// Done
  internal static let done = L10n.tr("Localizable", "done")
  /// Email magic link
  internal static let emailMagicLink = L10n.tr("Localizable", "email_magic_link")
  /// Error
  internal static let errorTitle = L10n.tr("Localizable", "error_title")
  /// Filters
  internal static let filtersButtonTitle = L10n.tr("Localizable", "filters_button_title")
  /// Find and join loyalty schemes
  internal static let findAndJoinDescription = L10n.tr("Localizable", "find_and_join_description")
  /// If the email address you entered is associated with a Bink account, then a password reset email will be sent.
  internal static let fogrotPasswordPopupText = L10n.tr("Localizable", "fogrot_password_popup_text")
  /// Please enter your email address and if it is associated with a Bink account, then a password reset email will be sent
  internal static let forgotPasswordDescription = L10n.tr("Localizable", "forgot_password_description")
  /// Incorrect Format
  internal static let formFieldValidationError = L10n.tr("Localizable", "form_field_validation_error")
  /// Please wait while we work with the merchant to set up your card. This shouldn’t take long.
  internal static let genericPendingModuleDescription = L10n.tr("Localizable", "generic_pending_module_description")
  /// Request pending
  internal static let genericPendingModuleTitle = L10n.tr("Localizable", "generic_pending_module_title")
  /// Get a new card
  internal static let getNewCardButton = L10n.tr("Localizable", "get_new_card_button")
  /// Go to site
  internal static let goToSiteButton = L10n.tr("Localizable", "go_to_site_button")
  /// History
  internal static let historyTitle = L10n.tr("Localizable", "history_title")
  /// hour
  internal static let hour = L10n.tr("Localizable", "hour")
  /// hours
  internal static let hours = L10n.tr("Localizable", "hours")
  /// Bink is the only app where you can store and view all your loyalty programmes on your mobile, and link your everyday payment cards to automatically collect points and rewards.\nThrough our unique technology platform, Payment Linked Loyalty, you can use your everyday payment cards to automatically collect rewards. Using Bink, you will never miss rewards opportunities from your favourite brands again.
  internal static let howItWorksDescription = L10n.tr("Localizable", "how_it_works_description")
  /// How it works
  internal static let howItWorksTitle = L10n.tr("Localizable", "how_it_works_title")
  /// I accept
  internal static let iAccept = L10n.tr("Localizable", "i_accept")
  /// I decline
  internal static let iDecline = L10n.tr("Localizable", "i_decline")
  /// Info
  internal static let infoTitle = L10n.tr("Localizable", "info_title")
  /// Learn more about how it works
  internal static let learnMore = L10n.tr("Localizable", "learn_more")
  /// Link error
  internal static let linkModuleErrorTitle = L10n.tr("Localizable", "link_module_error_title")
  /// To link to cards
  internal static let linkModuleToLinkToCardsMessage = L10n.tr("Localizable", "link_module_to_link_to_cards_message")
  /// To %d of %d card
  internal static func linkModuleToNumberOfPaymentCardMessage(_ p1: Int, _ p2: Int) -> String {
    return L10n.tr("Localizable", "link_module_to_number_of_payment_card_message", p1, p2)
  }
  /// To %d of %d cards
  internal static func linkModuleToNumberOfPaymentCardsMessage(_ p1: Int, _ p2: Int) -> String {
    return L10n.tr("Localizable", "link_module_to_number_of_payment_cards_message", p1, p2)
  }
  /// To payment cards
  internal static let linkModuleToPaymentCardsMessage = L10n.tr("Localizable", "link_module_to_payment_cards_message")
  /// linked
  internal static let linkedStatusImageName = L10n.tr("Localizable", "linked_status_image_name")
  /// There was a problem loading the page, please try again later.
  internal static let loadingError = L10n.tr("Localizable", "loading_error")
  /// Log in failed
  internal static let logInFailedTitle = L10n.tr("Localizable", "log_in_failed_title")
  /// You are seeing this because sometimes it takes a while to log in with the merchant. In the meantime please do not attempt to log in again, but you can use your card and receive your benefits as usual. After you are logged in you will be able to see your points balance.
  internal static let logInPendingDescription = L10n.tr("Localizable", "log_in_pending_description")
  /// Log in pending
  internal static let logInPendingTitle = L10n.tr("Localizable", "log_in_pending_title")
  /// Log in
  internal static let logInTitle = L10n.tr("Localizable", "log_in_title")
  /// Log in
  internal static let login = L10n.tr("Localizable", "login")
  /// Incorrect email/password. Please try again.
  internal static let loginError = L10n.tr("Localizable", "login_error")
  /// Forgot password
  internal static let loginForgotPassword = L10n.tr("Localizable", "login_forgot_password")
  /// Welcome back!
  internal static let loginSubtitle = L10n.tr("Localizable", "login_subtitle")
  /// Log in with email
  internal static let loginTitle = L10n.tr("Localizable", "login_title")
  /// Log in with email
  internal static let loginWithEmailButton = L10n.tr("Localizable", "login_with_email_button")
  /// Log in with password
  internal static let loginWithPassword = L10n.tr("Localizable", "login_with_password")
  /// Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pellentesque, nisi ut sagittis luctus, justo orci porttitor nulla, ac ultricies sem mi quis nunc. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Curabitur placerat sagittis tortor quis vehicula. Fusce et aliquam tellus, eu semper sem. Proin eu eleifend nunc. Aliquam id lacus faucibus, euismod orci in, tempor felis. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam finibus commodo dui sit amet imperdiet. Phasellus tincidunt elementum euismod. Aliquam lobortis sapien in justo varius pulvinar. Morbi ac placerat sem. Maecenas ut auctor purus.Etiam quis blandit sapien. Nam urna quam, tempus ut massa sed, blandit ultrices neque. Sed sagittis vel quam ac interdum. Nunc tempus eros eget leo volutpat, ac sodales ex scelerisque. Aenean vel nibh lacus. Sed convallis faucibus euismod. Sed diam dui, commodo blandit tempus in, faucibus quis ligula. Integer condimentum mollis bibendum. Nullam feugiat rutrum mauris a luctus. Morbi dignissim, orci ac tempor bibendum, augue diam pharetra massa, vel commodo leo sem sed nisl. Pellentesque egestas egestas quam, nec laoreet dolor. Curabitur commodo scelerisque nisl ac mollis. Morbi egestas arcu nec convallis mollis.
  internal static let loremIpsum = L10n.tr("Localizable", "lorem_ipsum")
  /// Hold card here. It will scan automatically.
  internal static let loyaltyScannerExplainerText = L10n.tr("Localizable", "loyalty_scanner_explainer_text")
  /// You can also type in the card details yourself.
  internal static let loyaltyScannerWidgetExplainerEnterManuallyText = L10n.tr("Localizable", "loyalty_scanner_widget_explainer_enter_manually_text")
  /// Please try adding the card manually.
  internal static let loyaltyScannerWidgetExplainerUnrecognizedBarcodeText = L10n.tr("Localizable", "loyalty_scanner_widget_explainer_unrecognized_barcode_text")
  /// Enter manually
  internal static let loyaltyScannerWidgetTitleEnterManuallyText = L10n.tr("Localizable", "loyalty_scanner_widget_title_enter_manually_text")
  /// Unrecognised barcode
  internal static let loyaltyScannerWidgetTitleUnrecognizedBarcodeText = L10n.tr("Localizable", "loyalty_scanner_widget_title_unrecognized_barcode_text")
  /// Opt in to receive marketing messages
  internal static let marketingTitle = L10n.tr("Localizable", "marketing_title")
  /// minute
  internal static let minute = L10n.tr("Localizable", "minute")
  /// minutes
  internal static let minutes = L10n.tr("Localizable", "minutes")
  /// %@ does not support signing up for a new loyalty account via the Bink app.\n\nPlease go to the merchant’s website to sign up for a card, then return to the Bink app and add your new card details.
  internal static func nativeJoinUnavailableDescription(_ p1: Any) -> String {
    return L10n.tr("Localizable", "native_join_unavailable_description", String(describing: p1))
  }
  /// Sign up not supported
  internal static let nativeJoinUnavailableTitle = L10n.tr("Localizable", "native_join_unavailable_title")
  /// No
  internal static let no = L10n.tr("Localizable", "no")
  /// I don't have an account
  internal static let noAccountButtonTitle = L10n.tr("Localizable", "no_account_button_title")
  /// You are currently offline. This action cannot be performed whilst offline. Please check your internet connection and try again.
  internal static let noInternetConnectionMessage = L10n.tr("Localizable", "no_internet_connection_message")
  /// No matches
  internal static let noMatches = L10n.tr("Localizable", "no_matches")
  /// Not available
  internal static let notAvailableTitle = L10n.tr("Localizable", "not_available_title")
  /// OK
  internal static let ok = L10n.tr("Localizable", "ok")
  /// Link your payment cards to selected loyalty cards and earn rewards and benefits automatically when you pay.
  internal static let onboardingSlide1Body = L10n.tr("Localizable", "onboarding_slide1_body")
  /// Payment linked loyalty. Magic!
  internal static let onboardingSlide1Header = L10n.tr("Localizable", "onboarding_slide1_header")
  /// Store all your loyalty cards in a single digital wallet. View your rewards and points balances any time, anywhere.
  internal static let onboardingSlide2Body = L10n.tr("Localizable", "onboarding_slide2_body")
  /// All your cards in one place
  internal static let onboardingSlide2Header = L10n.tr("Localizable", "onboarding_slide2_header")
  /// Show your loyalty cards’ barcodes on screen, or collect points instantly when you pay. Whichever way, you’re always covered.
  internal static let onboardingSlide3Body = L10n.tr("Localizable", "onboarding_slide3_body")
  /// Never miss out
  internal static let onboardingSlide3Header = L10n.tr("Localizable", "onboarding_slide3_header")
  /// You can log in to your %@ account to see your points balance. This is optional.
  internal static func onlyPointsLogInDescription(_ p1: Any) -> String {
    return L10n.tr("Localizable", "only_points_log_in_description", String(describing: p1))
  }
  /// Oops
  internal static let oops = L10n.tr("Localizable", "oops")
  /// This payment card has expired
  internal static let paymentCardExpiredAlertMessage = L10n.tr("Localizable", "payment_card_expired_alert_message")
  /// This payment card has expired
  internal static let paymentCardExpiredAlertTitle = L10n.tr("Localizable", "payment_card_expired_alert_title")
  /// Position your card in the frame so the card number is visible
  internal static let paymentScannerExplainerText = L10n.tr("Localizable", "payment_scanner_explainer_text")
  /// You can also type in the card details yourself
  internal static let paymentScannerWidgetExplainerText = L10n.tr("Localizable", "payment_scanner_widget_explainer_text")
  /// Enter Manually
  internal static let paymentScannerWidgetTitle = L10n.tr("Localizable", "payment_scanner_widget_title")
  /// The active loyalty cards below are linked to this payment card. Simply pay as usual to collect points.
  internal static let pcdActiveCardDescription = L10n.tr("Localizable", "pcd_active_card_description")
  /// Linked cards
  internal static let pcdActiveCardTitle = L10n.tr("Localizable", "pcd_active_card_title")
  /// Add card
  internal static let pcdAddCardButtonTitle = L10n.tr("Localizable", "pcd_add_card_button_title")
  /// Your payment card is not authorised and you cannot link any loyalty cards to start earning rewards.\n\nYour card has failed the authorisation process or has expired. Please use the “Delete this card” action below to remove it from your wallet and re-add if required.\n\nIf you have any concerns, please read the FAQs or you can get in touch with Bink by pressing Contact us.
  internal static let pcdFailedCardDescription = L10n.tr("Localizable", "pcd_failed_card_description")
  /// Payment card inactive
  internal static let pcdFailedCardTitle = L10n.tr("Localizable", "pcd_failed_card_title")
  /// You can also add the cards below and link them to your payment cards.
  internal static let pcdOtherCardDescriptionCardsAdded = L10n.tr("Localizable", "pcd_other_card_description_cards_added")
  /// You do not have any linked loyalty cards. Add some cards to collect points.
  internal static let pcdOtherCardDescriptionNoCardsAdded = L10n.tr("Localizable", "pcd_other_card_description_no_cards_added")
  /// Other cards you can add
  internal static let pcdOtherCardTitleCardsAdded = L10n.tr("Localizable", "pcd_other_card_title_cards_added")
  /// No linked cards
  internal static let pcdOtherCardTitleNoCardsAdded = L10n.tr("Localizable", "pcd_other_card_title_no_cards_added")
  /// Card added: %@
  internal static func pcdPendingCardAdded(_ p1: Any) -> String {
    return L10n.tr("Localizable", "pcd_pending_card_added", String(describing: p1))
  }
  /// You cannot link any loyalty cards to start earning rewards.\n\nPlease wait for the card to be authorised. If the problem persists please read our FAQs or you can get in touch with Bink by pressing Contact us.
  internal static let pcdPendingCardDescription = L10n.tr("Localizable", "pcd_pending_card_description")
  /// Contact us
  internal static let pcdPendingCardHyperlink = L10n.tr("Localizable", "pcd_pending_card_hyperlink")
  /// Payment card pending
  internal static let pcdPendingCardTitle = L10n.tr("Localizable", "pcd_pending_card_title")
  /// You can link this card
  internal static let pcdYouCanLink = L10n.tr("Localizable", "pcd_you_can_link")
  /// Pending
  internal static let pendingTitle = L10n.tr("Localizable", "pending_title")
  /// Please try again
  internal static let pleaseTryAgainTitle = L10n.tr("Localizable", "please_try_again_title")
  /// Please wait
  internal static let pleaseWaitTitle = L10n.tr("Localizable", "please_wait_title")
  /// Add these loyalty cards and link them to your payment cards to collect rewards automatically when you pay.
  internal static let pllDescription = L10n.tr("Localizable", "pll_description")
  /// automatically
  internal static let pllDescriptionHighlightAutomatically = L10n.tr("Localizable", "pll_description_highlight_automatically")
  /// Unfortunately some of your cards failed to link, please try again later.
  internal static let pllErrorMessage = L10n.tr("Localizable", "pll_error_message")
  /// Error
  internal static let pllErrorTitle = L10n.tr("Localizable", "pll_error_title")
  /// Add payment cards
  internal static let pllScreenAddCardsButtonTitle = L10n.tr("Localizable", "pll_screen_add_cards_button_title")
  /// The payment cards below will be linked to your %@. Simply pay with them to collect points.
  internal static func pllScreenAddMessage(_ p1: Any) -> String {
    return L10n.tr("Localizable", "pll_screen_add_message", String(describing: p1))
  }
  /// Add card
  internal static let pllScreenAddTitle = L10n.tr("Localizable", "pll_screen_add_title")
  /// Card ending in %@
  internal static func pllScreenCardEnding(_ p1: Any) -> String {
    return L10n.tr("Localizable", "pll_screen_card_ending", String(describing: p1))
  }
  /// You have not added any payment cards yet.
  internal static let pllScreenLinkMessage = L10n.tr("Localizable", "pll_screen_link_message")
  /// Link to payment cards
  internal static let pllScreenLinkTitle = L10n.tr("Localizable", "pll_screen_link_title")
  /// The payment cards below are pending authorisation. You will be able to link them to your loyalty card once they've been approved.
  internal static let pllScreenPendingCardsDetail = L10n.tr("Localizable", "pll_screen_pending_cards_detail")
  /// Pending payment cards
  internal static let pllScreenPendingCardsTitle = L10n.tr("Localizable", "pll_screen_pending_cards_title")
  /// Add them to link this card and others.
  internal static let pllScreenSecondaryMessage = L10n.tr("Localizable", "pll_screen_secondary_message")
  /// Link to your Payment Cards
  internal static let pllTitle = L10n.tr("Localizable", "pll_title")
  /// %@%@%@ left to go!
  internal static func plrAccumulatorVoucherHeadline(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
    return L10n.tr("Localizable", "plr_accumulator_voucher_headline", String(describing: p1), String(describing: p2), String(describing: p3))
  }
  /// Your past rewards
  internal static let plrHistorySubtitle = L10n.tr("Localizable", "plr_history_subtitle")
  /// Rewards history
  internal static let plrHistoryTitle = L10n.tr("Localizable", "plr_history_title")
  /// Earned
  internal static let plrIssuedHeadline = L10n.tr("Localizable", "plr_issued_headline")
  /// Earning
  internal static let plrLcdPointsModuleAuthTitle = L10n.tr("Localizable", "plr_lcd_points_module_auth_title")
  /// Towards rewards
  internal static let plrLcdPointsModuleDescription = L10n.tr("Localizable", "plr_lcd_points_module_description")
  /// Collecting
  internal static let plrLcdPointsModuleTitle = L10n.tr("Localizable", "plr_lcd_points_module_title")
  /// spent
  internal static let plrLoyaltyCardSubtitleAccumulator = L10n.tr("Localizable", "plr_loyalty_card_subtitle_accumulator")
  /// earned
  internal static let plrLoyaltyCardSubtitleStamps = L10n.tr("Localizable", "plr_loyalty_card_subtitle_stamps")
  /// You currently don’t have any linked payment cards.\nYou can only earn rewards by shopping with a linked payment card.\nPlease add a card so you can start earning rewards.
  internal static let plrPaymentCardNeededBody = L10n.tr("Localizable", "plr_payment_card_needed_body")
  /// Payment card needed
  internal static let plrPaymentCardNeededTitle = L10n.tr("Localizable", "plr_payment_card_needed_title")
  /// Your voucher has been cancelled
  internal static let plrStampVoucherDetailCancelledHeader = L10n.tr("Localizable", "plr_stamp_voucher_detail_cancelled_header")
  /// Your voucher has expired
  internal static let plrStampVoucherDetailExpiredHeader = L10n.tr("Localizable", "plr_stamp_voucher_detail_expired_header")
  /// About this voucher
  internal static let plrStampVoucherDetailInprogressHeader = L10n.tr("Localizable", "plr_stamp_voucher_detail_inprogress_header")
  /// Your voucher was redeemed
  internal static let plrStampVoucherDetailRedeemedHeader = L10n.tr("Localizable", "plr_stamp_voucher_detail_redeemed_header")
  /// %@%@ stamp to go!
  internal static func plrStampVoucherHeadline(_ p1: Any, _ p2: Any) -> String {
    return L10n.tr("Localizable", "plr_stamp_voucher_headline", String(describing: p1), String(describing: p2))
  }
  /// %@%@ stamps to go!
  internal static func plrStampVoucherHeadlinePlural(_ p1: Any, _ p2: Any) -> String {
    return L10n.tr("Localizable", "plr_stamp_voucher_headline_plural", String(describing: p1), String(describing: p2))
  }
  /// for spending %@%@
  internal static func plrVoucherAccumulatorBurnDescription(_ p1: Any, _ p2: Any) -> String {
    return L10n.tr("Localizable", "plr_voucher_accumulator_burn_description", String(describing: p1), String(describing: p2))
  }
  /// Spent:
  internal static let plrVoucherAccumulatorEarnValueTitle = L10n.tr("Localizable", "plr_voucher_accumulator_earn_value_title")
  /// on 
  internal static let plrVoucherDatePrefix = L10n.tr("Localizable", "plr_voucher_date_prefix")
  /// Expired 
  internal static let plrVoucherDetailExpiredDatePrefix = L10n.tr("Localizable", "plr_voucher_detail_expired_date_prefix")
  /// Your %@ has expired
  internal static func plrVoucherDetailExpiredHeader(_ p1: Any) -> String {
    return L10n.tr("Localizable", "plr_voucher_detail_expired_header", String(describing: p1))
  }
  /// Expires 
  internal static let plrVoucherDetailExpiresDatePrefix = L10n.tr("Localizable", "plr_voucher_detail_expires_date_prefix")
  /// Added 
  internal static let plrVoucherDetailIssuedDatePrefix = L10n.tr("Localizable", "plr_voucher_detail_issued_date_prefix")
  /// Your %@ is ready!
  internal static func plrVoucherDetailIssuedHeader(_ p1: Any) -> String {
    return L10n.tr("Localizable", "plr_voucher_detail_issued_header", String(describing: p1))
  }
  /// Privacy Policy
  internal static let plrVoucherDetailPrivacyButtonTitle = L10n.tr("Localizable", "plr_voucher_detail_privacy_button_title")
  /// Redeemed 
  internal static let plrVoucherDetailRedeemedDatePrefix = L10n.tr("Localizable", "plr_voucher_detail_redeemed_date_prefix")
  /// Your %@ was redeemed
  internal static func plrVoucherDetailRedeemedHeader(_ p1: Any) -> String {
    return L10n.tr("Localizable", "plr_voucher_detail_redeemed_header", String(describing: p1))
  }
  /// Spend %@%@ with us and you'll get a %@%@ %@.
  internal static func plrVoucherDetailSubtextInprogress(_ p1: Any, _ p2: Any, _ p3: Any, _ p4: Any, _ p5: Any) -> String {
    return L10n.tr("Localizable", "plr_voucher_detail_subtext_inprogress", String(describing: p1), String(describing: p2), String(describing: p3), String(describing: p4), String(describing: p5))
  }
  /// Use the code above to redeem your reward. You will get %@%@%@ off your purchase.
  internal static func plrVoucherDetailSubtextIssued(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
    return L10n.tr("Localizable", "plr_voucher_detail_subtext_issued", String(describing: p1), String(describing: p2), String(describing: p3))
  }
  /// Terms & Conditions
  internal static let plrVoucherDetailTandcButtonTitle = L10n.tr("Localizable", "plr_voucher_detail_tandc_button_title")
  /// Goal:
  internal static let plrVoucherEarnTargetValueTitle = L10n.tr("Localizable", "plr_voucher_earn_target_value_title")
  /// for collecting %@%@ %@
  internal static func plrVoucherStampBurnDescription(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
    return L10n.tr("Localizable", "plr_voucher_stamp_burn_description", String(describing: p1), String(describing: p2), String(describing: p3))
  }
  /// Collected:
  internal static let plrVoucherStampEarnValueTitle = L10n.tr("Localizable", "plr_voucher_stamp_earn_value_title")
  /// You can log in to your %@ account to see your points balance and transaction history. This is optional.
  internal static func pointsAndTransactionsLogInDescription(_ p1: Any) -> String {
    return L10n.tr("Localizable", "points_and_transactions_log_in_description", String(describing: p1))
  }
  /// Points history
  internal static let pointsHistoryTitle = L10n.tr("Localizable", "points_history_title")
  /// Account exists
  internal static let pointsModuleAccountExistsStatus = L10n.tr("Localizable", "points_module_account_exists_status")
  /// Last checked
  internal static let pointsModuleLastChecked = L10n.tr("Localizable", "points_module_last_checked")
  /// Log in
  internal static let pointsModuleLogIn = L10n.tr("Localizable", "points_module_log_in")
  /// Logging in
  internal static let pointsModuleLoggingInStatus = L10n.tr("Localizable", "points_module_logging_in_status")
  /// Registering card
  internal static let pointsModuleRegisteringCardStatus = L10n.tr("Localizable", "points_module_registering_card_status")
  /// Retry login
  internal static let pointsModuleRetryLogInStatus = L10n.tr("Localizable", "points_module_retry_log_in_status")
  /// Signing up
  internal static let pointsModuleSigningUpStatus = L10n.tr("Localizable", "points_module_signing_up_status")
  /// To see history
  internal static let pointsModuleToSeeHistory = L10n.tr("Localizable", "points_module_to_see_history")
  /// View history
  internal static let pointsModuleViewHistoryMessage = L10n.tr("Localizable", "points_module_view_history_message")
  /// Popular
  internal static let popularTitle = L10n.tr("Localizable", "popular_title")
  /// Privacy Policy
  internal static let ppolicyLink = L10n.tr("Localizable", "ppolicy_link")
  /// I accept Bink's Privacy Policy
  internal static let ppolicyTitle = L10n.tr("Localizable", "ppolicy_title")
  /// Receive marketing messages
  internal static let preferencesMarketingCheckbox = L10n.tr("Localizable", "preferences_marketing_checkbox")
  /// Make sure you’re the first to know about available rewards, offers and updates!\nYou can opt out at any time.
  internal static let preferencesPrompt = L10n.tr("Localizable", "preferences_prompt")
  /// offers
  internal static let preferencesPromptHighlightOffers = L10n.tr("Localizable", "preferences_prompt_highlight_offers")
  /// rewards
  internal static let preferencesPromptHighlightRewards = L10n.tr("Localizable", "preferences_prompt_highlight_rewards")
  /// updates
  internal static let preferencesPromptHighlightUpdates = L10n.tr("Localizable", "preferences_prompt_highlight_updates")
  /// Cannot retrieve your preferences at the moment. Please try again later.
  internal static let preferencesRetrieveFail = L10n.tr("Localizable", "preferences_retrieve_fail")
  /// Make sure you’re the first to know about available rewards, offers and updates!
  internal static let preferencesScreenDescription = L10n.tr("Localizable", "preferences_screen_description")
  /// We can't update your preferences at the moment. Please try again later.
  internal static let preferencesUpdateFail = L10n.tr("Localizable", "preferences_update_fail")
  /// Privacy Policy
  internal static let privacyPolicy = L10n.tr("Localizable", "privacy_policy")
  /// Your recent transaction history.
  internal static let recentTransactionHistorySubtitle = L10n.tr("Localizable", "recent_transaction_history_subtitle")
  /// Register card
  internal static let registerCardTitle = L10n.tr("Localizable", "register_card_title")
  /// Registration failed.
  internal static let registerFailed = L10n.tr("Localizable", "register_failed")
  /// Register
  internal static let registerGcTitle = L10n.tr("Localizable", "register_gc_title")
  /// Fill out the form below to get a new %@ and start collecting rewards
  internal static func registerGhostCardDescription(_ p1: Any) -> String {
    return L10n.tr("Localizable", "register_ghost_card_description", String(describing: p1))
  }
  /// Register your card
  internal static let registerGhostCardTitle = L10n.tr("Localizable", "register_ghost_card_title")
  /// Sometimes it takes a while to register with your merchant.\nIn the meantime please do not attempt to register your card again. You can use your card and receive your benefits as normal.\nAfter registration has been completed you will be able to see your points balance.
  internal static let registerPendingDescription = L10n.tr("Localizable", "register_pending_description")
  /// Register Ghost card pending
  internal static let registerPendingTitle = L10n.tr("Localizable", "register_pending_title")
  /// All it takes is an email and password.
  internal static let registerSubtitle = L10n.tr("Localizable", "register_subtitle")
  /// Sign up with email
  internal static let registerTitle = L10n.tr("Localizable", "register_title")
  /// Registration failed
  internal static let registrationFailedTitle = L10n.tr("Localizable", "registration_failed_title")
  /// Please go to the merchant’s website to join this scheme. You can then come back and add your card.
  internal static let registrationUnavailableDescription = L10n.tr("Localizable", "registration_unavailable_description")
  /// Registration unavailable
  internal static let registrationUnavailableTitle = L10n.tr("Localizable", "registration_unavailable_title")
  /// Retry
  internal static let retryTitle = L10n.tr("Localizable", "retry_title")
  /// Scan a card you already have
  internal static let scanACardDescription = L10n.tr("Localizable", "scan_a_card_description")
  /// Scan and link your payment card
  internal static let scanAndLinkDescription = L10n.tr("Localizable", "scan_and_link_description")
  /// Search
  internal static let search = L10n.tr("Localizable", "search")
  /// Is my Data Secure?
  internal static let securityAndPrivacyAlertTitle = L10n.tr("Localizable", "security_and_privacy_alert_title")
  /// Bink takes the security of your information extremely seriously and uses a range of best in class methods to protect your information.\nBink is a registered PCI Level 1 Service Provider for the protection of sensitive first party data and personally identifiable information.
  internal static let securityAndPrivacyDescription = L10n.tr("Localizable", "security_and_privacy_description")
  /// How we protect your data
  internal static let securityAndPrivacyMessage = L10n.tr("Localizable", "security_and_privacy_message")
  /// Security and privacy
  internal static let securityAndPrivacyTitle = L10n.tr("Localizable", "security_and_privacy_title")
  /// Add these loyalty cards to see your points and rewards in real time in the Bink app.
  internal static let seeDescription = L10n.tr("Localizable", "see_description")
  /// See your balance
  internal static let seeTitle = L10n.tr("Localizable", "see_title")
  /// Get in touch with Bink
  internal static let settingsRowContactSubtitle = L10n.tr("Localizable", "settings_row_contact_subtitle")
  /// Contact us
  internal static let settingsRowContactTitle = L10n.tr("Localizable", "settings_row_contact_title")
  /// Frequently asked questions
  internal static let settingsRowFaqsSubtitle = L10n.tr("Localizable", "settings_row_faqs_subtitle")
  /// FAQs
  internal static let settingsRowFaqsTitle = L10n.tr("Localizable", "settings_row_faqs_title")
  /// Feature flags
  internal static let settingsRowFeatureflagsTitle = L10n.tr("Localizable", "settings_row_featureflags_title")
  /// Find out more about Bink
  internal static let settingsRowHowitworksSubtitle = L10n.tr("Localizable", "settings_row_howitworks_subtitle")
  /// How it works
  internal static let settingsRowHowitworksTitle = L10n.tr("Localizable", "settings_row_howitworks_title")
  /// Log out
  internal static let settingsRowLogoutTitle = L10n.tr("Localizable", "settings_row_logout_title")
  /// Preferences
  internal static let settingsRowPreferencesTitle = L10n.tr("Localizable", "settings_row_preferences_title")
  /// Privacy policy
  internal static let settingsRowPrivacypolicyTitle = L10n.tr("Localizable", "settings_row_privacypolicy_title")
  /// Rate this app
  internal static let settingsRowRateappTitle = L10n.tr("Localizable", "settings_row_rateapp_title")
  /// How we protect your data
  internal static let settingsRowSecuritySubtitle = L10n.tr("Localizable", "settings_row_security_subtitle")
  /// Security and privacy
  internal static let settingsRowSecurityTitle = L10n.tr("Localizable", "settings_row_security_title")
  /// Terms and conditions
  internal static let settingsRowTermsandconditionsTitle = L10n.tr("Localizable", "settings_row_termsandconditions_title")
  /// Theme
  internal static let settingsRowThemeTitle = L10n.tr("Localizable", "settings_row_theme_title")
  /// About
  internal static let settingsSectionAboutTitle = L10n.tr("Localizable", "settings_section_about_title")
  /// Account
  internal static let settingsSectionAccountTitle = L10n.tr("Localizable", "settings_section_account_title")
  /// Appearance
  internal static let settingsSectionAppearanceTitle = L10n.tr("Localizable", "settings_section_appearance_title")
  /// Beta
  internal static let settingsSectionBetaTitle = L10n.tr("Localizable", "settings_section_beta_title")
  /// Only accessible on debug builds
  internal static let settingsSectionDebugSubtitle = L10n.tr("Localizable", "settings_section_debug_subtitle")
  /// Debug
  internal static let settingsSectionDebugTitle = L10n.tr("Localizable", "settings_section_debug_title")
  /// Legal
  internal static let settingsSectionLegalTitle = L10n.tr("Localizable", "settings_section_legal_title")
  /// Support and feedback
  internal static let settingsSectionSupportTitle = L10n.tr("Localizable", "settings_section_support_title")
  /// Cancel
  internal static let settingsThemeCancelTitle = L10n.tr("Localizable", "settings_theme_cancel_title")
  /// Dark
  internal static let settingsThemeDarkTitle = L10n.tr("Localizable", "settings_theme_dark_title")
  /// Light
  internal static let settingsThemeLightTitle = L10n.tr("Localizable", "settings_theme_light_title")
  /// System
  internal static let settingsThemeSystemTitle = L10n.tr("Localizable", "settings_theme_system_title")
  /// Settings
  internal static let settingsTitle = L10n.tr("Localizable", "settings_title")
  /// Who we are
  internal static let settingsWhoWeAreTitle = L10n.tr("Localizable", "settings_who_we_are_title")
  /// Sign up
  internal static let signUpButtonTitle = L10n.tr("Localizable", "sign_up_button_title")
  /// Sign up failed
  internal static let signUpFailedTitle = L10n.tr("Localizable", "sign_up_failed_title")
  /// Fill out the form below to get a new %@ and start collecting rewards
  internal static func signUpNewCardDescription(_ p1: Any) -> String {
    return L10n.tr("Localizable", "sign_up_new_card_description", String(describing: p1))
  }
  /// Sign up for %@
  internal static func signUpNewCardTitle(_ p1: Any) -> String {
    return L10n.tr("Localizable", "sign_up_new_card_title", String(describing: p1))
  }
  /// Sometimes it takes a while to sign up with your merchant.\nIn the meantime please do not attempt to sign up again. You can use your card and receive your benefits as normal.\nAfter the sign up has been completed you will be able to see your points balance.
  internal static let signUpPendingDescription = L10n.tr("Localizable", "sign_up_pending_description")
  /// Sign up pending
  internal static let signUpPendingTitle = L10n.tr("Localizable", "sign_up_pending_title")
  /// Sign in with Apple failed.
  internal static let socialTandcsSiwaError = L10n.tr("Localizable", "social_tandcs_siwa_error")
  /// One last step...
  internal static let socialTandcsSubtitle = L10n.tr("Localizable", "social_tandcs_subtitle")
  /// Terms and conditions
  internal static let socialTandcsTitle = L10n.tr("Localizable", "social_tandcs_title")
  /// Connection error. Please try again.
  internal static let sslPinningFailureText = L10n.tr("Localizable", "ssl_pinning_failure_text")
  /// Error
  internal static let sslPinningFailureTitle = L10n.tr("Localizable", "ssl_pinning_failure_title")
  /// Add these loyalty cards to store your barcode in Bink and always have it on your phone. No more plastic!
  internal static let storeDescription = L10n.tr("Localizable", "store_description")
  /// Store your barcode
  internal static let storeTitle = L10n.tr("Localizable", "store_title")
  /// %@ build %@
  internal static func supportMailAppVersion(_ p1: Any, _ p2: Any) -> String {
    return L10n.tr("Localizable", "support_mail_app_version", String(describing: p1), String(describing: p2))
  }
  /// \n\n\n\nThe below information will help us with with your query, please don’t change it.\nBink ID: %@\nVersion: %@\niOS Version: %@
  internal static func supportMailBody(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
    return L10n.tr("Localizable", "support_mail_body", String(describing: p1), String(describing: p2), String(describing: p3))
  }
  /// Bink App Support
  internal static let supportMailSubject = L10n.tr("Localizable", "support_mail_subject")
  /// Please read the Bink Privacy Policy for further details of how your data will be processed
  internal static let tandcsDescription = L10n.tr("Localizable", "tandcs_description")
  /// Terms and Conditions
  internal static let tandcsLink = L10n.tr("Localizable", "tandcs_link")
  /// I agree to Bink's Terms and Conditions
  internal static let tandcsTitle = L10n.tr("Localizable", "tandcs_title")
  /// I authorise Mastercard, Visa and American Express to monitor activity on my payment card to determine when I have made a qualifying transaction, and for Mastercard, Visa and American Express to share such transaction details with Bink to enable my card-linked offer(s) and target offers that may be of interest to me. \n\nFor information about Bink’s privacy practices please see Bink’s Privacy Policy. You may opt-out of transaction monitoring on the payment card(s) you entered at any time by deleting your payment card from your Bink wallet.
  internal static let termsAndConditionsDescription = L10n.tr("Localizable", "terms_and_conditions_description")
  /// Terms and conditions
  internal static let termsAndConditionsTitle = L10n.tr("Localizable", "terms_and_conditions_title")
  /// To be implemented
  internal static let toBeImplementedMessage = L10n.tr("Localizable", "to_be_implemented_message")
  /// Go to merchant site
  internal static let toMerchantSiteButton = L10n.tr("Localizable", "to_merchant_site_button")
  /// %@ does not support displaying your transaction history in the Bink app.\n\nYou can view your history and balance on the merchant’s website.
  internal static func transactionHistoryNotSupportedDescription(_ p1: Any) -> String {
    return L10n.tr("Localizable", "transaction_history_not_supported_description", String(describing: p1))
  }
  /// Transaction history not supported
  internal static let transactionHistoryNotSupportedTitle = L10n.tr("Localizable", "transaction_history_not_supported_title")
  /// No transactions to display since adding your card to Bink.\nIn some cases transactions take longer to update.
  internal static let transactionHistoryUnavailableDescription = L10n.tr("Localizable", "transaction_history_unavailable_description")
  /// Points history
  internal static let transactionHistoryUnavailableTitle = L10n.tr("Localizable", "transaction_history_unavailable_title")
  /// Payment Linked Loyalty (PLL) allows customers’ payment cards to be securely linked to loyalty programmes, enabling every customer to be identified and rewarded every time they shop.\nThis is currently not available for this merchant.
  internal static let unlinkablePllDescription = L10n.tr("Localizable", "unlinkable_pll_description")
  /// Payment Linked Loyalty unavailable
  internal static let unlinkablePllTitle = L10n.tr("Localizable", "unlinkable_pll_title")
  /// unlinked
  internal static let unlinkedStatusImageName = L10n.tr("Localizable", "unlinked_status_image_name")
  /// Add these loyalty cards and link them to your payment cards to collect rewards automatically when you pay.
  internal static let walletPromptLinkBody = L10n.tr("Localizable", "wallet_prompt_link_body")
  /// Link to your payment cards
  internal static let walletPromptLinkTitle = L10n.tr("Localizable", "wallet_prompt_link_title")
  /// More coming soon!
  internal static let walletPromptMoreComingSoon = L10n.tr("Localizable", "wallet_prompt_more_coming_soon")
  /// Collect rewards automatically for select loyalty cards by linking them to your payment cards.
  internal static let walletPromptPayment = L10n.tr("Localizable", "wallet_prompt_payment")
  /// Add these loyalty cards to see your points and rewards balances in real time.
  internal static let walletPromptSeeBody = L10n.tr("Localizable", "wallet_prompt_see_body")
  /// See your points balances
  internal static let walletPromptSeeTitle = L10n.tr("Localizable", "wallet_prompt_see_title")
  /// Add these loyalty cards to store their barcodes so you'll always have them on your phone when you need them.
  internal static let walletPromptStoreBody = L10n.tr("Localizable", "wallet_prompt_store_body")
  /// Store your barcodes
  internal static let walletPromptStoreTitle = L10n.tr("Localizable", "wallet_prompt_store_title")
  /// Something went wrong.
  internal static let wentWrong = L10n.tr("Localizable", "went_wrong")
  /// Below are a list of people that have been instrumental in developing the app you now hold in your hands.
  internal static let whoWeAreBody = L10n.tr("Localizable", "who_we_are_body")
  /// Who we are
  internal static let whoWeAreTitle = L10n.tr("Localizable", "who_we_are_title")
  /// Yes
  internal static let yes = L10n.tr("Localizable", "yes")
  /// First name
  internal static let zendeskIdentityPromptFirstName = L10n.tr("Localizable", "zendesk_identity_prompt_first_name")
  /// Last name
  internal static let zendeskIdentityPromptLastName = L10n.tr("Localizable", "zendesk_identity_prompt_last_name")
  /// Please enter your contact details
  internal static let zendeskIdentityPromptMessage = L10n.tr("Localizable", "zendesk_identity_prompt_message")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
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
