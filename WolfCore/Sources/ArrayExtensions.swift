//
//  ArrayExtensions.swift
//  WolfCore
//
//  Created by Robert McNally on 7/5/15.
//  Copyright © 2015 Arciem LLC. All rights reserved.
//

import Foundation

extension Array {
    public func circularIndex(at index: Int) -> Int {
        return WolfCore.circularIndex(at: index, count: count)
    }

    public func element(atCircularIndex index: Int) -> Element {
        return self[circularIndex(at: index)]
    }

    public mutating func replaceElement(atCircularIndex index: Index, withElement element: Element) {
        self[circularIndex(at: index)] = element
    }
}

extension Array {
    public func split(by size: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: size).map { start in
            let end = self.index(start, offsetBy: size, limitedBy: self.count) ?? self.endIndex
            return Array(self[start ..< end])
        }
    }
}

public func circularIndex(at index: Int, count: Int) -> Int {
    guard count > 0 else {
        return 0
    }

    let i = index % count
    return i >= 0 ? i : i + count
}
