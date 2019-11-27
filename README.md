Swift 5.0 |  [RU_Readme](/README.ru.md)
# RxObservableCache 

Allows you to cache data for Observable 

Cocoapods:
```ruby
pod 'RxObservableCache', '~> 2.0.0'
```

## How to use

### 1. Create object `CacheAssociation<T>` 
This object is used to access the cache, T is the data type for which the cache is created.
Through CacheAssociation, a connection is established with the cache and rules are set for reading / writing to the cache.

```swift
CacheAssociation.init(cacheIdentifier: CacheIdentifier, rule: CacheRule, groupId: CacheGroupId? = nil)
```
+ CacheIdentifier - unique identifier for cached data
+ CacheRule - cache interaction rule

```swift
public enum CacheRule {
    case readOnly(ExpiredAfterSeconds) 
    case readWrite(ExpiredAfterSeconds) 
    case writeOnly
}
// ExpiredAfterSeconds - read the data from the cache only if they live there for no longer than the specified number of seconds
```



BestPractice to create such an object, declare an extension on the `CacheAssociation` type with a constraint on` T`

Example:

```swift
extension CacheAssociation where T == News { 
    static func news(with id: Int, rule: CacheRule) -> CacheAssociation<News> {
        return .init(cacheIdentifier: "\(id)", rule: rule, groupId: nil)
    } 
}
```

### 2. Set `CacheAssociation<T>` on Observable/Single 

```swift 
// somewhere in code 
func loadNews(by id: Int) -> Single<News> { ... }

loadNews(by: id)
  .associate(with: .news(with: id, .readWrite(30))
  .subscribe(onComplete: { ... })
  .disposed(by: bag)

// The handler will first look up the data in the cache by id and if they are there for no longer than 30 seconds, it will return them
// otherwise execute the original `loadNews (by: id)` after it is successful
// data will be written (cacheRule = .readWrite) to the cache.
```

## CacheContainer
For managing caches, use singleton CacheContainer, it allows you to clear all caches, disable caching
whole, or turn on logging.
The current instance is accessible via `CacheContainer.instanceLazyInit`


## CacheGroupId Cache Groups
Caches can be combined into groups. For a group, you can specify a set of options.

Using options you can, for example, limit the number of caches in a group.

```swift  
CacheContainer.instanceLazyInit.set(options: [.maxGroupCaches(5)], for: "news") 

// When creating CacheAssociation, you need to specify a group
extension CacheAssociation where T == News {
     static func news (with id: Int, rule: CacheRule) -> CacheAssociation <News> {
         return .init (cacheIdentifier: "\ (id)", rule: rule, groupId: "news") // specify the group
     }
}

func loadNewsData(for id: Int) {
  loadNews(by: id)
    .associate(with: .news(with: id, .readWrite(30))
    .subscribe(onComplete: { ... })
    .disposed(by: bag)
}
 
loadNewsData(for: 101) 
loadNewsData(for: 102) 
loadNewsData(for: 103) 
loadNewsData(for: 104) 
loadNewsData(for: 105) 
loadNewsData(for: 106)
// There will be 5 caches in memory. If we assume that the requests were executed in order after
// run the last cache for 101 retire
```

 

