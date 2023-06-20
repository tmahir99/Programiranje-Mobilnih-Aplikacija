//
//  MKCoordinateRegion.swift
//  ProtectApp
//
//  Created by Mahir Tahirovic on 17.12.22..
//

import UIKit
import SwiftUI
import Foundation
import CoreLocation
class MKCoordinateRegion: NSObject {

}
extension MKCoordinateRegion {
    
    static func goldenGateRegion() -> MKCoordinateRegion {
        MKCoordinateRegion(
            center centerCoordinate: CLLocationCoordinate2D,
            latitudinalMeters: CLLocationDistance,
            longitudinalMeters: CLLocationDistance
        )
    }
    
    func getBinding() -> Binding<MKCoordinateRegion>? {
        return Binding<MKCoordinateRegion>(.constant(self))
    }
}
