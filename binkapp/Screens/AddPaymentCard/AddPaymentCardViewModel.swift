//
//  AddPaymentCardViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 27/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct AddPaymentCardViewModel {

    let router: MainScreenRouter
    let paymentCard: PaymentCardCreateModel

    init(router: MainScreenRouter, paymentCard: PaymentCardCreateModel) {
        self.router = router
        self.paymentCard = paymentCard
    }

    var formDataSource: FormDataSource {
        return FormDataSource(paymentCard)
    }

    var paymentCardType: PaymentCardType? {
        return paymentCard.cardType
    }

    func setPaymentCardType(_ cardType: PaymentCardType?) {
        paymentCard.cardType = cardType
    }

    func setPaymentCardFullPan(_ fullPan: String?) {
        paymentCard.fullPan = fullPan
    }

    func setPaymentCardName(_ nameOnCard: String?) {
        paymentCard.nameOnCard = nameOnCard
    }

    func setPaymentCardExpiry(month: Int?, year: Int?) {
        paymentCard.month = month
        paymentCard.year = year
    }

    func toPaymentTermsAndConditions() {
        router.toPaymentTermsAndConditionsViewController()
    }

//    func addPaymentCard() {
//        guard let paymentCreateRequest = PaymentCardCreateRequest(model: paymentCard) else {
//            return
//        }
//
//        try? apiManager.doRequest(url: .postPaymentCard, httpMethod: .post, parameters: paymentCreateRequest.asDictionary(), onSuccess: { (response: PaymentCardResponse) in
//            //
//        }, onError: { error in
//            print(error)
//        })
//    }
}
