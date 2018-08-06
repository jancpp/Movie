//
//  MovieService.swift
//  Movie
//
//  Created by Jan Polzer on 8/4/18.
//  Copyright © 2018 Apps KC. All rights reserved.
//

import Foundation
import CoreData

class MovieService {
    
    private var managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    func getMovies() -> NSFetchedResultsController<Movie> {
        let fetchedResultsController: NSFetchedResultsController<Movie>
        
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        let nameSort = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [nameSort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        }
        catch {
            fatalError("Error in fetching records")
        }
        
        return fetchedResultsController
    }
    
    func updateRating(for movie: Movie, with newRating: Int) {
        movie.userRating = Int16(newRating)
        
        do {
            try managedObjectContext.save()
        }
        catch {
            print("Error updating movie rating")
        }
    }
    
    func resetAllRatings(completion: (Bool) -> Void) {
        let batchUpdateRequest = NSBatchUpdateRequest(entityName: "Movie")
        batchUpdateRequest.propertiesToUpdate = ["userRating": 0]
        batchUpdateRequest.resultType = .updatedObjectIDsResultType
        
        do {
            if let result = try managedObjectContext.execute(batchUpdateRequest) as? NSBatchUpdateResult {
                if let objectIds = result.result as? [NSManagedObjectID] {
                    for objectId in objectIds {
                        let managedObject = managedObjectContext.object(with: objectId)
                        
                        if !managedObject.isFault {
                            managedObjectContext.stalenessInterval = 0
                            managedObjectContext.refresh(managedObject, mergeChanges: true)
                        }
                    }
                    
                    completion(true)
                }
            }
            
        } catch {
            completion(false)
        }
        
    }
}
