//
//  CountryDetailView.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/26/25.
//

import SwiftUI

struct CountryDetailView: View {
    @ObservedObject var viewModel: CountryDetailViewModel
    var onDismiss: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                
                Divider()
                
                infoSection
                
                Divider()
                
                actionSection
            }
            .padding()
        }
        .navigationTitle(viewModel.country.name)
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var headerSection: some View {
        HStack(alignment: .center) {

            SVGWebView(urlString: viewModel.country.flag)
                .frame(width: 80, height: 80)
                .aspectRatio(contentMode: .fit)
            
                Text("Country Code: \(viewModel.country.alpha2Code)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            infoRow(icon: "mappin.circle.fill", title: "Capital", value: viewModel.capital)
            
            infoRow(icon: "dollarsign.circle.fill", title: "Currency", value: viewModel.formattedCurrencies)
        }
    }
    
    private var actionSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                viewModel.toggleSaved()
            }) {
                HStack {
                    Image(systemName: viewModel.isSaved ? "minus.circle.fill" : "plus.circle.fill")
                    Text(viewModel.isSaved ? "Remove from Saved" : "Add to Saved")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(viewModel.isSaved ? Color.red : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
    
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(value)
                    .foregroundColor(.secondary)
            }
        }
    }
}
