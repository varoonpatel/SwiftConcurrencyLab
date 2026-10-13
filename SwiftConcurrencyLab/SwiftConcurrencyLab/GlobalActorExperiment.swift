//
//  GlobalActorExperiment.swift
//  SwiftConcurrencyLab
//
//  Created by Varun on 2026-10-12.
//

/// `@globalActor` is a mechanism in that allows multiple types, properties, function to share the same isolation domain,
/// ensuring their isolated code executes serially and helping to prevent data races.
/// Normal actor protects its own state, whereas `globalActor`can share isolation domain.

enum GlobalActorExperiment {
    static func run() async {
        await processImage()
    }
    
    @globalActor
    actor ImageProcessingActor {
        static let shared = ImageProcessingActor()
    }
    
    @ImageProcessingActor
    final class ImageCache {
        func save(_ image: String) {
            print("Caching image: \(image)")
        }
    }
    
    @ImageProcessingActor
    final class ImageFilter {
        func applyGrayscale(to image: String) {
            print("Applying Grayscale to: \(image)")
        }
    }
    
    /// `processImage` is also isolated to the `ImageProcessingActor` actor so, it does not need to cross the boundary to run both the methods.
    @ImageProcessingActor
    static func processImage() async {
        let cache = ImageCache()
        let filter = ImageFilter()
        
        cache.save("image_data")
        filter.applyGrayscale(to: "image_data")
    }
}
