name             'CLM'
maintainer       'Liora Milbaum'
maintainer_email 'liora@lmb.co.il'
license          'MIT'
description      'CLM'
long_description 'CLM'
version          '0.0.1'

%w{ java7 libarchive IM python}.each do |cookbook|
  depends cookbook
end

supports 'ubuntu'

