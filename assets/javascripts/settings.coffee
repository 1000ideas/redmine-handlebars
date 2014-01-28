class HandlebarsPluginSettings
  constructor: ->
    $('#new-handlebars-user').click (event) =>
      event.preventDefault()
      @new_user(event.target)

    $(document).on 'click', '.remove-handlebars-user', (event) =>
      event.preventDefault()
      $(event.target).parents('tr').first().remove()
      @update_json_setting()

    $(document).on 'change', '.handlebars-users select', =>
      @update_json_setting()

    true

  new_user: (link)->
    template = $( $(link).data('template') )
    $(link).prev().find('tbody').append template
    true

  update_json_setting: ->
    manager_users = {}
    $('.handlebars-users tr').each (idx, el) =>
      manager = $('select', el).first().val()
      users = $('select', el).last().val()
      manager_users[manager] = users

    $('#settings_users').val JSON.stringify(manager_users)

jQuery -> (window.handlebarsPluginSettings = new HandlebarsPluginSettings())