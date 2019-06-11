Pod::Spec.new do |s|
  s.name             = 'RxObservableCache'
  s.version          = '1.0.0'
  s.summary          = 'Cache for Rx observable'
  s.homepage         = 'https://github.com/alexejn/RxObservableCache'
  s.author           = { "Alexey Nenast'ev" => "a-nenastev@mail.ru" }
  s.source           = { :git => "https://github.com/alexejn/RxObservableCache.git", :tag => s.version.to_s }
  s.license      = 'MIT'
  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'
  s.source_files  = 'RxCache/**/*.{swift}'
  s.dependency 'RxSwift', '~> 4.5.0'
end
