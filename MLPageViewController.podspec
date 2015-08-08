Pod::Spec.new do |s|
s.name         = "MLPageViewController"
s.version      = "1.0.0"
s.summary      = "MLPageViewController"

s.homepage     = 'https://github.com/molon/MLPageViewController'
s.license      = { :type => 'MIT'}
s.author       = { "molon" => "dudl@qq.com" }

s.source       = {
:git => "https://github.com/molon/MLPageViewController.git",
:tag => "#{s.version}"
}

s.platform     = :ios, '7.0'
s.public_header_files = 'Classes/**/*.h'
s.source_files  = 'Classes/**/*.{h,m}'
s.resource = "Classes/**/*.bundle"
s.requires_arc  = true

end
