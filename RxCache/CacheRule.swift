//
//  CacheRule.swift
//  RxCache
//
//  Created by alexej_ne on 11/06/2019.
//  Copyright © 2019 alexeyne. All rights reserved.
//

public enum CacheRule {
    case readOnly(ExpiredAfterSeconds)
    case readWrite(ExpiredAfterSeconds)
    case writeOnly
}

