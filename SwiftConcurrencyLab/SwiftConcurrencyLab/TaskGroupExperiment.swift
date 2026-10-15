//
//  TaskGroupExperiment.swift
//  SwiftConcurrencyLab
//
//  Created by Varun on 2026-10-13.
//

import Foundation

/// `TaskGroup` is used when you want to kick off dynamic number of child tasks and collect the results as all tasks finish.
/// We can use `group.cancelAll()` to cancel all the child tasks.
/// Use `addTaskUnlessCancelled` when you want to prevent adding a task if the group is cancelled.
/// There is no build-in way to throttle child tasks from executing parallelly, we can control by capping active tasks and managing count in `try await group.next()` or `for await result in group`
enum TaskGroupExperiment {
    static func run() async {
        //        await basicExample()
//        await differentReturnTypes()
        await errorExampleWithPartialResults()
    }
    
    // Experiment 1
    static func basicExample() async {
        let sports = ["Football", "Basketball", "Tennis"]
        
        do {
            let news: [String] = try await withThrowingTaskGroup(returning: [String].self) { group in
                for sports in sports {
                    group.addTask {
                        try await fetchNews(for: sports)
                    }
                }
                
                var results: [String] = []
                
                for try await news in group {
                    results.append(news)
                }
                
                return results
            }
            
            print("News: \(news)")
        } catch {
            print("Error: \(error)")
        }
    }
    
    static func fetchNews(for sports: String) async throws -> String {
        print("Fetching news for \(sports)")
        
        try await Task.sleep(for: .seconds(1))
        
        return "News for \(sports)"
    }
    
    // Experiment 2
    /// We have to use an enum when we want to store data returned from each child task are different
    static func differentReturnTypes() async {
        let movieResult = await withTaskGroup(of: MovieResult.self) { group in
            group.addTask {
                .movie(await fetchMovie())
            }
            
            group.addTask {
                .videoURL(await fetchVideoURL())
            }
            
            group.addTask {
                .rating(await fetchRating())
            }
            
            var results: [MovieResult] = []
            
            for await result in group {
                results.append(result)
            }
            
            return results
        }
        
        print("Movie result: \(movieResult)")
    }
    
    enum MovieResult {
        case movie(String)
        case videoURL(URL)
        case rating(Double)
    }
    
    static func fetchMovie() async -> String {
        "Movie"
    }
    
    static func fetchVideoURL() async -> URL {
        URL(string: "http://video.url")!
    }
    
    static func fetchRating() async -> Double {
        9.5
    }
    
    // Experiment 3
    static func errorExampleWithPartialResults() async {
        var results: [String] = []

        do {
            let articles = try await withThrowingTaskGroup(of: String.self) { group in

                for sport in ["Basketball", "Football", "Hockey"] {
                    group.addTask {
                        try await fetchArticles(for: sport)
                    }
                }

                for try await article in group {
                    results.append(article)
                }

                return results
            }

            print("Articles:", articles)

        } catch {
            print("Group failed with error:", error)
        }
        
        print("Partial Results: \(results)")
    }
    
    enum FeedError: Error {
        case failedToFetch(String)
    }
    
    static func fetchArticles(for sport: String) async throws -> String {
        print("Started: \(sport)")
        
        if sport == "Hockey" {
            try await Task.sleep(for: .seconds(3))
            print("Hockey is throwing an error")
            throw FeedError.failedToFetch(sport)
        }
        
        try await Task.sleep(for: .seconds(1))
        
        print("Finished: \(sport)")
        return "\(sport) articles"
    }
}
