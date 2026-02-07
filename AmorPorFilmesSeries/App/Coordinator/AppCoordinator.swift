//
//  AppCoordinator.swift
//  PaixaoPorFilmesESeries
//
//  Created by Andre  Haas on 28/05/25.
//

// App/Coordinator/AppCoordinator.swift
import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: NavigationController { get set }
    
    func start()
}

class AppCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: NavigationController
    
    init(navigationController: NavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        
        if isLoggedIn {
            showMainTabBarFlow()
        } else {
            showAuthFlow()
        }
    }
    
    private func showAuthFlow() {
        let authCoordinator = AuthCoordinator(
            navigationController: navigationController
        )
        authCoordinator.delegate = self
        childCoordinators.append(authCoordinator)
        authCoordinator.start()
    }
    
    private func showMainTabBarFlow() {
        navigationController.viewControllers = []
        childCoordinators.removeAll()
        
        let tabBarController = UITabBarController()
        tabBarController.tabBar.tintColor = Color.primary
        tabBarController.tabBar.barTintColor = Color.backgroundDark
        tabBarController.tabBar.backgroundColor = Color.backgroundDark
        tabBarController.tabBar.isTranslucent = true
        
        // 1. Home
        let homeNavController = NavigationController()
        let homeCoordinator = HomeCoordinator(navigationController: homeNavController)
        homeCoordinator.delegate = self
        childCoordinators.append(homeCoordinator)
        homeCoordinator.start()
        homeNavController.tabBarItem = UITabBarItem(title: "Início", image: UIImage(systemName: "house"), tag: 0)
        homeNavController.tabBarItem.selectedImage = UIImage(systemName: "house.fill")
        
        // 2. Explore (Placeholder)
        let exploreNavController = NavigationController()
        let exploreVC = UIViewController()
        exploreVC.view.backgroundColor = Color.backgroundDark
        exploreVC.title = "Explorar"
        exploreNavController.setViewControllers([exploreVC], animated: false)
        exploreNavController.tabBarItem = UITabBarItem(title: "Explorar", image: UIImage(systemName: "magnifyingglass"), tag: 1)

        // 3. My List
        let watchlistNavController = NavigationController()
        let watchlistCoordinator = WatchlistCoordinator(navigationController: watchlistNavController)
        childCoordinators.append(watchlistCoordinator)
        watchlistCoordinator.start()
        watchlistNavController.tabBarItem = UITabBarItem(title: "Minha Lista", image: UIImage(systemName: "bookmark"), tag: 2)
        watchlistNavController.tabBarItem.selectedImage = UIImage(systemName: "bookmark.fill")

        // 4. Calendar
        let calendarNavController = NavigationController()
        let calendarCoordinator = CalendarCoordinator(navigationController: calendarNavController)
        childCoordinators.append(calendarCoordinator)
        calendarCoordinator.start()
        calendarNavController.tabBarItem = UITabBarItem(title: "Calendário", image: UIImage(systemName: "calendar"), tag: 3)
        calendarNavController.tabBarItem.selectedImage = UIImage(systemName: "calendar.badge.clock")

        // 5. Profile
        let profileNavController = NavigationController()
        let profileVC = ProfileViewController()
        profileNavController.setViewControllers([profileVC], animated: false)
        profileNavController.tabBarItem = UITabBarItem(title: "Perfil", image: UIImage(systemName: "person"), tag: 4)
        profileNavController.tabBarItem.selectedImage = UIImage(systemName: "person.fill")
        
        tabBarController.viewControllers = [
            homeNavController,
            exploreNavController,
            watchlistNavController,
            calendarNavController,
            profileNavController
        ]
        
        navigationController.setViewControllers([tabBarController], animated: true)
    }
}

extension AppCoordinator: AuthCoordinatorDelegate {
    func didLogIn(user: User) {
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        showMainTabBarFlow()
    }
    
    func didCompleteAuthFlow() {
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        showMainTabBarFlow()
    }
}

extension AppCoordinator: HomeCoordinatorDelegate {
    func didRequestLogout() {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        childCoordinators.removeAll()
        showAuthFlow()
    }
}
