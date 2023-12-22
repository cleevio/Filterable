//
//  Searchable.swift
//
//
//  Created by Lukáš Valenta on 11.12.2023.
//

import Foundation

public protocol FilterableByKeypaths: Filterable {
    var searchKeyPaths: [KeyPath<Self, Filter>] { get }
}

extension FilterableByKeypaths where Filter == String {
    func filter(with filter: Filter) -> Bool {
        searchKeyPaths.firstIndex(where: {
            self[keyPath: $0].localizedStandardContains(filter)
        }) == nil
    }
}
