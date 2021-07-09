//
//  AutomatedTesting_4_GoToSite.swift
//  binkappUITests
//
//  Created by Sean Williams on 08/07/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import XCTest

class AutomatedTesting_4_GoToSite: XCTestCase {
    private var app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        UIView.setAnimationsEnabled(false)
        
        app.launchArguments = ["UI-testing"]
        app.launch()
        app.buttons["Browse brands"].tap()
    }
    
    private func goToSiteAndAssertErrorAlertExistanceIsFalse() {
        app.buttons["Bink info button"].tap()
        app.buttons["Go to site"].tap()
        XCTAssertFalse(app.alerts.element.waitForExistence(timeout: 3))
    }
    
//    func test_0_burgerKing_goToSite_loadsWebpage_successfully() {
//        app.tables.cells["Burger King"].tap()
//        goToSiteAndAssertErrorAlertExistanceIsFalse()
//    }

    func test_1_coOp_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Co-op"].firstMatch.tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }

//    func test_2_fatFace_goToSite_loadsWebpage_successfully() {
//        app.tables.cells["FatFace"].tap()
//        goToSiteAndAssertErrorAlertExistanceIsFalse()
//    }

    func test_3_harveyNichols_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Harvey Nichols"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }

    func test_4_iceland_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Iceland"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_5_wasabi_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Wasabi"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
//    func test_6_whSmith_goToSite_loadsWebpage_successfully() {
//        app.tables.cells["WHSmith"].tap()
//        goToSiteAndAssertErrorAlertExistanceIsFalse()
//    }
    
    func test_7_morrisons_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Morrisons"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_8_superdrug_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Superdrug"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_9_tesco_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Tesco"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_10_waterstones_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Waterstones"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
//    func test_11_addisonLee_goToSite_loadsWebpage_successfully() {
//        app.tables.cells["Addison Lee"].tap()
//        goToSiteAndAssertErrorAlertExistanceIsFalse()
//    }
    
    func test_12_alitaliaMilleMiglia_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Alitalia MilleMiglia"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_13_asiaMiles_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Asia Miles"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_14_bAndQ_goToSite_loadsWebpage_successfully() {
        app.tables.cells["B&Q"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }

    func test_15_beales_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Beales"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }

    func test_16_beefeater_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Beefeater"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }

//    func test_17_bestWestern_goToSite_loadsWebpage_successfully() {
//        app.tables.cells["Best Western"].tap()
//        goToSiteAndAssertErrorAlertExistanceIsFalse()
//    }

    func test_18_boost_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Boost Juice Bars"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }

    func test_19_boots_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Boots"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }

    func test_20_brewersFayre_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Brewers Fayre"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }

    func test_21_britishAirways_goToSite_loadsWebpage_successfully() {
        app.tables.cells["British Airways"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_22_clubIndvidual_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Club Individual"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_23_costa_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Costa"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_24_cotswoldOutdoor_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Cotswold Outdoor"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_25_debenhams_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Debenhams"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_26_esprit_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Esprit"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_27_esquires_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Esquires"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_28_eurostar_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Eurostar"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_29_foyles_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Foyles"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_30_goOutdoors_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Go Outdoors"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_31_grosvenorCasinos_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Grosvenor Casinos"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_32_hAndM_goToSite_loadsWebpage_successfully() {
        app.tables.cells["H&M"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_33_harrods_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Harrods"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_34_heathrow_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Heathrow"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_35_hiltonHonors_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Hilton Honors"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_36_hollandAndBarett_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Holland & Barrett"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_37_hotelChocolat_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Hotel Chocolat"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_38_houseOfFraser_goToSite_loadsWebpage_successfully() {
        app.tables.cells["House of Fraser"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_39_iberia_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Iberia"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_40_ikeaFamily_goToSite_loadsWebpage_successfully() {
        app.tables.cells["IKEA Family"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_41_johnLewis_goToSite_loadsWebpage_successfully() {
        app.tables.cells["John Lewis"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_42_kfc_goToSite_loadsWebpage_successfully() {
        app.tables.cells["KFC"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_43_krispyKreme_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Krispy Kreme"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_44_mAndCo_goToSite_loadsWebpage_successfully() {
        app.tables.cells["M and Co"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_45_malaysiaAirlines_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Malaysia Airlines"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_46_marksAndSpencer_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Marks and Spencer"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_47_matalan_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Matalan"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_48_monsoon_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Monsoon"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_49_nandos_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Nandos"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_50_nationalTrust_goToSite_loadsWebpage_successfully() {
        app.tables.cells["National Trust"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_51_nectar_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Nectar"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_52_odeon_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Odeon"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_53_paperchase_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Paperchase"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_54_petsAtHome_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Pets at Home"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_55_rspb_goToSite_loadsWebpage_successfully() {
        app.tables.cells["RSPB"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_56_russellAndBromley_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Russell & Bromley"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_57_shell_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Shell"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_58_singaporeAirlines_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Singapore Airlines"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_59_spaceNK_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Space.NK"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_60_starbucks_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Starbucks"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_61_subway_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Subway"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_62_swissAir_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Swiss Air"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_63_tableTable_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Table Table"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_64_texaco_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Texaco"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_65_theBodyShop_goToSite_loadsWebpage_successfully() {
        app.tables.cells["The Body Shop"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_66_thePerfumeShop_goToSite_loadsWebpage_successfully() {
        app.tables.cells["The Perfume Shop"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_67_theWorks_goToSite_loadsWebpage_successfully() {
        app.tables.cells["The Works"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_68_tkMaxx_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Tk Maxx"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_69_towsure_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Towsure"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
    
    func test_70_waitrose_goToSite_loadsWebpage_successfully() {
        app.tables.cells["Waitrose"].tap()
        goToSiteAndAssertErrorAlertExistanceIsFalse()
    }
}
