class HandlebarsPlugin
  #refresh time in seconds
  @refresh_time = 60

  @function_backup = {}
  
  constructor: ->
    @_override_contextmenu_functions()
    @_init_auto_refresh()
    @_init_hide_show_column()


    $(document).tooltip
      items: "[data-tooltip]"
      track: true
      hide: false
      content: ->
        $(this).data('tooltip')
    true

  refresh: (done = (=> @_reset_auto_refresh()) )->
    $.ajax
      url: location.href
      dataType: 'html'
      success: (data) ->
        $(data).filter('form').replaceAll('#handlebars-form')
      complete: done

  _init_auto_refresh: ->
    @refresh_timeout_id = setTimeout(
      =>
        @refresh =>
          @_init_auto_refresh()        
      HandlebarsPlugin.refresh_time*1000
    )

  _clear_auto_refresh: ->
    clearTimeout(@refresh_timeout_id)

  _reset_auto_refresh: ->
    @_clear_auto_refresh()
    @_init_auto_refresh()

  _init_hide_show_column: ->
    $(document).on 'click', '.handlebars .user-name .hide', (event) ->
      event.preventDefault()
      
      $(event.target).parents('.handlebars').toggleClass('hidden')


      hidden = $('.handlebars.hidden').map (idx, el) ->
        $(el).data('user-id')

      document.cookie = "handlebars-hidden=#{JSON.stringify(hidden.toArray()).replace(',', '|')}"

      if $(event.target).parents('.handlebars').hasClass('hidden')
        $(event.target).attr('title', $(event.target).prev().text())
      else
        $(event.target).removeAttr('title')



  contextMenuRightClick: (event) ->
    target = $(event.target)
    handlebar = target.closest('.handlebar')
    if handlebar.length == 0
      HandlebarsPlugin.function_backup.contextMenuRightClick(event)
    else
      event.preventDefault()
      issue_id = handlebar.data('issue-id')
      handlebar.parents('form').first().find('.issue-id-placeholder').val(issue_id)
      contextMenuShow(event);

  _override_contextmenu_functions: ->
    for method in ["contextMenuRightClick"]
      HandlebarsPlugin.function_backup[method] = window[method]
      window[method] = @[method]

window.handlebarsPlugin = new HandlebarsPlugin()