//
//  DispatchUtils.swift
//  WolfCore
//
//  Created by Robert McNally on 7/9/15.
//  Copyright © 2015 Arciem LLC. All rights reserved.
//

import Foundation

#if os(Linux)
    import CDispatch
    public typealias dispatch_block_t = () -> Void
#endif

// #define DISPATCH_QUEUE_CONCURRENT \
                // DISPATCH_GLOBAL_OBJECT(dispatch_queue_attr_t, \
                // _dispatch_queue_attr_concurrent)

// A Canceler is returned by functions in this file that either execute a block after a delay, or execute a block at intervals. If the <isCanceled> variable is set to true, the block will never be executed, or the calling of the block at intervals will stop.
public class Canceler {
    public var isCanceled = false
    public init() { }
    public func cancel() { isCanceled = true }
}

// Convenience types for symmetry with Swift naming conventions
public typealias DispatchBlock = dispatch_block_t
public typealias DispatchQueue = dispatch_queue_t
public typealias ErrorBlock = (ErrorType) -> Void

// A block that takes a Canceler. The block will not be called again if it sets the <isCanceled> variable of the Canceler to true.
public typealias CancelableBlock = (canceler: Canceler) -> Void

public let mainQueue = dispatch_get_main_queue()
#if os(Linux)
    public let backgroundQueue = dispatch_queue_create("background", &_dispatch_queue_attr_concurrent)
#else
    public let backgroundQueue = dispatch_queue_create("background", DISPATCH_QUEUE_CONCURRENT)
#endif

// A utility function to convert a time since now as a Double (NSTimeInterval) representing a number of seconds to a dispatch_time_t used by GCD.
public func dispatchTimeSinceNow(offsetInSeconds: NSTimeInterval) -> dispatch_time_t {
    return dispatch_time(DISPATCH_TIME_NOW, Int64(offsetInSeconds * Double(NSEC_PER_SEC)))
}

// Dispatch a block synchronously on the given queue. Blocks dispatched synchronously block the current thread until they complete.
//
// Example:
//   print("1")
//   dispatchSyncOn(queue: backgroundQueue) {
//     print("2")
//   }
//   print("3")
//
// Since the dispatch is synchronous, this example is guaranteed to print:
// 1
// 2
// 3
public func dispatchSync(onQueue queue: DispatchQueue, _ f: DispatchBlock) {
    dispatch_sync(queue, f)
}

// Dispatch a block synchronously on the main queue. This is useful when you're already executing a block on a background queue and you want to ensure the next operation happens on the main queue before the code of your background block proceeds.
public func dispatchSyncOnMain(f: DispatchBlock) {
    dispatchSync(onQueue: mainQueue, f)
}

func _dispatch(onQueue queue: DispatchQueue, canceler: Canceler, _ f: CancelableBlock) {
    dispatch_async(queue) {
        f(canceler: canceler)
    }
}

// Dispatch a block asynchronously on the give queue. This method returns immediately. Blocks dispatched asynchronously will be executed at some time in the future.
public func dispatch(onQueue queue: DispatchQueue, _ f: DispatchBlock) -> Canceler {
    let canceler = Canceler()
    _dispatch(onQueue: queue, canceler: canceler) { canceler in
        if !canceler.isCanceled {
            f()
        }
    }
    return canceler
}

// Dispatch a block asynchronously on the main queue.
public func dispatchOnMain(f: DispatchBlock) -> Canceler {
    return dispatch(onQueue: mainQueue, f)
}

// Dispatch a block asynchronously on the background queue.
public func dispatchOnBackground(f: DispatchBlock) -> Canceler {
    return dispatch(onQueue: backgroundQueue, f)
}

func _dispatch(onQueue queue: DispatchQueue, afterDelay delay: NSTimeInterval, c: Canceler, f: CancelableBlock) {
    dispatch_after(dispatchTimeSinceNow(delay), queue) {
        f(canceler: c)
    }
}

// After the given delay, dispatch a block asynchronously on the given queue. Returns a Canceler object that, if its <isCanceled> attribute is true when the dispatch time arrives, the block will not be executed.
public func dispatch(onQueue queue: DispatchQueue, afterDelay delay: NSTimeInterval, f: DispatchBlock) -> Canceler {
    let canceler = Canceler()
    _dispatch(onQueue: queue, afterDelay: delay, c: canceler) { canceler in
        if !canceler.isCanceled {
            f()
        }
    }
    return canceler
}

// After the given delay, dispatch a block asynchronously on the main queue. Returns a Canceler object that, if its <isCanceled> attribute is true when the dispatch time arrives, the block will not be executed.
public func dispatchOnMain(afterDelay delay: NSTimeInterval, f: DispatchBlock) -> Canceler {
    return dispatch(onQueue: mainQueue, afterDelay: delay, f: f)
}

// After the given delay, dispatch a block asynchronously on the background queue. Returns a Canceler object that, if its <isCanceled> attribute is true when the dispatch time arrives, the block will not be executed.
public func dispatchOnBackground(afterDelay delay: NSTimeInterval, f: DispatchBlock) -> Canceler {
    return dispatch(onQueue: backgroundQueue, afterDelay: delay, f: f)
}

func _dispatchRepeated(onQueue queue: DispatchQueue, atInterval interval: NSTimeInterval, canceler: Canceler, _ f: CancelableBlock) {
    _dispatch(onQueue: queue, afterDelay: interval, c: canceler) { canceler in
        if !canceler.isCanceled {
            f(canceler: canceler)
        }
        if !canceler.isCanceled {
            _dispatchRepeated(onQueue: queue, atInterval: interval, canceler: canceler, f)
        }
    }
}

// Dispatch the block immediately, and then again after each interval passes. An interval of 0.0 means dispatch the block only once.
public func dispatchRepeated(onQueue queue: DispatchQueue, atInterval interval: NSTimeInterval, f: CancelableBlock) -> Canceler {
    let canceler = Canceler()
    _dispatch(onQueue: queue, canceler: canceler) { canceler in
        if !canceler.isCanceled {
            f(canceler: canceler)
        }
        if interval > 0.0 {
            if !canceler.isCanceled {
                _dispatchRepeated(onQueue: queue, atInterval: interval, canceler: canceler, f)
            }
        }
    }
    return canceler
}

public func dispatchRepeatedOnMain(atInterval interval: NSTimeInterval, f: CancelableBlock) -> Canceler {
    return dispatchRepeated(onQueue: mainQueue, atInterval: interval, f: f)
}

public func dispatchRepeatedOnBackground(atInterval interval: NSTimeInterval, f: CancelableBlock) -> Canceler {
    return dispatchRepeated(onQueue: backgroundQueue, atInterval: interval, f: f)
}
