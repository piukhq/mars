//
//  RemoteConfigFileModelTests.swift
//  binkappTests
//
//  Created by Ricardo Silva on 17/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import XCTest
@testable import binkapp

// swiftlint:disable all

class RemoteConfigFileModelTests: XCTestCase {
    let json = """
    {
      "local_points_collection": {
        "idle_threshold": 20,
        "idle_retry_limit": 2,
        "agents": [
                {
            "merchant": "nandos",
            "membership_plan_id": {
              "dev": 64,
              "staging": 64,
              "preprod": 64,
              "production": 64
            },
            "enabled": {
              "ios": false,
              "ios_debug": true,
              "android": false,
              "android_debug": false
            },
            "loyalty_scheme": {
              "balance_currency": null,
              "balance_prefix": null,
              "balance_suffix": "rewards"
            },
            "points_collection_url": "https://login.nandos.co.uk/",
            "fields": {
              "username_field_common_name": "email",
              "required_credentials": [
                "username",
                "password"
              ],
              "auth_fields": [
                {
                  "column": "Email",
                  "common_name": "email",
                  "type": 0,
                  "choice": []
                },
                {
                  "column": "Password",
                  "common_name": "password",
                  "type": 1,
                  "choice": []
                }
              ]
            },
            "script_file_name": "LocalPointsCollection_Navigate_Nandos"
          },
          {
            "merchant": "nectar",
            "membership_plan_id": {
              "dev": 14,
              "staging": 14,
              "preprod": 14,
              "production": 14
            },
            "enabled": {
              "ios": true,
              "ios_debug": true,
              "android": false,
              "android_debug": true
            },
            "loyalty_scheme": {
              "balance_currency": null,
              "balance_prefix": null,
              "balance_suffix": "points"
            },
            "points_collection_url": "https://account.sainsburys.co.uk/nectar/login?",
            "fields": {
              "username_field_common_name": "email",
              "required_credentials": [
                "username",
                "password"
              ],
              "auth_fields": [
                {
                  "column": "Email",
                  "common_name": "email",
                  "type": 0,
                  "choice": []
                },
                {
                  "column": "Password",
                  "common_name": "password",
                  "type": 1,
                  "choice": []
                }
              ]
            },
            "script_file_name": "LocalPointsCollection_Navigate_Nectar"
          },
          {
            "merchant": "tesco",
            "membership_plan_id": {
              "dev": 207,
              "staging": 230,
              "preprod": 230,
              "production": 203
            },
            "enabled": {
              "ios": true,
              "ios_debug": true,
              "android": true,
              "android_debug": true
            },
            "loyalty_scheme": {
              "balance_currency": null,
              "balance_prefix": null,
              "balance_suffix": "points"
            },
            "points_collection_url": "https://secure.tesco.com/Clubcard/MyAccount/home/Home",
            "fields": {
              "username_field_common_name": "email",
              "required_credentials": [
                "username",
                "password"
              ],
              "auth_fields": [
                {
                  "column": "Email",
                  "common_name": "email",
                  "type": 0,
                  "choice": []
                },
                {
                  "column": "Password",
                  "common_name": "password",
                  "type": 1,
                  "choice": []
                }
              ]
            },
            "script_file_name": "LocalPointsCollection_Navigate_Tesco"
          },
          {
            "merchant": "heathrow",
            "membership_plan_id": {
              "dev": 32,
              "staging": 32,
              "preprod": 32,
              "production": 32
            },
            "enabled": {
              "ios": true,
              "ios_debug": true,
              "android": true,
              "android_debug": true
            },
            "loyalty_scheme": {
              "balance_currency": null,
              "balance_prefix": null,
              "balance_suffix": "points"
            },
            "points_collection_url": "https://www.heathrow.com/rewards/home",
            "fields": {
              "username_field_common_name": "username",
              "required_credentials": [
                "username",
                "password",
                "cardNumber"
              ],
              "auth_fields": [
                {
                  "column": "Username",
                  "common_name": "username",
                  "type": 0,
                  "choice": []
                },
                {
                  "column": "Password",
                  "common_name": "password",
                  "type": 1,
                  "choice": []
                }
              ]
            },
            "script_file_name": "LocalPointsCollection_Navigate_Heathrow"
          },
          {
            "merchant": "superdrug",
            "membership_plan_id": {
              "dev": 16,
              "staging": 16,
              "preprod": 16,
              "production": 16
            },
            "enabled": {
              "ios": true,
              "ios_debug": true,
              "android": true,
              "android_debug": true
            },
            "loyalty_scheme": {
              "balance_currency": null,
              "balance_prefix": null,
              "balance_suffix": "points"
            },
            "points_collection_url": "https://www.superdrug.com/login",
            "fields": {
              "username_field_common_name": "email",
              "required_credentials": [
                "username",
                "password"
              ],
              "auth_fields": [
                {
                  "column": "Email",
                  "common_name": "email",
                  "type": 0,
                  "choice": []
                },
                {
                  "column": "Password",
                  "common_name": "password",
                  "type": 1,
                  "choice": []
                }
              ]
            },
            "script_file_name": "LocalPointsCollection_Navigate_Superdrug"
          },
          {
            "merchant": "waterstones",
            "membership_plan_id": {
              "dev": 52,
              "staging": 52,
              "preprod": 52,
              "production": 52
            },
            "enabled": {
              "ios": false,
              "ios_debug": true,
              "android": false,
              "android_debug": true
            },
            "loyalty_scheme": {
              "balance_currency": null,
              "balance_prefix": null,
              "balance_suffix": "stamps"
            },
            "points_collection_url": "https://www.waterstones.com/account/waterstonescard",
            "fields": {
              "username_field_common_name": "email",
              "required_credentials": [
                "username",
                "password"
              ],
              "auth_fields": [
                {
                  "column": "Email",
                  "common_name": "email",
                  "type": 0,
                  "choice": []
                },
                {
                  "column": "Password",
                  "common_name": "password",
                  "type": 1,
                  "choice": []
                }
              ]
            },
            "script_file_name": "LocalPointsCollection_Navigate_Waterstones"
          },
          {
            "merchant": "kfc",
            "membership_plan_id": {
              "dev": 66,
              "staging": 66,
              "preprod": 66,
              "production": 66
            },
            "enabled": {
              "ios": false,
              "ios_debug": false,
              "android": false,
              "android_debug": true
            },
            "loyalty_scheme": {
              "balance_currency": null,
              "balance_prefix": null,
              "balance_suffix": "stamps"
            },
            "points_collection_url": "https://order.kfc.co.uk/account/my-rewards",
            "fields": {
              "username_field_common_name": "email",
              "required_credentials": [
                "username",
                "password"
              ],
              "auth_fields": [
                {
                  "column": "Email",
                  "common_name": "email",
                  "type": 0,
                  "choice": []
                },
                {
                  "column": "Password",
                  "common_name": "password",
                  "type": 1,
                  "choice": []
                }
              ]
            },
            "script_file_name": "LocalPointsCollection_Navigate_Kfc"
          },
          {
            "merchant": "subway",
            "membership_plan_id": {
              "dev": 65,
              "staging": 65,
              "preprod": 65,
              "production": 65
            },
            "enabled": {
              "ios": false,
              "ios_debug": true,
              "android": true,
              "android_debug": true
            },
            "loyalty_scheme": {
              "balance_currency": null,
              "balance_prefix": null,
              "balance_suffix": "points"
            },
            "points_collection_url": "https://subcard.subway.co.uk/cardholder/en/",
            "fields": {
              "username_field_common_name": "email",
              "required_credentials": [
                "username",
                "password"
              ],
              "auth_fields": [
                {
                  "column": "Email",
                  "common_name": "email",
                  "type": 0,
                  "choice": []
                },
                {
                  "column": "Password",
                  "common_name": "password",
                  "type": 1,
                  "choice": []
                }
              ]
            },
            "script_file_name": "LocalPointsCollection_Navigate_Subway"
          },
          {
            "merchant": "starbucks",
            "membership_plan_id": {
              "dev": 15,
              "staging": 15,
              "preprod": 15,
              "production": 15
            },
            "enabled": {
              "ios": false,
              "ios_debug": false,
              "android": false,
              "android_debug": true
            },
            "loyalty_scheme": {
              "balance_currency": null,
              "balance_prefix": null,
              "balance_suffix": "stars"
            },
            "points_collection_url": "https://www.starbucks.co.uk/account/login",
            "fields": {
              "username_field_common_name": "email",
              "required_credentials": [
                "username",
                "password"
              ],
              "auth_fields": [
                {
                  "column": "Email",
                  "common_name": "email",
                  "type": 0,
                  "choice": []
                },
                {
                  "column": "Password",
                  "common_name": "password",
                  "type": 1,
                  "choice": []
                }
              ]
            },
            "script_file_name": "LocalPointsCollection_Navigate_Starbucks"
          }
        ]
      },
      "app_config": {
        "in_app_review_enabled": true,
        "recommended_live_app_version": {
          "ios": "2.3.17",
          "android": "2.3.14"
        }
      },
      "dynamic_actions": [
        {
          "name": "xmas_2021",
          "type": "xmas",
          "start_date": 1639990800,
          "end_date": 1640854800,
          "locations": [
            {
              "icon": "U+1F384",
              "screen": "loyalty_wallet",
              "area": "left_top_bar",
              "action": "single_tap"
            },
            {
              "icon": "U+1F384",
              "screen": "payment_wallet",
              "area": "left_top_bar",
              "action": "single_tap"
            }
          ],
          "event": {
            "type": "launch_modal",
            "body": {
              "title": "Merry Binkin' Christmas!",
              "description": "The Mobile team at Bink would like to wish you all a very Merry Christmas and a happy New Year! ",
              "cta": {
                "title": "Contact us",
                "action": "zd_contact_us"
              }
            }
          },
          "enabled_live": false,
          "force_debug": false
        }
      ],
      "beta": {
        "features": [
          {
            "slug": "themes",
            "type": "themes",
            "title": "Themes",
            "description": "Toggle theming in the Bink app",
            "enabled": true
          },
          {
            "slug": "tesco_locations",
            "type": "tesco_locations",
            "title": "Tesco Locations",
            "description": "Geo-locations of Tesco stores in the UK",
            "enabled": true
          }
        ],
        "users": [
          {
            "uid": "7159b222-0475-4fb5-8239-967cf4a6969d"
          },
          {
            "uid": "7136ea1a-cac3-43b9-9e0a-a1cca98c6b24"
          },
          {
            "uid": "ca7c471c-1dec-48ae-bc70-cf4441f025c9"
          },
          {
            "uid": "fb4b42b1-4b86-4586-9616-7b85db00bfda"
          },
          {
            "uid": "ddf861d9-a053-4d8c-81b8-ef7df28f58a3"
          },
          {
            "uid": "f3f661a7-3f44-46bc-a363-2f2f07613ca4"
          },
          {
            "uid": "52211c59-671c-4db8-a6dd-8b5ba8e6e546"
          },
          {
            "uid": "c68ae9af-cdf7-4ac6-b25f-0e80c42469e8"
          },
          {
            "uid": "7023f33d-3e15-42da-8c5a-9f310d1589d6"
          },
          {
            "uid": "42d76e81-6c74-477b-a0e2-ca26dfac5c0a"
          },
          {
            "uid": "77a43c7c-da72-4f89-b152-447597fe8249"
          },
          {
            "uid": "44b1173f-09f0-4136-b9bd-cbe862926ca7"
          },
          {
            "uid": "60ecabf6-e419-488f-b06e-aa1aac33d1a5"
          },
          {
            "uid": "08c8df52-6611-4699-8013-d25b7f778ae9"
          },
          {
            "uid": "39caf942-7186-4f5a-861d-1b583334a473"
          }
        ]
      }
    }
"""

    func test_remoteFileShouldParse() throws {
        let decoded = json.asDecodedObject(ofType: RemoteConfigFile.self)
        
        XCTAssertNotNil(decoded)
    }
}