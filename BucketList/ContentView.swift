//
//  ContentView.swift
//  BucketList
//
//  Created by Andres Marquez on 2021-08-04.
//

import SwiftUI
import LocalAuthentication
import MapKit

struct ContentView: View {
    //checks if phone is unlocked
    @State private var isUnlocked = false
    //shows alert if authentication failed
    @State private var unlockFail = false
    @State private var unlockFailMessage = ""
    
    @State private var centerCoordinate = CLLocationCoordinate2D()
    @State private var locations = [CodableMKPointAnnotation]()
    @State private var selectedPlace: MKPointAnnotation?
    @State private var showingPlaceDetails = false
    @State private var showingEditScreen = false
    
    var body: some View {
        ZStack {
            ZStack {}
                .alert(isPresented: $showingPlaceDetails) {
                    Alert(title: Text(selectedPlace?.title ?? "Unknown"), message: Text(selectedPlace?.subtitle ?? "Missing place information."), primaryButton: .default(Text("OK")), secondaryButton: .default(Text("Edit")) {
                            self.showingEditScreen = true
                    })
                }
            ZStack {
                let selectedPlaceBinding = Binding(
                    get: { selectedPlace },
                    set: {
                        selectedPlace = $0
                    })
                if isUnlocked {
                    LocationView(centerCoordinate: $centerCoordinate, locations: $locations, selectedPlace: selectedPlaceBinding, showingPlaceDetails: $showingPlaceDetails, showingEditScreen: $showingEditScreen)
                } else {
                    Button("Unlock Places") {
                        self.authenticate()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
            }
            .alert(isPresented: $unlockFail) {
                Alert(title: Text("Failed to authenticate"), message: Text(unlockFailMessage), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showingEditScreen, onDismiss: saveData) {
                if self.selectedPlace != nil {
                    EditView(placemark: self.selectedPlace!)
                }
            }
            .onAppear(perform: loadData)
        }
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "Please authenticate yourself to unlock your places."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                // authentication has now completed
                DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                    } else {
                        // there was a problem
                        self.unlockFailMessage = "We could not verify your identity"
                        self.unlockFail = true
                    }
                }
            }
        } else {
            // no biometrics
            self.unlockFailMessage = "Biometrics are not available on your device"
            self.unlockFail = true
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func loadData() {
        let filename = getDocumentsDirectory().appendingPathComponent("SavedPlaces")

        do {
            let data = try Data(contentsOf: filename)
            locations = try JSONDecoder().decode([CodableMKPointAnnotation].self, from: data)
        } catch {
            print("Unable to load saved data.")
        }
    }
    
    func saveData() {
        do {
            let filename = getDocumentsDirectory().appendingPathComponent("SavedPlaces")
            let data = try JSONEncoder().encode(self.locations)
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
            print("Data saved")
        } catch {
            print("Unabled to save data")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
