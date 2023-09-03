//
//  UserModel.swift
//  ProtectApp
//
//  Created by Mahir Tahirovic on 23.12.22..

import Foundation
struct UserModel: Identifiable{
    var id: ObjectIdentifier
    var locations: [Double]
    var name: String
    var LastName: String
    var protector: String
    var alram: TimeInterval;
}
