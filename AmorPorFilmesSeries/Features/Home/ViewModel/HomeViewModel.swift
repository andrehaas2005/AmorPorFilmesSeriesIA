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
            ("The Last of Us", "T1:E5 • 12m restantes", 0.8, "https://lh3.googleusercontent.com/aida-public/AB6AXuCV4hqWZOkKY-zjvmVHva9Sp3NK98DA8V7Yu-lnd-DFCFcN-l1pVmmGT6sO4l5H2dS72X1W25SeyXlsSxUVavNxup6eMJAPeFPeZXrKJDWMV2lVRuqrb6VAdUj53Zm5fATnLGjKwlfnkKnQMRQyQNO6K-IQOzAyUtK1ey6ZhPG44Cm1l3T2iYrVBrXGhrmIOBStfTfPi9U7-dvkilj-bbrCUUiFxjqCAXFpizk7SKNZCWDcWdpEs57aczCVHvJ5k1Y5biFDfAbug4w"),
            ("Breaking Bad", "T3:E10 • 32m restantes", 0.45, "https://lh3.googleusercontent.com/aida-public/AB6AXuCMAUNo72NvhpEdqi1xxUVCLWrfx8L4felCvpr0h_iufgAlJl9hE-LTMKDjzGFo9YiJFxyQj03iLuVAVF7hQfGnVxWbdsVX4l5swolWXu50-hdT3BlAZx45gozbVTr0I-atxk6uXylOD-t_KC8m4V9Q359RJt5yednN67_jFF4Rdjy0IRKx8Jf4ma2akiaSID99gHMlFg7eNouy0pWgsMfWXfzJxPM5QP1Y78m0e1JhKH3VjpitSebCL-A6Xj1htgQSC4tGOmKc2yc")
        ]

        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        movieService.fetchNowPlayingMovies { [weak self] result in
            defer { dispatchGroup.leave() }
            switch result {
            case .success(let movies):
                DispatchQueue.main.async {
                    self?.items.value = movies
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.errorMessage.value = "Erro ao carregar: \(error.localizedDescription)"
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
