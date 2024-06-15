//
//  Station.swift
//  NearbyStationInJapan
//
//  Created by aicccux on 6/15/24.
//

import Foundation

struct StationResponse: Codable {
    let response: StationCollection
}

struct StationCollection: Codable {
    let station: [Station]
}

struct Station: Codable, Identifiable {
    var id: UUID = UUID()
    let name: String
    let prefecture: String
    let line: String
    let x: Double
    let y: Double
    let postal: String
    let distance: String
    let prev: String?
    let next: String?
    private enum CodingKeys: String, CodingKey {
            case name, prefecture, line, x, y, postal, distance, prev, next
        }
}
