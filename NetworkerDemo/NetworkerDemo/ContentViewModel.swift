//
//  ContentViewModel.swift
//  NetworkerDemo
//
//  Created by Juraj Macák on 01/11/2022.
//

import SwiftUI
import Networker
import Combine
import Alamofire

final class ContentViewModel: ObservableObject {

    private let networker: Networker<Endpoint>
    private var cancellables = Set<AnyCancellable>()

    @Published var result: ApiResult<PlanetsDto, Error> = .created
    @Published var planet: Result<Planet, Error>? = nil

    init() {
        networker = Networker(
            configuration: .default
        )

        fetchPlanets()
    }

    func fetchPlanets() {
        getPlantets()
            .assign(to: &$result)
    }

    @MainActor
    func fetchPlanet(page: Int) {
        planet = nil

        Task { [weak self] in
            self?.planet = await getPlanet(page: page)
        }
    }
}

extension ContentViewModel {

    private func getPlantets() -> AnyPublisher<ApiResult<PlanetsDto, Error>, Never> {
        networker
            .call(endpoint: .swapiPlanets)
            .mapToApiResult()
    }

    private func getPlanet(page: Int) async -> Result<Planet, Error> {
        await networker
            .call(endpoint: .planetDetail(page: page))
    }
}
