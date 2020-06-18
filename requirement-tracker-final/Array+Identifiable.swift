//
//  Array+Identifiable.swift
//  req-tracker
//
//  Created by Mehul Arora on 5/31/20.
//  Copyright © 2020 Mehul Arora. All rights reserved.
//

import Foundation

// Extensions to find unique elements in Arrays based on unique properties of classes

// Generic extension
extension Array where Element: Identifiable {
    func firstIndex(matching: Element) -> Int? {
        for i in 0 ..< self.count {
            if self[i].id == matching.id {
                return i
            }
        }
        return nil
    }
}

// Extension for Class entity
extension Array where Element == TakenClass {
    func firstIndex(matching: Element) -> Int? {
        for i in 0 ..< self.count {
            if self[i].id == matching.id {
                return i
            }
        }
        return nil
    }
}

// Extension for Requirement entity
extension Array where Element == Requirement {
    func firstIndex(matching: Element) -> Int? {
        for i in 0 ..< self.count {
            if self[i].name == matching.name {
                return i
            }
        }
        return nil
    }
}
