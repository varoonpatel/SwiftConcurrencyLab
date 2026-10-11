//
//  MainActorExperiment.swift
//  SwiftConcurrencyLab
//
//  Created by Varun on 2026-10-11.
//

import Foundation

/// `@MainActor` is a global actor, it uses the main queue to execute its work.
/// Methods and types marked with `@MainActor` can safely modify UI because UI always on the main queue.
enum MainActorExperiment {
    static func run() async {
        print("===== @MainActor Experiment =====")

//        await nonMainActorFunction()
//        await mainActorFunction()
        await mainActorRun()
    }
    
    // Experiment 1
    /// Since the current function is not isolated to the `@MainActor` we have to use `await` to access Counter's property and function
    static func nonMainActorFunction() async {
        let counter = Counter()
        
        await counter.increment()
        print("Current count: \(await counter.count)")
    }
    
    // Experiment 2
    /// Since the current function is isolated to the `@MainActor` we don't need to use `await` to access Counter's property and function
    @MainActor
    static func mainActorFunction() async {
        let counter = Counter()
        
        counter.increment()
        print("Current count: \(counter.count)")
    }
    
    // Experiment 3
    /// Below code uses `await MainActor.run` to dispatch work to the `@MainActor`
    static func mainActorRun() async {
        let counter = Counter()
        
        let task = Task.detached {
            await MainActor.run {
                counter.increment()
                print("Current count: \(counter.count)")
            }
        }
        
        await task.value
    }
    
    
    /// All the properties and functions are isolated to the `@MainActor`, caller must respect isolation the `@MainActor`
    @MainActor
    class Counter {
        var count: Int = 0
        
        func increment() {
            count += 1
        }
    }
}
