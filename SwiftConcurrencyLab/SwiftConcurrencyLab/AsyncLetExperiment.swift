//
//  AsyncLet.swift
//  SwiftConcurrencyLab
//
//  Created by Varun on 2026-10-08.
//

import Foundation

/// Using `async let`, we can kick off multiple async operations parallely.
/// Execution starts immediately without waiting for the results.
/// Suspend only when we need data from all the operations
enum AsyncLetExperiment {
    
    static func run() async {
        print("===== async let Experiment =====")

        await basic()
//        await multipleAsyncLets()
//        await sequentialComparison()
//        await throwingExample()
//        await cancellationExample()
    }
    
    
    // Experiment 1
    private static func basic() async {
        print("Starting async let experiment 1")
        async let response = fetchData(name: "First", delay: 2)
        
        let result = try? await response
        
        print("Result: \(result ?? "Request Failed")")
    }
    
    // Experiment 2
    // Both requests starts parallelly, `results` would wait for both request to finish
    private static func multipleAsyncLets() async {
        print("Starting async let experiment 2")
        
        async let first = try? fetchData(name: "First", delay: 3)
        async let second = try? fetchData(name: "Second", delay: 2)
        
        let results = await (first, second)
        
        print("Results: \(results)")
        print("Finished")
    }
    
    // Experiment 3
    // Without `async let` both requests starts sequentially
    private static func sequentialComparison() async {
        print("Starting async let experiment 3")
        
        let first = try? await fetchData(name: "First", delay: 3)
        let second = try? await fetchData(name: "Second", delay: 2)
        
        let results = (first, second)
        
        print("Results: \(results)")
        print("Finished")
    }
    
    
    
    // Experiment 4
    /// If one child throws, all siblings are immediately cancelled.
    private static func throwingExample() async {
        do {
            async let first = fetchData(name: "First", delay: 2, shouldThrowError: true)
            async let second = fetchData(name: "Second", delay: 4)
            
            let results = try await (first, second)
            print("Result: \(results)")
        } catch {
            print("Error: \(error)")
        }
    }
    
    // Experiment 5
    /// When parent task is cancelled, unfinished child tasks gets cancelled.
    private static func cancellationExample() async {

        let task = Task {

            do {
                let result = try await parent()
                print("Result: \(result)")
            } catch is CancellationError {
                print("Parent received CancellationError")
            } catch {
                print("Parent received error: \(error)")
            }
        }

        // Wait 3 seconds, then cancel the parent.
        try? await Task.sleep(for: .seconds(3))

        print("Cancelling parent task")

        task.cancel()

        await task.value
    }

    private static func parent() async throws -> (String, String) {

        print("Parent started")

        async let first = fetchData(
            name: "First",
            delay: 2
        )

        async let second = fetchData(
            name: "Second",
            delay: 10
        )

        print("Parent created children")

        return try await (first, second)
    }
    
    enum FetchError: Error {
        case failed(String)
    }
    
    private static func fetchData(
        name: String,
        delay: UInt64,
        shouldThrowError: Bool = false
    ) async throws -> String {

        print("\(name) started")

        do {
            try await Task.sleep(for: .seconds(delay))
        } catch {
            print("\(name) was cancelled: \(error)")
            throw error
        }

        if shouldThrowError {
            print("\(name) throwing")
            throw FetchError.failed(name)
        }

        print("\(name) finished")

        return "\(name) result"
    }
}

