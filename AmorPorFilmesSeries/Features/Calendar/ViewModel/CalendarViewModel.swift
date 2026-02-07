//
//  CalendarViewModel.swift
//  AmorPorFilmesSeries
//

import Foundation

class CalendarViewModel {
    weak var coordinator: CalendarCoordinator?

    var dates: Observable<[(day: String, date: String, isSelected: Bool)]> = Observable([])
    var releases: Observable<[(title: String, episode: String, time: String, isFirst: Bool)]> = Observable([])

    init(coordinator: CalendarCoordinator) {
        self.coordinator = coordinator
        fetchData()
    }

    func fetchData() {
        dates.value = [
            ("SEG", "12", false),
            ("TER", "13", false),
            ("QUA", "14", true),
            ("QUI", "15", false),
            ("SEX", "16", false),
            ("SÁB", "17", false),
            ("DOM", "18", false)
        ]

        releases.value = [
            ("The Bear", "Temporada 3 • Ep. 01", "09:00", true),
            ("The Boys", "Temporada 4 • Ep. 05", "21:00", false),
            ("House of the Dragon", "Temporada 2 • Ep. 02", "22:00", false)
        ]
    }
}
