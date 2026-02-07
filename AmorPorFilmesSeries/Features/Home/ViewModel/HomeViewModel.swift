//
//  HomeViewModel.swift
//  AmorPorFilmesSeries
//

import Foundation
import ModuloServiceMovie

public class HomeViewModel: ViewModelProtocol {
    typealias DataType = Movie
    internal var movieService: (any MovieServiceProtocol)!
    
    var isLoading: Observable<Bool> = Observable<Bool>(false)
    var items: Observable<[Movie]> = Observable<[Movie]>()
    var errorMessage: Observable<String?> = Observable<String?>()
    weak var coordinator: HomeCoordinator?
    
    // Additional data for enhanced Home Screen
    var continueWatching: Observable<[(title: String, info: String, progress: Float, image: String)]> = Observable([])

    init(movieService: MovieServiceProtocol) {
        self.movieService = movieService
    }
    
    func fetchData() {
        isLoading.value = true
        errorMessage.value = nil

        // Mock continue watching data
        continueWatching.value = [
            ("The Last of Us", "T1:E5 • 12m restantes", 0.8, "https://sl1nk.com/yLc9O"),
            ("Breaking Bad", "T3:E10 • 32m restantes", 0.45, "https://sl1nk.com/BZgZl")
        ]

        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
      movieService.fetchNowPlayingMovies { [weak self] result in
        defer { dispatchGroup.leave() }
        guard let self = self else {return}
        switch result {
          case .success(let movies):
          DispatchQueue.main.async {
            self.items.value = movies
          }
        case .failure(let error):
          DispatchQueue.main.async {
            self.errorMessage.value = "Erro ao carregar: \(error.localizedDescription)"
          }
        }
      }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.isLoading.value = false
        }
    }
    
    func didSelectMovie(_ movie: Movie) {
        coordinator?.showMovieDetails(movie)
    }
}
