//
//  CacheContainer.swift
//  RxCache
//
//  Created by alexej_ne on 11/06/2019.
//  Copyright © 2019 alexeyne. All rights reserved.
//

public final class CacheContainer {
    private static var instance: CacheContainer?
    
    public var isEnabled: Bool = true
    public var logEnabled: Bool = false
    
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
        
        if logEnabled {
            let optString = options.map { "\($0)"}.joined(separator: ",")
            log("[SET OPTIONS] groupId: \(groupId) options: \(optString)")
        }
        
    }
    
    public func set<D>(data: D, for id: CacheIdentifier, in groupID: CacheGroupId? ) {
        guard isEnabled else { return }
        
        caches[id] = data
        cacheDataLifeTime[id] = Date()
        
        if logEnabled {
            log("[SET] cacheId:\(id) time:\(Date()) data: \(data)") 
        }
        
        if let groupID = groupID {
            add(cacheId: id, to: groupID)
            applyOptions(for: groupID)
        }
    }
    
    public func tryGet<D>(for id: CacheIdentifier) -> D? {
        guard isEnabled else { return nil }
        
        guard let data = caches[id] else {
            log("[GET-notfound] cacheId:\(id) \(D.self)")
            return nil
        }
        
        guard let result = data as? D else { fatalError("Данные в кеше \(id)[\(data)] не соответсвуют типу \(D.self)") }
        
        log("[GET] cacheId:\(id) \(D.self)")
        return result
    }
    
    public func isDataExpired(for id: CacheIdentifier, maxTimelife: Seconds) -> Bool {
        guard var date = cacheDataLifeTime[id] else { return true }
        date.addTimeInterval(TimeInterval(maxTimelife))
        let result = date.compare(Date()) == .orderedAscending
        log("[CHECK EXPIRATION] expired: \(result) cacheId:\(id) maxTimelife:\(maxTimelife) now: \(Date())")
        return result
    }
    
    public func isFreshData(for id: CacheIdentifier, freshLifeTime: Seconds) -> Bool  {
        return !isDataExpired(for: id, maxTimelife: freshLifeTime)
    }
    
    
    private func add(cacheId: CacheIdentifier, to groupId: CacheGroupId) {
        if var groupCaches = cacheGroup[groupId] {
            groupCaches.append(cacheId)
            log("[ADD TO GROUP] cacheId:\(cacheId) groupID:\(groupId)")
        } else {
            log("[INIT CACHE GROUP] cacheId:\(cacheId) groupID:\(groupId)")
            cacheGroup[groupId] = [cacheId]
        }
    }
    
    public func applyOptions(for groupId: CacheGroupId) {
        guard let options = cacheGroupOptions[groupId], !options.isEmpty, var cacheGroup = cacheGroup[groupId] else { return }
        
        for option in options {
            switch option {
            case .maxGroupCaches(let maxCount):
                log("[OPTION-maxGroupCaches] maxCount:\(maxCount) current: \(cacheGroup.count) groupID:\(groupId)")
                if cacheGroup.count > maxCount { cacheGroup.removeFirst()  }
            }
        }
    }
    
    private func log(_ event: String) {
        guard logEnabled else { return }
        print("🧺 \(event)")
    }
}
