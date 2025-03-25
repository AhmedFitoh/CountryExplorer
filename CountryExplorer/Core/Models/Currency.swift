//
//  Currency.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/25/25.
//

import Foundation

struct Currency: Codable, Equatable, Identifiable {
    var id: String { code }
    let code: String
    let name: String
    let symbol: String?
}
