//
//  ListViewController.swift
//  LocationTrackingDemo
//
//  Created by Ohrimenko Maxim on 9/17/18.
//  Copyright © 2018 Unicsoft. All rights reserved.
//

import UIKit
import RealmSwift

/**
 Delegate to notify about what route to show or clear the map
 */
protocol ListViewControllerDelegate: class {
    /**
     Notifies delegate to show picked route on map
     */
    func show(route: RouteObject)
    /**
     Notifies delegate to clear all on map
     */
    func clearAll()
}

/**
 Class to handle list representation of detected routes
 */
class ListViewController: UIViewController {

    /**
     UITableView outlet
     */
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.estimatedRowHeight = 50.0
            tableView.rowHeight = UITableViewAutomaticDimension
        }
    }
    /**
     Stores array of routes
     */
    var routes: Results<RouteObject>!
    /**
     Stores token of observed array to notify about the updates
     */
    var token: NotificationToken?
    /**
     ListViewControllerDelegate delegate
     */
    weak var delegate: ListViewControllerDelegate?
    /**
     Custom date formatter
     */
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }()
    
    /**
     Called after the controller's view is loaded into memory.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        let clearButton = UIBarButtonItem.init(title: "Clear", style: .plain, target: self, action: #selector(clearAll))
        navigationItem.rightBarButtonItem = clearButton
        
        token = routes.observe { [weak self] (_) in
            self?.tableView.reloadData()
        }
    }
    /**
     Deinitialisation
     */
    deinit {
        token?.invalidate()
    }
    
    /**
     Button action to show alert and propose user to delete the routes from DB
     */
    @objc func clearAll() {
        let alert = UIAlertController.init(title: "Are you sure you want to delete all routes?", message: nil, preferredStyle: .alert)
        let yesAction = UIAlertAction.init(title: "Yes", style: .default) { [weak self] (_) in
            if let realm = self?.routes.realm {
                try! realm.write {
                    realm.deleteAll()
                    self?.delegate?.clearAll()
                }
            }
        }
        let noAction = UIAlertAction.init(title: "No", style: .cancel) { (_) in }
        alert.addAction(yesAction)
        alert.addAction(noAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}

/**
 UITableViewDelegate & UITableViewDataSource implementation
 */
extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    /**
     Tells the data source to return the number of rows in a given section of a table view
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    /**
     Asks the data source for a cell to insert in a particular location of the table view
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        let item = routes[indexPath.row]
        cell.textLabel?.text = "Start: " + dateFormatter.string(from: Date(timeIntervalSince1970: item.startInterval))
        if item.endInterval == 0.0 {
            cell.detailTextLabel?.text = "End: " + dateFormatter.string(from: Date())
        } else {
            cell.detailTextLabel?.text = "End: " + dateFormatter.string(from: Date(timeIntervalSince1970: item.endInterval))
        }
        return cell
    }
    /**
     Tells the delegate that the specified row is now selected
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = routes[indexPath.row]
        delegate?.show(route: item)
        navigationController?.popViewController(animated: true)
    }
    
}
