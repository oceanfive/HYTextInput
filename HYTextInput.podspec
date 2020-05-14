Pod::Spec.new do |s|
  s.name             = 'HYTextInput'
  s.version          = '0.0.4'
  s.summary          = 'HYTextInput'
  s.description      = <<-DESC
OC 中的文字输入，封装了一些常用的功能
                       DESC
  s.homepage         = 'https://github.com/oceanfive/HYTextInput'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'oceanfive' => '849638313@qq.com' }
  s.source           = { :git => 'https://github.com/oceanfive/HYTextInput.git', :tag => s.version.to_s }
  s.ios.deployment_target = '7.0'
  s.source_files = 'HYTextInput/Classes/**/*'
  s.frameworks = 'UIKit'
end
