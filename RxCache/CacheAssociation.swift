//
//  CacheAssociation.swift
//  RxCache
//
//  Created by alexej_ne on 11/06/2019.
//  Copyright © 2019 alexeyne. All rights reserved.
//

public struct CacheAssociation<T> {
    
    let id: CacheIdentifier
    let rule: CacheRule
    let groupId: CacheGroupId?
    
    public init(cacheIdentifier: CacheIdentifier, rule: CacheRule, groupId: CacheGroupId? = nil) {
        self.id = cacheIdentifier
        self.rule = rule
        self.groupId = groupId
    }
    
    public init(_ cacheble: Cacheble, rule: CacheRule, groupId: CacheGroupId? = nil) {
        self.init(cacheIdentifier: cacheble.cacheId, rule: rule, groupId: groupId)
    }
}
