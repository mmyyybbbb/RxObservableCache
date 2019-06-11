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
            
            func fromCache(with lifeTime: ReadExpiration, or obs: Observable<Element>) -> Observable<Element> {
                guard cache.isFreshData(for: id, freshLifeTime: lifeTime),
                    let data: Element = cache.tryGet(for: id) else { return obs }
                return .just(data)
            }
            
            switch association.rule {
            case .writeOnly:
                return self.do(onNext: writeOnNext)
                
            case let .readOnly(lifeTime):
                return fromCache(with: lifeTime, or: self)
                
            case let .readWrite(lifeTime):
                return fromCache(with: lifeTime, or: self.do(onNext: writeOnNext))
            }
        }
        
        return result
    } 
}

