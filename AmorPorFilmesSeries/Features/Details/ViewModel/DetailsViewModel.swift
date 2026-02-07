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
    let trailerImageUrl = Observable<URL?>(nil)
    let metadata = Observable<String?>(nil)

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
            // Example metadata: "2024 • 2h 46m • Ficção Científica, Ação"
            let year = movie.releaseDate.prefix(4)
            metadata.value = "\(year) • 2h 46m • Ficção Científica, Ação"
        case .serie(let serie):
            title.value = serie.name
            description.value = serie.overview
            imageUrl.value =  URL(string: serie.posterPath)
            metadata.value = "2023 • 2 Temporadas • Drama, Sci-Fi"
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

        trailerImageUrl.value = URL(string: "https://lh3.googleusercontent.com/aida-public/AB6AXuBnBaxDyoX1oK0kxhytkLlnFvPdbjlJ-n5FTSyvPmS008l79noVA3HLj9tIhgkywUbjlXtHd7WJlq20nVzCw-loY-5REaW8PW0IVf3PSnr-4w4D0kRTt_rJF5tPBh7G9tUKfiD9YLq5TE6DiF0X2chFaZYa8lIP9kbt68TDeug7fNgR6aQ0jg5hJ9IWi1sCswwOhVAiH1OGdsv9qdIinbLf0G9Vx-95sHyDAeLTkurJYLYXTkS_KaisWtCQ6Wr8IZr5Ke45MUIbbzE")

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
