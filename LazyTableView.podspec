Pod::Spec.new do |s|
  s.name         = "LazyTableView"
  s.version      = "1.3"
  s.summary      = "LazyTableView can be the greatest degree of simplification of the operation of UITableView, support for remote JSON loading."

  s.description  = <<-DESC
                   1.Automatically load a remote URL of the JSON data, the analysis    
                   of section also mention, allowing users to obtain higher   
                   efficiency with less code.
                   2. manually create the local static cell, you can freely control   
                   the section and cell.
                   3. custom HUD animation when there is no sense of violation and  
                   loading data.
                   LazyTableView can be the greatest degree of simplification of the  
                   operation of UITableView, support for remote JSON loading
                   DESC

  s.homepage     = "https://github.com/sx1989827/LazyTableView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "sx1989827" => "" }
  s.ios.deployment_target = '7.0'
  s.source       = { :git => "https://github.com/sx1989827/LazyTableView.git", :tag => '1.1'}
  s.source_files = "LazyTableView/LazyTableView/*.{h,m}"
  s.resources    = "LazyTableView/LazyTableView/img/*.png"
  s.requires_arc = true
  s.dependency 'MJRefresh'
  s.dependency	        'AFNetworking',"2.6.3"
  s.dependency             'JSONModel'
end