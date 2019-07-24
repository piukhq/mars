//
//  AddCardPresenter.swift
//  binkapp
//
//  Copyright (c) 2019 Bink. All rights reserved.
//

import UIKit

protocol AddCardPresentationLogic
{
  func presentSomething(response: AddCard.Something.Response)
}

class AddCardPresenter: AddCardPresentationLogic
{
  weak var viewController: AddCardDisplayLogic?
  
  func presentSomething(response: AddCard.Something.Response)
  {
    let viewModel = AddCard.Something.ViewModel()
    viewController?.displaySomething(viewModel: viewModel)
  }
}
