//
//  CoreDataStorageService.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/26/25.
//

import CoreData

final class CoreDataStorageService: StorageServiceProtocol {
    @Published private var savedCountries: [Country] = []
    
    var savedCountriesPublisher: Published<[Country]>.Publisher { $savedCountries }
    
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
        loadCountriesFromCoreData()
    }
    
    func saveCountry(_ country: Country) throws {
        // Check if country already exists
        if isCountrySaved(country) {
            throw StorageError.countryAlreadyExists
        }
        
        // Check if limit reached
        if savedCountries.count >= StorageConstants.maxSavedCountries {
            throw StorageError.countryLimitReached
        }
        
        // Save to Core Data
        let context = coreDataStack.viewContext
        
        // Create new CountryEntity
        let countryEntity = CountryEntity(context: context)
        countryEntity.name = country.name
        countryEntity.capital = country.capital
        countryEntity.alpha2Code = country.alpha2Code
        countryEntity.alpha3Code = country.alpha3Code
        countryEntity.flag = country.flag
        
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
        
        // Save context
        do {
            try context.save()
            loadCountriesFromCoreData() // Reload to update the published property
        } catch {
            throw StorageError.saveFailed
        }
    }
    
    func loadSavedCountries() -> [Country] {
        return savedCountries
    }
    
    func removeCountry(_ country: Country) {
        let context = coreDataStack.viewContext
        let fetchRequest: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "alpha3Code == %@", country.alpha3Code)
        
        do {
            let results = try context.fetch(fetchRequest)
            for entity in results {
                context.delete(entity)
            }
            
            try context.save()
            loadCountriesFromCoreData() // Reload to update the published property
        } catch {
            print("Error removing country: \(error)")
        }
    }
    
    func isCountrySaved(_ country: Country) -> Bool {
        return savedCountries.contains(where: { $0.alpha3Code == country.alpha3Code })
    }
    
    // MARK: - Private Helper Methods
    
    private func loadCountriesFromCoreData() {
        let context = coreDataStack.viewContext
        let fetchRequest: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
        
        do {
            let countryEntities = try context.fetch(fetchRequest)
            savedCountries = countryEntities.map { entity in
                convertEntityToModel(entity)
            }
        } catch {
            print("Error loading countries from CoreData: \(error)")
            savedCountries = []
        }
    }
    
    private func convertEntityToModel(_ entity: CountryEntity) -> Country {
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
}
