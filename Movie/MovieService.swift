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
    
    static func getMovies(moc: NSManagedObjectContext) -> NSFetchedResultsController<Movie> {
        
        let fetchedResultsController: NSFetchedResultsController<Movie>
        
        let request: NSFetchRequest<Movie> = Movie.fetchRequest()
        let nameSort = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [nameSort]
        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Error fetching records" )
        }
        
        return fetchedResultsController
    }
    
}
