//
//  AddPaymentCardViewModel.swift
//  binkapp
//
//  Created by Nick Farrant on 27/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

struct AddPaymentCardViewModel {
    private let apiManager: ApiManager
    private let router: MainScreenRouter
    private let paymentCard: PaymentCardCreateModel

    init(apiManager: ApiManager, router: MainScreenRouter, paymentCard: PaymentCardCreateModel) {
        self.apiManager = apiManager
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

    func toPaymentTermsAndConditions(delegate: PaymentTermsAndConditionsViewControllerDelegate?) {
        router.toPaymentTermsAndConditionsViewController(delegate: delegate)
    }

    func addPaymentCard(completion: @escaping (Bool) -> Void) {
        guard let paymentCreateRequest = PaymentCardCreateRequest(model: paymentCard) else {
            return
        }

        try? apiManager.doRequest(url: .postPaymentCard, httpMethod: .post, parameters: paymentCreateRequest.asDictionary(), onSuccess: { (response: PaymentCardResponse) in
            completion(true)
        }, onError: { error in
            print(error)
            completion(false)
        })
    }

    func popToRootViewController() {
        router.popToRootViewController()
    }

    func displayError() {
        router.displaySimplePopup(title: "Oops", message: "Something went wrong.")
    }
}
