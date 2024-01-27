//
//  ContentView-ViewModel.swift
//  BucketList
//
//  Created by Kirill Baranov on 26/01/24.
//

import LocalAuthentication
import Foundation
import MapKit
import Observation

extension ContentView {
    
    @Observable
    class ViewModel {
        private(set) var locations: [Location]
        var selectedPlace: Location?
        var isUnlocked = false
        var isStandartMap = true
        var isAuthError = false
        
        let savePath = URL.documentsDirectory.appending(path: "SavedPlaces")
        
        init() {
            do {
                let data = try Data(contentsOf: savePath)
                locations = try JSONDecoder().decode([Location].self, from: data)
            } catch {
                print(error.localizedDescription)
                locations = []
            }
        }
        
        func addLocation(at coordinate: CLLocationCoordinate2D) {
            let newLocation = Location(id: UUID(), name: "New location", description: "", latitude: coordinate.latitude, longitude: coordinate.longitude)
            locations.append(newLocation)
            save()
        }
        
        func update(location: Location) {
            
            guard let selectedPlace else { return }
            
            if let index = locations.firstIndex(of: selectedPlace) {
                locations[index] = location
                save()
            }
        }
        
        func save() {
            do {
                let data = try JSONEncoder().encode(locations)
                try data.write(to: savePath, options: [.atomic, .completeFileProtection])
                
            } catch {
                print("Unable to save data.")
                print(error.localizedDescription)
            }
        }
        
        func authenticate() {
            let context = LAContext()
            var error: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = " "
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                    if success {
                        self.isUnlocked = true
                    } else {
                        self.isAuthError = true
                        print("auth error: \(String(describing: authenticationError))")
                    }
                }
            } else {
                print("no biometrics")
            }
        }
        
        func switchMapMode() {
            self.isStandartMap.toggle()
        }
    }
    
}
