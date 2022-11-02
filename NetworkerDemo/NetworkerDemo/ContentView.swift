//
//  ContentView.swift
//  NetworkerDemo
//
//  Created by Juraj Macák on 01/11/2022.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 12) {
                switch viewModel.result {
                case .created:
                    EmptyView()

                case .loading:
                    ProgressView()

                case .error(let error):
                    Text(error.localizedDescription)

                case .loaded(let data):
                    List {
                        ForEach(Array(data.results.enumerated()), id: \.offset) {index, planet in
                            NavigationLink {
                                VStack {
                                    if let result = viewModel.planet {
                                        switch result {
                                        case .success(let planetDetail):
                                            planetDetailView(planet: planetDetail)

                                        case .failure(let failure):
                                            Text(failure.localizedDescription)
                                        }
                                    } else {
                                        ProgressView()
                                    }
                                }
                                .onAppear {
                                    viewModel.fetchPlanet(page: index + 1)
                                }
                            } label: {
                                Text(planet.name)
                            }

                        }
                    }
                }
            }
            .navigationTitle("Planets")
        }
    }

    private func planetDetailView(planet: Planet) -> some View {
        VStack {
            List {
                LabeledContent("Name", value: planet.name)
                LabeledContent("Climate", value: planet.climate)
                LabeledContent("Diameter", value: planet.diameter)
                LabeledContent("Gravity", value: planet.gravity)
                LabeledContent("Orbital period", value: planet.orbitalPeriod)
                LabeledContent("Population", value: planet.population)
                LabeledContent("Rotation Period", value: planet.rotationPeriod)
                LabeledContent("Terain", value: planet.terrain)
                LabeledContent("Surface water", value: planet.surfaceWater)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
