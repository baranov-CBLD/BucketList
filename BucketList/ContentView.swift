//
//  ContentView.swift
//  BucketList
//
//  Created by Kirill Baranov on 23/01/24.
//

import LocalAuthentication
import MapKit
import SwiftUI

struct ContentView: View {
    
    @State private var viewModel = ViewModel()
    
    let startPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 56, longitude: -3),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
    )
    
    var body: some View {
        
        VStack {
            if viewModel.isUnlocked {
                
                ZStack {
                    
                    MapReader { proxy in
                        Map(initialPosition: startPosition) {
                            ForEach(viewModel.locations) { location in
                                Annotation(location.name, coordinate: location.coordinate) {
                                    Image(systemName: "star.circle")
                                        .resizable()
                                        .foregroundStyle(.red)
                                        .frame(width: 44, height: 44)
                                        .background(.white)
                                        .clipShape(.circle)
                                        .onLongPressGesture {
                                            viewModel.selectedPlace = location
                                        }
                                }
                            }
                        }
                        .mapStyle(viewModel.isStandartMap ? .standard : .hybrid)
                        .onTapGesture { position in
                            if let coordinate = proxy.convert(position, from: .local) {
                                viewModel.addLocation(at: coordinate)
                            }
                        }
                        .sheet(item: $viewModel.selectedPlace) { place in
                            EditView(location: place) {
                                viewModel.update(location: $0)
                            }
                        }
                    }
                    
                    VStack {
                        Button("Switch to \(viewModel.isStandartMap ? "hybrid" : "standard") mode", action: viewModel.switchMapMode)
                            .padding()
                            .background(.thinMaterial)
                            .clipShape(.capsule)
                        Spacer()
                    }
                }
                
            } else {
                Button("Unlock Places", action: viewModel.authenticate)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(.capsule)
            }
        }
        .alert("Auth error", isPresented: $viewModel.isAuthError) {
            Button("Ok") {
                
            }
        }
        
    }
}

#Preview {
    ContentView()
}
