//
//  CountryCardView.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/25/25.
//

import SwiftUI

struct CountryCardView: View {
    let country: Country
    let isSaved: Bool
    var onTap: () -> Void
    var onSave: () -> Void
    var onRemove: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(country.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                SVGWebView(urlString: country.flag)
                    .frame(width: 80, height: 80)
                    .aspectRatio(contentMode: .fit)
            }
            .padding(.bottom, 4)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                    
                    Text("Capital: \(country.capital ?? "Unknown")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let currencies = country.currencies, !currencies.isEmpty {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.green)
                        
                        Text("Currency: \(currencies[0].name)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            HStack {
                Spacer()
                
                Button(action: {
                    isSaved ? onRemove() : onSave()
                }) {
                    Image(systemName: isSaved ? "minus.circle.fill" : "plus.circle.fill")
                        .foregroundColor(isSaved ? .red : .blue)
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .onTapGesture {
            onTap()
        }
    }
}
