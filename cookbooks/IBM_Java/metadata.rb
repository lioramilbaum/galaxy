name             'IBM_Java'
maintainer       'L.M.B.-Consulting Ltd.'
maintainer_email 'liora@lmb.co.il'
license          'All rights reserved'
description      'Installs/Configures IBM_Java'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.1'

%w{ libarchive }.each do |cookbook|
  depends cookbook
end

supports 'ubuntu'
