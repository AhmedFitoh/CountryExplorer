//
//  CoreDataStack.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/26/25.
//

import CoreData
import Combine

final class CoreDataStack {
    static let shared = CoreDataStack()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CountryExplorer")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                print("CoreData save error: \(error), \(error.userInfo)")
            }
        }
    }
    
    // Create a background context for importing data
    func backgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
}


// MARK: - Cache All Countries for Offline Use

extension APIService {
    // Add this method to cache all countries
    func cacheAllCountries() async {
        do {
            let countries = try await fetchAllCountries()
            await cacheCountries(countries)
        } catch {
            print("Failed to cache countries: \(error)")
        }
    }
    
    private func cacheCountries(_ countries: [Country]) async {
        let context = CoreDataStack.shared.backgroundContext()
        
        await context.perform {
            // Clear existing cached countries (optional, depends on your strategy)
            self.clearExistingCache(in: context)
            
            // Save new countries
            for country in countries {
                let countryEntity = CountryEntity(context: context)
                countryEntity.name = country.name
                countryEntity.capital = country.capital
                countryEntity.alpha2Code = country.alpha2Code
                countryEntity.alpha3Code = country.alpha3Code
                countryEntity.flag = country.flag
                
                // Cache is true to distinguish from user saved countries
                countryEntity.isCache = true
                
                // Save currencies
                if let currencies = country.currencies {
                    for currency in currencies {
                        let currencyEntity = CurrencyEntity(context: context)
                        currencyEntity.code = currency.code
                        currencyEntity.name = currency.name
                        currencyEntity.symbol = currency.symbol
                        currencyEntity.country = countryEntity
                    }
                }
            }
            
            // Save context
            do {
                try context.save()
                print("Successfully cached \(countries.count) countries")
            } catch {
                print("Failed to save context with cached countries: \(error)")
            }
        }
    }
    
    private func clearExistingCache(in context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isCache == YES")
        
        do {
            let cachedEntities = try context.fetch(fetchRequest)
            for entity in cachedEntities {
                context.delete(entity)
            }
        } catch {
            print("Failed to clear existing cache: \(error)")
        }
    }
    
    func fetchAllCountriesWithCacheFallback() async throws -> [Country] {
        do {
            // Try fetching online
            let countries = try await fetchAllCountries()
            
            // Cache the results for next time
            Task {
                await cacheCountries(countries)
            }
            
            return countries
        } catch {
            print("Online fetch failed, trying cache: \(error)")
            
            // Fetch from cache if online fetch fails
            return try await fetchCountriesFromCache()
        }
    }
    
    private func fetchCountriesFromCache() async throws -> [Country] {
        return try await withCheckedThrowingContinuation { continuation in
            let context = CoreDataStack.shared.viewContext
            let fetchRequest: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "isCache == YES")
            
            do {
                let countryEntities = try context.fetch(fetchRequest)
                
                if countryEntities.isEmpty {
                    continuation.resume(throwing: APIError.noData)
                    return
                }
                
                let countries = countryEntities.map { entity -> Country in
                    let currencies = entity.currencies?.compactMap { currencyEntity -> Currency? in
                        guard let currencyEntity = currencyEntity as? CurrencyEntity,
                              let code = currencyEntity.code,
                              let name = currencyEntity.name else {
                            return nil
                        }
                        
                        return Currency(code: code, name: name, symbol: currencyEntity.symbol)
                    }
                    
                    return Country(
                        name: entity.name ?? "",
                        capital: entity.capital,
                        currencies: currencies,
                        flag: entity.flag ?? "",
                        alpha2Code: entity.alpha2Code ?? "",
                        alpha3Code: entity.alpha3Code ?? ""
                    )
                }
                
                continuation.resume(returning: countries)
            } catch {
                continuation.resume(throwing: APIError.decodingError)
            }
        }
    }
}
