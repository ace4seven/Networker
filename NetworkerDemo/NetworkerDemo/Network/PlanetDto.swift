//
//  PlanetDto.swift
//  NetworkerDemo
//
//  Created by Juraj Macák on 01/11/2022.
//

import Foundation

struct PlanetsDto: Decodable {

    let count: Int
    let next: String?
    let previous: String?
    let results: [Planet]
}

struct Planet: Decodable, Identifiable {
    let id = UUID()
    let name, rotationPeriod, orbitalPeriod, diameter: String
    let climate, gravity, terrain, surfaceWater: String
    let population: String
    let residents, films: [String]
    let created, edited: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case name
        case rotationPeriod = "rotation_period"
        case orbitalPeriod = "orbital_period"
        case diameter, climate, gravity, terrain
        case surfaceWater = "surface_water"
        case population, residents, films, created, edited, url
    }
}

