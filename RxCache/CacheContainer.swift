//
//  CacheContainer.swift
//  RxCache
//
//  Created by alexej_ne on 11/06/2019.
//  Copyright © 2019 alexeyne. All rights reserved.
//

public final class CacheContainer {
    private static var instance: CacheContainer?
    
    public static var instanceLazyInit: CacheContainer {
        if let instance = instance {
            return instance
        }
        
        let newInst = CacheContainer()
        instance = newInst
        return newInst
    }
    
    private var cacheDataLifeTime: [CacheIdentifier: Date] = [:]
    private var caches: [CacheIdentifier: Any] = [:]
    private var cacheGroup: [CacheGroupId: [CacheIdentifier]] = [:]
    private var cacheGroupOptions: [CacheGroupId: [CacheGroupOption]] = [:]
    
    private init() { }
    
    public static func releaseInstance() {
        instance = nil 
    }
    
    public func set(options: [CacheGroupOption], for groupId: CacheGroupId) {
        cacheGroupOptions[groupId] = options
    }
    
    public func set<D>(data: D, for id: CacheIdentifier, in groupID: CacheGroupId? ) {
        caches[id] = data
        cacheDataLifeTime[id] = Date()
        
        if let groupID = groupID {
            add(cacheId: id, to: groupID)
            applyOptions(for: groupID)
        }
    }
    
    public func tryGet<D>(for id: CacheIdentifier) -> D? {
        guard let data = caches[id] else { return nil }
        
        guard let result = data as? D else { fatalError("Данные в кеше \(id)[\(data)] не соответсвуют типу \(D.self)") }
        
        return result
    }
    
    public func isDataExpired(for id: CacheIdentifier, maxTimelife: TimeInterval) -> Bool {
        guard var date = cacheDataLifeTime[id] else { return true }
        date.addTimeInterval(maxTimelife)
        return date.compare(Date()) == .orderedAscending
    }
    
    public func isFreshData(for id: CacheIdentifier, freshLifeTime: TimeInterval) -> Bool  {
        return !isDataExpired(for: id, maxTimelife: freshLifeTime)
    }
    
    
    private func add(cacheId: CacheIdentifier, to groupId: CacheGroupId) {
        if var groupCaches = cacheGroup[groupId] {
            groupCaches.append(cacheId)
        } else {
            cacheGroup[groupId] = [cacheId]
        }
    }
    
    public func applyOptions(for groupId: CacheGroupId) {
        guard let options = cacheGroupOptions[groupId], !options.isEmpty, var cacheGroup = cacheGroup[groupId] else { return }
        
        for option in options {
            switch option {
            case .maxGroupCaches(let maxCount):
                if cacheGroup.count > maxCount { cacheGroup.removeFirst()  }
            }
        }
    }
}
