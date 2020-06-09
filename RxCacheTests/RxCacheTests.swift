//
//  RxCacheTests.swift
//  RxCacheTests
//
//  Created by alexej_ne on 11/06/2019.
//  Copyright © 2019 alexeyne. All rights reserved.
//
import RxSwift
import RxCocoa
import XCTest
import RxBlocking
@testable import RxCache

class RxCacheTests: XCTestCase {

    let disposeBad = DisposeBag()
    
     var observable: Single<Int> {
        return Observable<Int>.create { (observer) -> Disposable in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                
                let val = Int.random(in: 0...999999)
//                print("push \(val)")
                observer.onNext(val)
                observer.onCompleted()
            }
            return Disposables.create()
        }.asSingle()
    }

    func testExample() {
        CacheContainer.instanceLazyInit.logEnabled = true
        subscribe()
        let shared: Observable<Int>? = CacheContainer.instanceLazyInit.tryGetSharedObs(for: "cache")
        print(shared)
        subscribe()
        let shared2: Observable<Int>? = CacheContainer.instanceLazyInit.tryGetSharedObs(for: "cache")
         print(shared2)
//        let data1 = tryGet()
//        print(data1)
//        let data2 = tryGet()
//        print(data2)
//        sleep(3)
//        let data3 = tryGet()
//        print(data3)//
        let data4 = tryGet()
        let shared4: Observable<Int>? = CacheContainer.instanceLazyInit.tryGetSharedObs(for: "cache")
        print(shared4)
//        print(data4)
    }

    private func tryGet() -> Int? {
        try? observable.associate(with: .init(cacheIdentifier: "cache", rule: .readWrite(3)))
            .toBlocking().first()
    }
    
    private func subscribe() {
        observable.associate(with: .init(cacheIdentifier: "cache", rule: .readWrite(20)))
            .subscribe(onSuccess: { val in  print(val)  })
        .disposed(by: disposeBad)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
