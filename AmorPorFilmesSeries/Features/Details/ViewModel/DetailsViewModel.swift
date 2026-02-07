//
//  DetailsViewModel.swift
//  AmorPorFilmesSeries
//

import Foundation
import UIKit

class DetailsViewModel {
    let detailType: DetailType
    let title = Observable<String?>(nil)
    let description = Observable<String?>(nil)
    let imageUrl = Observable<URL?>(nil)

    // Mock data for UI components
    let providers = Observable<[(name: String, color: String)]>([])
    let cast = Observable<[String]>([])
    let episodes = Observable<[(code: String, title: String, desc: String)]>([])
    let rating = Observable<Double>(4.0)

    weak var coordinator: DetailsCoordinator?

    init(detailType: DetailType) {
        self.detailType = detailType
        setupDetails(for: detailType)
        setupMockContent()
    }

    private func setupDetails(for type: DetailType) {
        switch type {
        case .movie(let movie):
            title.value = movie.title
            description.value = movie.overview
            imageUrl.value = URL(string: Configuration.imageBaseURL + movie.posterPath)
        case .serie(let serie):
            title.value = serie.name
            description.value = serie.overview
            imageUrl.value =  URL(string: serie.posterPath)
        case .actor(let actor):
            title.value = actor.name
            description.value = "Informações detalhadas sobre o ator."
            imageUrl.value = actor.name.isEmpty ? nil : URL(string: "https://image.tmdb.org/t/p/w500/\(actor.profilePath)")
        }
    }

    private func setupMockContent() {
        providers.value = [
            ("Netflix", "#E50914"),
            ("Max", "#002be7"),
            ("Prime Video", "#00052d"),
            ("Apple TV", "#f5f5f7")
        ]

        cast.value = [
            "Timothée Chalamet",
            "Zendaya",
            "Rebecca Ferguson",
            "Josh Brolin",
            "Austin Butler"
        ]

        episodes.value = [
            ("E01", "O Horizonte de Eventos", "A tripulação descobre os primeiros sinais de vida no planeta Miller."),
            ("E02", "Congelamento Profundo", "Uma tempestade inesperada coloca em risco a base principal de exploração.")
        ]
    }
}
