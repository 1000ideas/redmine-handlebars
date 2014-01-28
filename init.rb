Redmine::Plugin.register :occupancy do
  name 'Occupancy plugin'
  author '1000Ideas'
  description 'This plugin allow you to see workers occupancy in current time'
  version '0.0.1'
  url 'http://1000i.pl'
  author_url 'http://1000i.pl'

  menu :top_menu, :occupancy, {controller: :occupancies, action: :show}, caption: :top_menu_occupancy, before: :projects

  permission :see_occupancy, {occupancies: :show}, require: :loggedinen
  
  settings default: {'users' => '{}'}, partial: 'occupancies/settings'

end
