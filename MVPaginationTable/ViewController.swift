//
//  ViewController.swift
//  MVPaginationTable
//
//  Created by Michael on 19/6/14.
//  Copyright (c) 2014 Michael Vu. All rights reserved.
//

import UIKit

class ViewController: MVPaginationTable, MVPaginatorDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        var array:NSMutableArray = NSMutableArray()
        for value in 0...50 {
            array.addObject("\(value)")
        }
        self.tableFrame = CGRectMake(0, 44, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 44)
        self.paginator = MVPaginator(array, delegate:self)
        self.paginator!.pageSize = 15
        self.paginator!.load()
    }
    
    func paginator(paginator: MVPaginator, didReceiveResults results: NSMutableArray) {
        self.items = results
        self.paginationCompleted()
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        super.tableView(tableView, numberOfRowsInSection: section)
        return self.items.count
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!  {
        super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let text = self.items[indexPath.row] as String
        cell.textLabel.text = text
        return cell
    }
}
