Pod::Spec.new do |s|
  s.name             = 'Arrow'
  s.version          = '0.1.0'
  s.summary          = 'Arrow is dependency management framework '\
                       'generate the auto wired types '\
                       'and create mock'

  s.homepage         = 'https://github.com/AhmedOsman00/Arrow'
  s.license          = 'MIT'
  s.author           = { 'Ahmed Osman' => 'eng.ahmedosman00@gmail.com' }
  s.source           = { :http => 'https://github.com/AhmedOsman00/Arrow.git'}

  s.ios.deployment_target = '12.0'

  s.source_files = 'Sources/**/*.swift'
  s.frameworks = 'Foundation'
  # s.script_phases = [
  #   { 
  #     :name => 'Generate Dependancies File',
  #     :script => './Arrow/arrow.sh PROJECT_DIR PROJECT_FILE_PATH',
  #     :execution_position => :before_compile
  #   }
  # ]
  # s.preserve_paths  = './Arrow/arrow.sh'
end
