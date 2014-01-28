class OccupancyPluginSettings
  constructor: ->
    $('#new-occupancy-user').click (event) =>
      event.preventDefault()
      @new_user(event.target)

    $(document).on 'click', '.remove-occupancy-user', (event) =>
      event.preventDefault()
      $(event.target).parents('tr').first().remove()
      @update_json_setting()

    $(document).on 'change', '.occupancy-users select', =>
      @update_json_setting()

    true

  new_user: (link)->
    template = $( $(link).data('template') )
    $(link).prev().find('tbody').append template
    true

  update_json_setting: ->
    manager_users = {}
    $('.occupancy-users tr').each (idx, el) =>
      manager = $('select', el).first().val()
      users = $('select', el).last().val()
      manager_users[manager] = users

    $('#settings_users').val JSON.stringify(manager_users)

jQuery -> (window.occupancyPluginSettings = new OccupancyPluginSettings())