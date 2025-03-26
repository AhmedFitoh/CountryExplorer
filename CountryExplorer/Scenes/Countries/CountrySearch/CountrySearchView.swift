//
//  CountrySearchView.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/26/25.
//

import SwiftUI

struct CountrySearchView: View {
    @ObservedObject var viewModel: CountryListViewModel
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var onSelectCountry: (Country) -> Void
    
    var body: some View {
        VStack {
            TextField("Search for a country", text: $viewModel.searchQuery)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
            
            if viewModel.isLoading {
                LoadingView()
            } else if viewModel.searchResults.isEmpty && !viewModel.searchQuery.isEmpty {
                Text("No results found")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                List {
                    ForEach(viewModel.searchResults) { country in
                        CountryCardView(
                            country: country,
                            isSaved: viewModel.isCountrySaved(country),
                            onTap: {
                                onSelectCountry(country)
                            },
                            onSave: {
                                viewModel.saveCountry(country)
                            },
                            onRemove: {
                                viewModel.removeCountry(country)
                            }
                        )
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Search Countries")
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .onChange(of: viewModel.errorMessage) { oldValue, newValue in
            if let error = newValue {
                alertMessage = error
                showingAlert = true
                viewModel.errorMessage = nil
            }
        }
    }
}
