//
//  Country.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/25/25.
//

import Foundation

struct Country: Identifiable, Codable, Equatable {
    let id = UUID()
    let name: String
    let capital: String?
    let currencies: [Currency]?
    let flag: String
    let alpha2Code: String
    let alpha3Code: String
    var isCache: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case name, capital, currencies, flag, alpha2Code, alpha3Code
    }
    
    static func == (lhs: Country, rhs: Country) -> Bool {
        return lhs.alpha3Code == rhs.alpha3Code
    }
}
