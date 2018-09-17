//
//  ListViewController.swift
//  LocationTrackingDemo
//
//  Created by developer MacBook on 9/17/18.
//  Copyright © 2018 Unicsoft. All rights reserved.
//

import UIKit
import RealmSwift

protocol ListViewControllerDelegate: class {
    func show(route: RouteObject)
    func clearAll()
}

class ListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var routes: Results<RouteObject>!
    var token: NotificationToken?
    
    weak var delegate: ListViewControllerDelegate?
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let clearButton = UIBarButtonItem.init(title: "Clear", style: .plain, target: self, action: #selector(clearAll))
        navigationItem.rightBarButtonItem = clearButton
        
        token = routes.observe { [weak self] (_) in
            self?.tableView.reloadData()
        }
    }
    
    deinit {
        token?.invalidate()
    }
    
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

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = routes[indexPath.row]
        cell.textLabel?.text = "Start: " + dateFormatter.string(from: Date(timeIntervalSince1970: item.startInterval))
        if item.endInterval == 0.0 {
            cell.detailTextLabel?.text = ""
        } else {
            cell.detailTextLabel?.text = "End: " + dateFormatter.string(from: Date(timeIntervalSince1970: item.endInterval))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = routes[indexPath.row]
        delegate?.show(route: item)
        navigationController?.popViewController(animated: true)
    }
    
}
