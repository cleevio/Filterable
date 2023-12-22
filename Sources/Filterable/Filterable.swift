/// A protocol representing a type that can be used as a filter.
public protocol FilterType: Equatable {
    /// A boolean value indicating whether the filter type is distinct (only one filter can be applied at a time).
    static var isDistinctFilterType: Bool { get }
}

extension FilterType {
    static var isDistinctFilterType: Bool { true }
}

extension Collection where Element: Filterable, Element.Filter == String {
    public func filter(with filter: String) -> [Self.Element] {
        let searchComponents = filter
            .components(separatedBy: " ")
            .filter { !$0.isEmpty }

        guard !searchComponents.isEmpty else { return Array(self) }

        return self.filter {
            searchComponents.allSatisfy($0.filter(with:))
        }
    }
}

/// A protocol representing a filterable object.
public protocol Filterable {
    associatedtype Filter

    /// Filters the object using the provided filter.
    /// - Parameter filter: The filter to apply.
    /// - Returns: A boolean value indicating whether the object passes the filter.
    func filter(with filter: Filter) -> Bool
}

/// Default implementation for filtering with multiple filters.
extension Filterable where Filter: FilterType {
    /// Filters the object using the provided collection of filters.
    /// - Parameter filters: The collection of filters to apply.
    /// - Returns: A boolean value indicating whether the object passes all the filters.
    public func filter(with filters: some Collection<Filter>) -> Bool {
        filters.allSatisfy(filter(with:))
    }
}

extension Collection where Element: Filterable, Element.Filter: FilterType {
    /// Filters the collection using the provided collection of filters.
    /// - Parameter filters: The collection of filters to apply.
    /// - Returns: An array containing the elements that pass all the filters.
    public func filter(with filters: some Collection<Element.Filter>) -> [Self.Element] {
        filter { $0.filter(with: filters) }
    }
}

extension Set where Element: FilterType {
    /// Selects the specified filter for the set.
    /// - Parameter filter: The filter to select.
    public mutating func selectFilter(_ filter: Element) {
        switch (contains(filter), Element.isDistinctFilterType) {
        case (true, true):
            removeAll()
        case (true, false):
            remove(filter)
        case (false, true):
            self = [filter]
        case (false, false):
            insert(filter)
        }
    }
}
