//
//  ContentView.swift
//  NearbyStationInJapan
//
//  Created by aicccux on 6/15/24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @StateObject var fetcher = StationFetcher()
    @StateObject var locationManager = LocationManager()
    @State var showRoute: MKRoute?
    @State var transportType: MKDirectionsTransportType?
    @State var vehicle = 0
    let ways: [MKDirectionsTransportType] = [.any, .automobile, .walking, .transit]
    
    var longitude: Double { return locationManager.currentLocation?.coordinate.longitude ?? 0.00 }
    var latitude: Double { return locationManager.currentLocation?.coordinate.latitude ?? 0.00 }
    
    var body: some View {
        NavigationStack {
            List(fetcher.stationList) { station in
                NavigationLink(
                    destination: {
                        Map() {
                            UserAnnotation()
                            Marker("\(station.name)\nPreview Station: \(station.prev ?? "none")\nNext Station: \(station.next ?? "none")\nDistance: \(station.distance)\nTram Line: \(station.line)", systemImage: "tram.circle", coordinate: CLLocationCoordinate2D(latitude: station.y, longitude: station.x))
                            if let showRoute = locationManager.route?.polyline{
                                MapPolyline(showRoute).stroke(.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round, dash: [0.5, 10]))
                            }
                        }.mapControls {
                            MapUserLocationButton().mapControlVisibility(.visible)
                            MapPitchToggle()
                            MapCompass()
                            MapScaleView().mapControlVisibility(.hidden)
                        }.onAppear {
                            let way = ways[vehicle]
                            switch way {
                            case .walking:
                                transportType = .walking
                            case .automobile:
                                transportType = .automobile
                            case .transit:
                                transportType = .transit
                            default:
                                transportType = .any
                            }
                            locationManager.getRoute(from: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), to: CLLocationCoordinate2D(latitude: station.y, longitude: station.x), transportType: transportType ?? .any)
                        }
                    }
                ){
                    HStack {
                        Text(station.prefecture)
                        Text(station.name)
                        Text(station.line)
                    }
                }
            }
            .task { try? await fetcher.fetchData(longitude: longitude, latitude: latitude) }
            .navigationTitle("Nearby Stations")
            HStack{
                Text("Choose Transport Type")
                Spacer()
                Picker(selection: $vehicle, label: Text("Transport Type")){
                    Text("Any").tag(0)
                    Text("Walking").tag(1)
                    Text("Autombile").tag(2)
                    Text("Transit").tag(3)
                }
            }.padding(.horizontal)
            Button(
                action: { Task {
                    try? await fetcher.fetchData(longitude: longitude, latitude: latitude)
                } }
            ) {
                Label("Update Location", systemImage: "arrow.clockwise")
            }.padding()
        }.navigationViewStyle(.stack)
    }
}

#Preview {
    ContentView()
}
