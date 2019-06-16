Swift 5.0
# RxObservableCache 

Позволяет кешировать данные для Observable 

Cocoapods:
```ruby
pod 'RxObservableCache', '~> 1.0.6'
```

## Как использовать

### 1. Создать объект `CacheAssociation<T>` 
Этот объект используется для доступа к кешу, T - тип данные для которых создается кеш. 
Через CacheAssociation устанавливается связь с кешом и задаются правила на чтение/запись в кеш

```swift
CacheAssociation.init(cacheIdentifier: CacheIdentifier, rule: CacheRule, groupId: CacheGroupId? = nil)
```
+ CacheIdentifier - уникальный идентификатор для кешируемых данных
+ CacheRule - правила взаимодействия с кешом

```swift
public enum CacheRule {
    case readOnly(ExpiredAfterSeconds) 
    case readWrite(ExpiredAfterSeconds) 
    case writeOnly
}
// ExpiredAfterSeconds - читать данные из кеша только если они живут там не дольше заданного количества секунд
```



BestPractice для создания такого объекта, объявить extension на типе `CacheAssociation` с ограничением на `Т`

Пример:

```swift
extension CacheAssociation where T == News { 
    static func news(with id: Int, rule: CacheRule) -> CacheAssociation<News> {
        return .init(cacheIdentifier: "\(id)", rule: rule, groupId: nil)
    } 
}
```

### 2. Установить `CacheAssociation<T>` на Observable или Single 

```swift 
// somewhere in code 
func loadNews(by id: Int) -> Single<News> { ... }

loadNews(by: id)
  .associate(with: .news(with: id, .readWrite(30))
  .subscribe(onComplete: { ... })
  .disposed(by: bag)

// Обработчик сперва по id будет искать данные в кеше и если они лежат там не дольше 30 секунд, вернет их,
// иначе выполниться оригинальный `loadNews(by: id)` после его успешного
// выполенния данные запишутся (cacheRule = .readWrite) в кеш. 
```

## CacheContainer
Для управления кэшами служит singleton CacheContainer, он позволяет очистить все кеши, отключить кеширование 
целиком, или включить логировние. 
Текущий экземпляр доступен через `CacheContainer.instanceLazyInit`


## Группы кешей `CacheGroupId`
Кеши можно объединять в группы. Для группы можно указать набор опций. 

С помощью опций можно, например, ограничить количеcтво кешей в группе. 

```swift  
CacheContainer.instanceLazyInit.set(options: [.maxGroupCaches(5)], for: "news") 

// При создании  CacheAssociation нужно указать группу 
extension CacheAssociation where T == News { 
    static func news(with id: Int, rule: CacheRule) -> CacheAssociation<News> {
        return .init(cacheIdentifier: "\(id)", rule: rule, groupId: "news") // указываем группу
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
// В памяти будет 5 кешей. Если считать что запросы были выполнены по-порядку то после
//выполнения последнего кеш для 101 удалиться 
```

 

