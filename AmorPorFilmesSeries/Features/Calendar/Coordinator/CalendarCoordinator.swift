//
//  CalendarCoordinator.swift
//  AmorPorFilmesSeries
//
//  Created by Jules on 05/06/25.
//

import UIKit

class CalendarCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: NavigationController

    init(navigationController: NavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = CalendarViewModel(coordinator: self)
        let viewController = CalendarViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
