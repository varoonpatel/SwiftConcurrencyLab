//
//  TaskDetachedExperiment.swift
//  SwiftConcurrencyLab
//
//  Created by Varun on 2026-10-09.
//

import Foundation

/// `Task.detached` is similar to regular task, but they don't inherit parent task's actor isolation, `TaskLocal` value and task priority.
/// Since `Task.detached` does not inherit actor isolation, they are useful to spun off task of the `@MainActor` or other custom actor. e.g. Starting a new off `@MainActor` task from SwiftUI view.
enum TaskDetachedExperiment {
    @TaskLocal static var requestId: String?

    static func run() async {
        print("===== Task.detached Experiment =====")

//        await basicDetachedTask()
        await actorIsolation()
        await taskPriority()
        await taskLocalValue()
    }

    // Experiment 1
    private static func basicDetachedTask() async {

        print("Parent task started")

        let task = Task.detached {
            print("Detached task started")

            try? await Task.sleep(for: .seconds(2))

            print("Detached task finished")

            return "Result from detached task"
        }

        print("Parent continues")

        let result = await task.value

        print("Result: \(result)")
        print("Parent finished")
    }
    
    // Experiment 2
    /// `MainActor.preconditionIsolated()` is used to verify actor isolation runtime.
    @MainActor
    final class Counter {

        private var value = 0

        func increment() {
            value += 1
            print("Counter: \(value)")
        }

        func experiment() async {

            print("Starting experiment")

            let regularTask = Task {
                // Verify that we're executing on MainActor.
                MainActor.preconditionIsolated()

                print("Regular Task is MainActor-isolated")

                increment()
            }

            await regularTask.value
            
            let detachedTask = Task.detached {
                MainActor.preconditionIsolated()

                print("Detached task started")
            }

            await detachedTask.value

            print("Experiment finished")
        }
    }
    
    static func actorIsolation() async {
        let counter = Counter()
        await counter.experiment()
    }
    
    // Experiment 3
    /// Might have to run multiple times to see a different task priority for detaches task.
    static func taskPriority() async {
        await Task(priority: .high) {
            print("Parent priority:", Task.currentPriority)
            
            let regularTask = Task {
                print("Regular task priority:", Task.currentPriority)
            }
            
            let detachedTask = Task.detached {
                print("Detached task priority:", Task.currentPriority)
            }
            
            await regularTask.value
            await detachedTask.value
        }.value
    }
    
    // Experimentt 4
    /// detachedTask would print `Detached Task: nil`, since detached task does not inherit TaskLocal value.
    static func taskLocalValue() async {
        await $requestId.withValue("request-123") {
            print("Parent:", requestId ?? "nil")
            
            let regularTask = Task {
                print("Regular Task:", requestId ?? "nil")
            }
            
            let detachedTask = Task.detached {
                print("Detached Task:", requestId ?? "nil")
            }
            
            await regularTask.value
            await detachedTask.value
        }
    }
}
