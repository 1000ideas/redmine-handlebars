require 'user_extension'
require 'issue_priority_extension'

Redmine::Plugin.register :handlebars do
  name 'HandleBars plugin'
  author '1000ideas'
  description 'This plugin allow you to see unfinished work by very handle bars'
  version '0.0.8'
  url 'http://1000i.pl'
  author_url 'http://1000i.pl'

  menu :top_menu, :handlebars, {controller: :handlebars, action: :show}, caption: :top_menu_handlebars, before: :projects

  permission :handlebars, {handlebars: :show}, require: :loggedinen
  
  settings default: {'users' => '{}'}, partial: 'handlebars/settings'

end
