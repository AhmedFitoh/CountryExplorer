//
//  CountryListView.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/25/25.
//

import SwiftUI

struct CountryListView: View {
    @ObservedObject var viewModel: CountryListViewModel
    let coordinator: AppCoordinator
    @State private var isSearchPresented = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            VStack {
                if viewModel.savedCountries.isEmpty {
                    emptyStateView
                } else {
                    countriesList
                }
                
                addButton
            }
            
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .navigationTitle("My Countries")
        .onAppear {
            Task {
                await viewModel.loadInitialData()
            }
        }
        .sheet(isPresented: $isSearchPresented) {
            NavigationView {
                CountrySearchView(viewModel: viewModel) { country in
                    isSearchPresented = false
                    coordinator.showCountryDetail(country: country)
                }
                .navigationTitle("Find a Country")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            isSearchPresented = false
                        }
                    }
                }
            }
        }
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
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("No Countries Added")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Add a country to see its details")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var countriesList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.savedCountries) { country in
                    CountryCardView(
                        country: country,
                        isSaved: true,
                        onTap: {
                            viewModel.didSelectCountry(country)
                        },
                        onSave: { },
                        onRemove: {
                            viewModel.removeCountry(country)
                        }
                    )
                }
            }
            .padding()
        }
    }
    
    private var addButton: some View {
        Button(action: {
            if viewModel.savedCountries.count >= StorageConstants.maxSavedCountries {
                alertMessage = "You can only save up to \(StorageConstants.maxSavedCountries) countries."
                showingAlert = true
            } else {
                isSearchPresented = true
            }
        }) {
            HStack {
                Image(systemName: "plus")
                Text("Add Country")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}
