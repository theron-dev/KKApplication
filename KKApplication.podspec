
Pod::Spec.new do |s|


  s.name         = "KKApplication"
  s.version      = "1.0.2"
  s.summary      = "小应用"
  s.description  = "小应用, 原生组建渲染 200k"

  s.homepage     = "https://github.com/hailongz/KKApplication"
  s.license      = "MIT"
  s.author       = { "zhang hailong" => "hailongz@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/hailongz/KKApplication.git", :tag => "#{s.version}" }

  s.vendored_frameworks = 'KKApplication.framework'
  s.requires_arc = true
  s.dependency 'KKView', '~> 1.0.3' 

end
