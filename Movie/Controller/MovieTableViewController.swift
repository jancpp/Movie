//
//  MovieTableViewController.swift
//  Movie
//
//  Created by Jan Polzer on 8/4/18.
//  Copyright © 2018 Apps KC. All rights reserved.
//

import UIKit
import CoreData

class MovieTableViewController: UITableViewController {
    
    private var coreData = CoreDataStack()
    private var fetchedResultsController: NSFetchedResultsController<Movie>?
    private var movieService: MovieService?
    @IBAction func resetRatingsAction(_ sender: UIBarButtonItem) {
        movieService?.resetAllRatings(completion: { [weak self] (success) in
            if success {
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        movieService = MovieService(managedObjectContext: coreData.persistentContainer.viewContext)
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController?.sections {
            return sections.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections {
            return sections[section].numberOfObjects
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieTableViewCell
        
        if let movie = fetchedResultsController?.object(at: indexPath) {
            cell.configureCell(movie: movie)
            cell.userRatingHandler = { [weak self] (newRating) in
                // movieservice to update rating
                self?.movieService?.updateRating(for: movie, with: newRating)
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let movieToDelete = fetchedResultsController?.object(at: indexPath) else { return }
            
            let confirmDeleteAlertController = UIAlertController(title: "Remove Movie", message: "Are you sure you would like to delete \"\(movieToDelete.title ?? "")\"", preferredStyle: .actionSheet)
            
            let deleteActoin = UIAlertAction(title: "Delete", style: .default) { (action) in
                self.coreData.persistentContainer.viewContext.delete(movieToDelete)
                self.coreData.saveContext()
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            confirmDeleteAlertController.addAction(deleteActoin)
            confirmDeleteAlertController.addAction(cancelAction)
            
            present(confirmDeleteAlertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Private
    
    private func loadData() {
        fetchedResultsController = movieService?.getMovies()
        fetchedResultsController?.delegate = self
    }
}


extension MovieTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        
        switch type {
        case .update:
            tableView.reloadRows(at: [indexPath], with: .fade)
            
        case .delete:
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
