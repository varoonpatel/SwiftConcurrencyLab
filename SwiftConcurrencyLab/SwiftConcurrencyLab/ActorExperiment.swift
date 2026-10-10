//
//  ActorExperiment.swift
//  SwiftConcurrencyLab
//
//  Created by Varun on 2026-10-09.
//

import Foundation

enum ActorExperiment {
    static func run() async {
        print("===== Actor Experiment =====")

//        await basicExample()
        await actorReentrancy()
    }
    
    // Experiment 1
    static func basicExample() async {
        let counter = Counter()
        
        async let first = counter.increment()
        async let second = counter.increment()
        async let third = counter.increment()
        
        let results = await (first, second, third)
        
        print("Results: \(results)")
        print("Final count: \(await counter.count)")
    }
    
    actor Counter {
        var count: Int = 0
        
        func increment() {
            count += 1
        }
    }
    
    // Experiment 2
    /// Reentrancy is when an actor method is suspended at `await`, allowing other work to run on that actor before the first call finishes, so the actor's state may have changed by the time it resumes.
    /// Don't rely on invarient (`amount <= balance`)
    static func actorReentrancy() async {
        let bankAccount = BankAccount()
        
        await bankAccount.deposit(100)
        async let firstTransaction = bankAccount.withdraw(50)
        async let secondTransaction = bankAccount.withdraw(80)
        
        _ = await (firstTransaction, secondTransaction)
        
        print("Account balance: \(await bankAccount.balance)")
    }
    
    actor BankAccount {
        var balance: Int = 0
        private var reserved: Int = 0
        
        func deposit(_ amount: Int) {
            balance += amount
        }
        
        func withdraw(_ amount: Int) async {
            guard amount <= balance - reserved else {
                print("Insufficient funds")
                return
            }
            reserved += amount
            
            print("Checking balance...")
            do {
                try await Task.sleep(for: .seconds(2))
                balance -= amount
                reserved -= amount
            } catch {
                reserved -= amount
                
            }
            print("Withdrawal completed. Balance:", balance)
        }
    }
    
    // Experiment 3
    /// Isolated property let us run a function execute on isolation of the actor instance passed as a parameter.
    /// calls to actor's isolated properties and methods do not require`await` inside the function.
    static func isolatedParameter() async {
        let counter = Counter()
        
        await incrementThreeTimes(counter: counter)
        
        func incrementThreeTimes(counter: isolated Counter) {
            counter.increment()
            counter.increment()
            counter.increment()
        }
    }
}
