#!/usr/bin/env ruby
resources = "#{ENV["BUILT_PRODUCTS_DIR"]}/#{ENV["UNLOCALIZED_RESOURCES_FOLDER_PATH"]}"
`ln -sfh "pt-BR.lproj" "#{resources}/pt.lproj"`
