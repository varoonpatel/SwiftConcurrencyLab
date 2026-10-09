//
//  TaskExperiment.swift
//  SwiftConcurrencyLab
//
//  Created by Varun on 2026-10-09.
//

import Foundation

/// Task is used to create unstructured task. Unlike structured concurrency, parent task does not wait for child task to finish before leaving the scope.
/// Task inherit caller's actor isolation, task priority and task-local value
/// We can set Task name and prioority while creating
enum TaskExperiment {
    
    static func run() async {
        print("===== Task Experiment =====")

//        await basicTask()
//        await parentDoesNotWait()
        await cancellation()
    }
    
    // Experiment 1
    /// Unlike structured concurrency, parent task does not wait for child task to finish before leaving the scope.
    /// We can retain the task and wait for the its result later
    static func basicTask() async {
        print("Starting task experiment 1")
        
        print("Parent Started")
        
        let task = Task {
            print("Task started")
            
            try? await Task.sleep(for: .seconds(1))
            
            print("Task finished")
            
            return "Hello from Task"
        }
        
        print("Parent continues")
        
        let result = await task.value
        print("Result: \(result)")
        
        print("Parent ended")
    }
    
    // Experiment 2
    /// Here, parent does not wait for task to finish, it immediately returns.
    private static func parentDoesNotWait() async {
        print("Starting task experiment 2")

        print("Parent started")

        Task {
            try? await Task.sleep(for: .seconds(1))
            print("Child task finished")
        }

        print("Parent finished")
    }
    
    // Experiment 3
    /// `task.cancel()` immediately mark task as cacelled and since `Task.sleep` is cancellation aware API it would immediately cancel the task and return `CancellationError`
    private static func cancellation() async {
        print("Starting task experiment 3")
        
        let task = Task {
            print("Task started")

            do {
                try await Task.sleep(for: .seconds(2))
                print("Task finished")
            } catch let error as CancellationError {
                print("Task was cancelled: \(error)")
            } catch {
                print("Error")
            }
        }
        
        try? await Task.sleep(for: .seconds(1))

        print("Cancelling task")
        task.cancel()

        return await task.value
    }
}
