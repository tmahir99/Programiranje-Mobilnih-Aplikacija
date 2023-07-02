//
//  MapWithUserLocation.swift
//  ProtectApp
//
//  Created by Mahir Tahirovic on 17.12.22..
//

import SwiftUI
import MapKit
struct MapWithUserLocation: View {
    @ObservedObject var locationManager: LocationManager
    @Binding var selectedLocation: Location?
    
    var region: Binding<MKCoordinateRegion>? {
        guard let location = locationManager.location else {
            return MKCoordinateRegion.goldenGateRegion().getBinding()
        }
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        
        return region.getBinding()
    }
    
    var body: some View {
        if let region = region {
            Map(coordinateRegion: region, interactionModes: .all, showsUserLocation: true, userTrackingMode: .constant(.follow))
                .ignoresSafeArea()
        }
    }
}

