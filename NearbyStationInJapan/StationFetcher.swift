//
//  StationFetcher.swift
//  NearbyStationInJapan
//
//  Created by aicccux on 6/15/24.
//

import Foundation

class StationFetcher: ObservableObject {
    @Published var stationList: [Station] = []
    
    func fetchData(longitude: Double, latitude: Double) async
    throws {
        guard let url = URL(string: "https://express.heartrails.com/api/json?method=getStations&x=\(longitude)&y=\(latitude)") else { throw FtetchError.badJSON }
        
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FtetchError.badRequest }
        
        Task { @MainActor in
            stationList = try JSONDecoder().decode(StationResponse.self, from: data).response.station
        }
    }
}

enum FtetchError: Error {
    case badRequest
    case badJSON
}
