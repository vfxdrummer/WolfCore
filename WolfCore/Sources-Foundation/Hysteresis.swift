//
//  Hysteresis.swift
//  WolfCore
//
//  Created by Robert McNally on 12/15/15.
//  Copyright © 2015 Arciem. All rights reserved.
//

import Foundation

/**

 hys·ter·e·sis
 ˌhistəˈrēsis/
 noun
 Physics

 noun: hysteresis
 the phenomenon in which the value of a physical property lags behind changes in the effect causing it, as for instance when magnetic induction lags behind the magnetizing force.

 **/

public class Hysteresis {
    private let effectStartLag: NSTimeInterval
    private let effectEndLag: NSTimeInterval
    private let effectStart: DispatchBlock
    private let effectEnd: DispatchBlock
    private var causeCount: Int = 0
    private var effectStartCanceler: Canceler?
    private var effectEndCanceler: Canceler?
    private var effectStarted: Bool = false
    private let serializer = Serializer(name: "Hysteresis")

    public init(effectStart: DispatchBlock, effectEnd: DispatchBlock, effectStartLag: NSTimeInterval, effectEndLag: NSTimeInterval) {
        self.effectStart = effectStart
        self.effectEnd = effectEnd
        self.effectStartLag = effectStartLag
        self.effectEndLag = effectEndLag
    }

    public func makeCause() -> Cause {
        return Cause(self)
    }

    private func incrementCauseCount() {
        serializer.dispatch() { [unowned self] in
            self.causeCount += 1
            if self.causeCount == 1 {
                self.effectEndCanceler?.cancel()
                self.effectStartCanceler = dispatchOnBackground(afterDelay: self.effectStartLag) {
                    if !self.effectStarted {
                        self.effectStart()
                        self.effectStarted = true
                    }
                }
            }
        }
    }

    private func decrementCauseCount() {
        serializer.dispatch() { [unowned self] in
            assert(self.causeCount > 0, "Attempt to decrement causeCount below zero.")
            self.causeCount -= 1
            if self.causeCount == 0 {
                self.effectStartCanceler?.cancel()
                self.effectEndCanceler = dispatchOnBackground(afterDelay: self.effectEndLag) {
                    if self.effectStarted {
                        self.effectEnd()
                        self.effectStarted = false
                    }
                }
            }
        }
    }

    public class Cause {
        private weak var h: Hysteresis?

        private init(_ h: Hysteresis) {
            self.h = h
            h.incrementCauseCount()
        }

        deinit {
            h?.decrementCauseCount()
        }
    }
}
