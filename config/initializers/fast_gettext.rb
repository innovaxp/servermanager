FastGettext.add_text_domain 'servermanager', :path => 'locale', :type => :po
FastGettext.default_available_locales = ['en','es','it'] 	#all you want to allow
FastGettext.default_text_domain = 'servermanager'

FastGettext.default_locale = 'es'

module Gem;def self.all_load_paths;[];end;end
