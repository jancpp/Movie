//
//  MovieTableViewController.swift
//  Movie
//
//  Created by Jan Polzer on 8/4/18.
//  Copyright © 2018 Apps KC. All rights reserved.
//

import UIKit
import CoreData

private var coreData = CoreDataStack()
private var fetchResultController: NSFetchedResultsController<Movie>?

class MovieTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
       
        if let sections = fetchResultController?.sections {
            return sections.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchResultController?.sections {
            return sections[section].numberOfObjects
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieTableViewCell
        
        if let movie = fetchResultController?.object(at: indexPath) {
            cell.cofigureCell(movie: movie)
        }

        return cell
    }

    // MARK: - private
    
    private func loadData() {
        fetchResultController = MovieService.getMovies(moc: coreData.persistentContainer.viewContext)
    }



}
