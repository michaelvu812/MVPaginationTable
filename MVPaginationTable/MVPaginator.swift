//
//  MVPaginator.swift
//  MVPaginator
//
//  Created by Michael on 19/6/14.
//  Copyright (c) 2014 Michael Vu. All rights reserved.
//

import Foundation
import CoreData

enum MVPaginatorType:Int {
    case Default = 0, Array, CoreData, Url, Json
}

enum MVPaginatorStatus:Int {
    case None = 0, InProgress, Done
}

let MVPaginatorDefaultPageSize = 10

@objc protocol MVPaginatorDelegate {
    func paginator(paginator:MVPaginator, didReceiveResults results:NSMutableArray)
    @optional func paginatorDidFail(paginator:MVPaginator, error:NSError)
    @optional func paginatorDidReset(paginator:MVPaginator)
}

@objc class MVPaginator: NSObject {
    var paginatorType:MVPaginatorType = .Default
    var pageSize:Int? = MVPaginatorDefaultPageSize
    var totalCount:Int  = 0
    var totalPage:Int = 0
    var currentPage:Int = 0
    var collection:NSMutableArray?
    var paginatorDelegate: MVPaginatorDelegate?
    var paginatorStatus: MVPaginatorStatus = .None
    var paginatorObject:AnyObject?
    var paginatorClass:AnyClass?
    var managedContext: NSManagedObjectContext = NSManagedObjectContext()
    var predicateOption:NSPredicate?
    
    init(_ array:NSMutableArray, type: MVPaginatorType? = .Array as MVPaginatorType, delegate:MVPaginatorDelegate?) {
        self.paginatorObject = array
        self.paginatorType = type!
        self.paginatorDelegate = delegate!
    }
    
    init(_ object:AnyClass, type: MVPaginatorType? = .CoreData as MVPaginatorType, context:NSManagedObjectContext, delegate:MVPaginatorDelegate?) {
        self.paginatorClass = object
        self.paginatorType = type!
        self.managedContext = context
        self.paginatorDelegate = delegate!
    }
    
    init(_ object:AnyClass, predicate:NSPredicate, type: MVPaginatorType? = .CoreData as MVPaginatorType, context:NSManagedObjectContext, delegate:MVPaginatorDelegate?) {
        self.paginatorClass = object
        self.predicateOption = predicate
        self.paginatorType = type!
        self.managedContext = context
        self.paginatorDelegate = delegate!
    }
    
    func setDefaultValues() {
        self.totalCount = 0
        self.totalPage = 0
        self.currentPage = 0
        self.collection = NSMutableArray()
        self.paginatorStatus = .None
    }
    
    func load() {
        self.reset()
        self.fetchNextPage()
    }
    
    func reset() {
        self.setDefaultValues()
        self.paginatorDelegate?.paginatorDidReset?(self)
    }
    
    func isLastPage() -> Bool {
        if self.paginatorStatus == .None {return false}
        return (self.currentPage >= self.totalPage)
    }
    
    func fetchFirstPage() {
        self.load()
    }
    
    func fetchNextPage() {
        if self.paginatorStatus == .InProgress {return}
        if self.isLastPage() == false {
            self.paginatorStatus = .InProgress
            self.fetchResultsWithPage(self.currentPage+1, pageSize: self.pageSize!)
        }
    }
    
    func fetchResultsWithPage(page:Int, pageSize:Int) {
        if self.paginatorType == .Array {
            let array = self.paginatorObject? as NSMutableArray
            if (array.count > 0) {
                let location = (page * pageSize) - pageSize
                var length:Int
                if self.totalCount > 0 && (self.totalCount - location) < pageSize {
                    length = (self.totalCount - location)
                } else {
                    length = pageSize
                }
                var results = array.subarrayWithRange(NSMakeRange(location, length))
                self.receivedResults(results, total: array.count as Int)
            } else {
                self.receivedResults(NSArray(), total: 0)
            }
        } else if self.paginatorType == .CoreData {
            if self.paginatorClass?.isSubclassOfClass(NSManagedObject.classForCoder()) {
                var array = NSArray()
                if self.predicateOption != nil {
                    array = self.paginatorClass?.fetchWithCondition(self.predicateOption!, context: self.managedContext) as NSArray
                } else {
                    array = self.paginatorClass?.fetchInContext(self.managedContext) as NSArray
                }
                if (array.count > 0) {
                    let location = (page * pageSize) - pageSize
                    var length:Int
                    if self.totalCount > 0 && (self.totalCount - location) < pageSize {
                        length = (self.totalCount - location)
                    } else {
                        length = pageSize
                    }
                    var results = array.subarrayWithRange(NSMakeRange(location, length))
                    self.receivedResults(results, total: array.count as Int)
                } else {
                    self.receivedResults(NSArray(), total: 0)
                }
            } else {
                self.receivedResults(NSArray(), total: 0)
            }
        } else if self.paginatorType == .Url {
            
        } else if self.paginatorType == .Json {
            
        } else {
            self.receivedFailedResults(self.errorWithMessage("Wrong pagination type"))
        }
    }
    
    func errorWithMessage(message:String) -> NSError {
        var errorDetail = NSMutableDictionary()
        errorDetail.setValue(message, forKey: NSLocalizedDescriptionKey)
        var errorMessage = NSError(domain: "MVPaginator", code: NSURLErrorUnknown, userInfo: errorDetail)
        return errorMessage
    }
    
    func receivedResults(results:NSArray, total:Int) {
        self.collection!.addObjectsFromArray(results)
        self.currentPage += 1
        self.totalCount = total
        self.totalPage = Int(ceil(CDouble(self.totalCount)/CDouble(self.pageSize!)))
        self.paginatorStatus = .Done
        self.paginatorDelegate?.paginator(self, didReceiveResults: self.collection!)
    }
    
    func receivedFailedResults(error:NSError) {
        self.paginatorStatus = .Done
        self.paginatorDelegate?.paginatorDidFail?(self, error: error)
    }
}

extension NSManagedObject {
    class func entityName() -> String {
        return NSStringFromClass(self.classForCoder())
    }
    class func fetchInContext(context:NSManagedObjectContext) -> NSArray {
        let request = NSFetchRequest()
        let entity = NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: context)
        request.entity = entity
        return context.executeFetchRequest(request, error: nil)
    }
    class func fetchWithCondition(condition:NSPredicate, context:NSManagedObjectContext) -> NSArray {
        let request = NSFetchRequest()
        let entity = NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: context)
        request.entity = entity
        if condition != nil {
            request.predicate = condition
        }
        return context.executeFetchRequest(request, error: nil)
    }
}
