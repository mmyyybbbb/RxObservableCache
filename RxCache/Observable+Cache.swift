//
//  Observable+Cache.swift
//  RxCache
//
//  Created by alexej_ne on 11/06/2019.
//  Copyright © 2019 alexeyne. All rights reserved.
//

import RxSwift

public extension Observable {
    
    func associate(with association: CacheAssociation<Element>) -> Observable<Element> {
        
        let result = Observable<Void>.just(()).flatMap { _ -> Observable<Element> in
            
            let cache = CacheContainer.instanceLazyInit
            let id = association.id
            let groupId = association.groupId
            
            let writeOnNext: (Element) -> Void = { cache.set(data: $0, for: id, in: groupId)  }
            
            func fromCache(with lifeTime: Seconds, or obs: Observable<Element>) -> Observable<Element> {
                guard cache.isFreshData(for: id, freshLifeTime: lifeTime) else {
                    
                    if let shared: Observable<Element> = cache.tryGetSharedObs(for: id) {
                        return shared
                    } else {
                        cache.setSharedObs(data: obs, for: id, in: groupId)
                        return obs
                    } 
                }
                
                if let data: Element = cache.tryGet(for: id) {
                    return .just(data)
                } else if let shared: Observable<Element> = cache.tryGetSharedObs(for: id) {
                    return shared
                } else {
                    cache.setSharedObs(data: obs, for: id, in: groupId)
                    return obs
                }
            }

            let sharedObs = self.share(replay: 1, scope: .whileConnected)
            
            switch association.rule {
            case .writeOnly:
                cache.setSharedObs(data: sharedObs, for: id, in: groupId)
                return sharedObs.do(onNext: writeOnNext)
                
            case let .readOnly(lifeTime):
                return fromCache(with: lifeTime, or: sharedObs)
                
            case let .readWrite(lifeTime):
                return fromCache(with: lifeTime, or: sharedObs.do(onNext: writeOnNext))
            }
        }
        
        return result
    } 
}

public extension Single {
    
    func associate(with association: CacheAssociation<Element>) -> Single<Element> {
        return self.asObservable().take(1).associate(with: association).asSingle()
    }
}
