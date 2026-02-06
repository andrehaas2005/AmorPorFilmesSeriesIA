//
//  WatchlistViewModel.swift
//  AmorPorFilmesSeries
//

import Foundation
import ModuloServiceMovie

public class WatchlistViewModel {
    
    var items: Observable<[(title: String, rating: String, image: String?)]> = Observable([])
    var isLoading = Observable<Bool>(false)
    var errorMessage = Observable<String?>(nil)
    
    weak var coordinator: WatchlistCoordinator?
    
    init(coordinator: WatchlistCoordinator) {
        self.coordinator = coordinator
        fetchData()
    }
    
    func fetchData() {
        // Mock data
        items.value = [
            ("Interestelar", "9.5", nil),
            ("O Poderoso Chefão", "8.8", nil),
            ("Spider-Man", "9.2", nil),
            ("Pulp Fiction", "8.0", nil),
            ("Blade Runner 2049", "9.0", nil),
            ("Breaking Bad", "9.8", nil)
        ]
    }
    
    func didSelectMovie(at index: Int) {
        // Handle selection
    }
}
