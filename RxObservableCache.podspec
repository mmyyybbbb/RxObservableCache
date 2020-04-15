Pod::Spec.new do |s|
  s.name             = 'RxObservableCache'
  s.version          = '2.2.0'
  s.summary          = 'Cache for Rx observable'
  s.homepage         = 'https://github.com/BCS-Broker/RxObservableCache'
  s.author           = { "Alexey Nenast'ev" => "a-nenastev@mail.ru" }
  s.source           = { :git => "https://github.com/BCS-Broker/RxObservableCache.git", :tag => s.version.to_s }
  s.license      = 'MIT'
  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'
  s.source_files  = 'RxCache/**/*.{swift}'
  s.dependency 'RxSwift', '~> 5.1.0'
end
