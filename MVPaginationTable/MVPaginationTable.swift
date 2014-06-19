//
//  MVPaginationTable.swift
//  MVPaginationTable
//
//  Created by Michael on 18/6/14.
//  Copyright (c) 2014 Michael Vu. All rights reserved.
//

import UIKit
import QuartzCore
import ObjectiveC

let isRetina = UIScreen.mainScreen().respondsToSelector(Selector("displayLinkWithTarget:selector:")) && UIScreen.mainScreen().scale == 2.0

@objc class MVPaginationTable: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    var tableView: UITableView = UITableView()
    var tableFrame: CGRect = CGRectZero {
        didSet {
            tableView.frame = tableFrame
        }
    }
    var items: NSMutableArray = NSMutableArray()
    var emptyLabel: UILabel = UILabel()
    var isRefreshing: Bool = false
    var canLoadMore: Bool = true
    var isLoadingMore: Bool = false
    var isShowSeparator: Bool = false
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var emptyText: String = String("Empty Data")
    var separatorColor = UIColor.colorWithHexString("#bbbbbb")
    var textColor = UIColor.colorWithHexString("#444444")
    var heightForRow:CGFloat = 40.0
    var activityIndicatorSize: CGFloat = 21.0
    var paginator: MVPaginator?
    var noMoreItemsText = String("No more items to load")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.separatorColor = self.separatorColor
        self.tableView.separatorStyle = .SingleLine
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.view.addSubview(self.tableView)
        
        var headerView = UIView(frame: CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), (isRetina ? 0.5 : 1)))
        headerView.backgroundColor = self.separatorColor
        self.tableView.tableHeaderView = headerView
        
        let rControl = UIRefreshControl()
        rControl.tintColor = UIColor.lightGrayColor()
        rControl.addTarget(self, action: Selector("refreshItem"), forControlEvents: .ValueChanged)
        self.refreshControl = rControl
        self.tableView.addSubview(self.refreshControl)
        self.tableView.reloadData()
        self.tableView.hidden = true
    }
    
    override func loadView() {
        super.loadView()
        if CGRectEqualToRect(self.tableView.frame, CGRectZero) {
            if CGRectEqualToRect(self.tableFrame, CGRectZero) {
                self.tableView.frame = self.view.frame
            } else {
                self.tableView.frame = self.tableFrame
            }
        }
    }
    
    func refreshItem() {
        if isLoadingMore {return}
        if isRefreshing {return}
        isRefreshing = true
        isLoadingMore = false
        self.paginator!.reset()
        self.paginationData()
    }
    
    func paginationData() {
        if !isRefreshing && !isLoadingMore && canLoadMore {return}
        if self.paginator!.currentPage <= 1 && items != nil {
            items = NSMutableArray()
        }
        self.addLoadMoreView()
        isLoadingMore = true
        self.paginator!.fetchNextPage()
    }
    
    func addLoadMoreView() {
        let footerView = UIView(frame: CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), self.heightForRow))
        footerView.backgroundColor = UIColor.clearColor()
        let bottomLayer = CALayer()
        bottomLayer.frame = CGRectMake(0, 0, CGRectGetWidth(footerView.frame), (isRetina ? 0.5 : 1))
        bottomLayer.backgroundColor = self.separatorColor.CGColor
        footerView.layer.addSublayer(bottomLayer)
        if self.paginator!.currentPage >= self.paginator!.totalPage && self.paginator!.totalPage > 1 {
            let noMoreLabel = UILabel(frame: footerView.frame)
            noMoreLabel.textAlignment = .Center
            noMoreLabel.text = self.noMoreItemsText
            noMoreLabel.backgroundColor = UIColor.clearColor()
            noMoreLabel.textColor = self.textColor
            footerView.addSubview(noMoreLabel)
        }
        self.tableView.tableFooterView = footerView
    }
    
    func paginationCompleted() {
        if self.isRefreshing {
            self.isRefreshing = false
            self.refreshControl.endRefreshing()
        }
        if self.paginator!.currentPage >= self.paginator!.totalPage {
            self.canLoadMore = false
            self.addLoadMoreView()
        } else {
            self.canLoadMore = true
        }
        if self.items.count > 0 && self.paginator!.totalPage > 0 {
            self.setEmptyView(false)
        } else {
            self.setEmptyView(true)
        }
        if self.isLoadingMore {
            self.hideActivityView()
        }
        self.isLoadingMore = false
        self.tableView.reloadData()
    }
    
    func setEmptyView(isEmpty:Bool) {
        if self.emptyLabel != nil && self.emptyLabel.isDescendantOfView(self.view) {
            self.emptyLabel.removeFromSuperview()
        }
        if isEmpty {
            self.tableView.hidden = true
            if self.paginator!.totalPage > 1 {
                self.tableView.scrollEnabled = true
            } else {
                self.tableView.scrollEnabled = false
            }
            self.emptyLabel = UILabel(frame: CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, CGRectGetWidth(self.tableView.frame), self.heightForRow))
            self.emptyLabel.text = self.emptyText;
            self.emptyLabel.textAlignment = .Center;
            self.emptyLabel.backgroundColor = UIColor.clearColor()
            self.emptyLabel.textColor = self.textColor
            self.emptyLabel.hidden = false;
            self.view.addSubview(self.emptyLabel);
        } else {
            self.tableView.hidden = false;
        }
    }
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        super.touchesBegan(touches, withEvent: event)
        let location = event.allTouches().anyObject().locationInView(self.tableView)
        let locationHeight:CGFloat = (isRetina ? 40.0 : 20.0)
        if location.y > 0.0 && location.y < locationHeight && location.x > 0.0 && location.x < locationHeight {
            self.touchOnStatusBar()
        }
    }
    
    func touchOnStatusBar() {
        if self.tableView != nil {
            self.tableView.setContentOffset(CGPointZero, animated: true)
        }
    }
    
    func scrollToTop() {
        if self.tableView.numberOfSections() > 0 {
            let topPosition = NSIndexPath(forRow: NSNotFound, inSection: 0)
            self.tableView.scrollToRowAtIndexPath(topPosition, atScrollPosition: .Top, animated: true)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.isKindOfClass(UITableView.classForCoder()) && scrollView.contentOffset.y > 0.0 {
            let scrollPosition = scrollView.contentSize.height - CGRectGetHeight(scrollView.frame) - scrollView.contentOffset.y
            if scrollPosition < self.heightForRow && !self.isLoadingMore && self.canLoadMore {
                self.loadMore()
            }
        }
    }
    
    func loadMore() {
        if self.isLoadingMore && !self.canLoadMore {return}
        self.showActivityView()
        self.isLoadingMore = true
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            self.addMoreItem()
        })
    }
    
    func showActivityView() {
        let footerView = UIView(frame: CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), self.heightForRow))
        footerView.backgroundColor = UIColor.clearColor()
        let bottomLayer = CALayer()
        bottomLayer.frame = CGRectMake(0, 0, CGRectGetWidth(footerView.frame), (isRetina ? 0.5 : 1))
        bottomLayer.backgroundColor = self.separatorColor.CGColor
        footerView.layer.addSublayer(bottomLayer)
        self.activityIndicator = UIActivityIndicatorView(frame: CGRectMake((CGRectGetWidth(footerView.frame) - self.activityIndicatorSize)/2, (CGRectGetHeight(footerView.frame) - self.activityIndicatorSize)/2, self.activityIndicatorSize, self.activityIndicatorSize))
        self.activityIndicator.activityIndicatorViewStyle = .Gray
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.hidden = false
        self.activityIndicator.startAnimating()
        footerView.addSubview(self.activityIndicator)
        self.tableView.tableFooterView = footerView
    }
    
    func hideActivityView() {
        self.activityIndicator.stopAnimating()
    }
    
    func addMoreItem() {
        self.paginationData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!  {
        return nil
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}