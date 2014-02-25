class HandlebarsPlugin
  #refresh time in seconds
  @refresh_time = 60

  @function_backup = {}

  constructor: ->
    @_override_contextmenu_functions()
    @_init_auto_refresh()
    @_init_hide_show_column()
    @_init_selectable()


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

  hide_user: (id) ->
    name = $(".handlebars[data-user-id=#{id}]")
      .addClass('hidden')
      .find('h3')
      .text()

    $('<li>')
      .attr('data-user-id', id)
      .append( $('<a>').attr('href', '#').addClass('show-user').text(name) )
      .appendTo('.hidden-handlebars-users ul')

    if $(".hidden-handlebars-users ul li").length > 0
      $(".hidden-handlebars-users").removeClass('hide')

    @set_hidden_users_cookie()

  show_user: (id) ->
    $(".handlebars[data-user-id=#{id}]")
      .removeClass('hidden')

    $(".hidden-handlebars-users ul li[data-user-id=#{id}]")
      .remove()

    if $(".hidden-handlebars-users ul li").length == 0
      $(".hidden-handlebars-users").addClass('hide')

    @set_hidden_users_cookie()

  set_hidden_users_cookie: ->
    hidden = $('.hidden-handlebars-users ul li').map (idx, el) ->
      $(el).data('user-id')

    document.cookie = "handlebars-hidden=#{JSON.stringify(hidden.toArray()).replace(',', '|')}"


  _init_hide_show_column: ->
    $(document).on 'click', '.handlebars .user-name .hide', (event) =>
      event.preventDefault()
      @hide_user $(event.target).parents('.handlebars').data('user-id')

    $(document).on 'click', '.hidden-handlebars-users', (event) =>
      event.preventDefault();
      @show_user $(event.target).parent().data('user-id')

  unselect_all_issues: ->
    $('.hascontextmenu').removeClass('selected')
    $('#handlebars-form input[name="ids[]"]').remove()

  click_on_issue: (id, ctrl = false, left = false) ->

    selected_count = $('.hascontextmenu.selected').length
    handlebar = $("[data-issue-id=#{id}]")
    form = handlebar.closest('form')

    unless ctrl or left
      # if selected_count > 0
      @unselect_all_issues()
    if left
      unless handlebar.hasClass('selected')
        @unselect_all_issues()
      handlebar.addClass('selected')
    else
      handlebar.toggleClass('selected')

    input = form.find("input[type=hidden][value=#{id}]")
    if handlebar.hasClass('selected') and input.length == 0
      input = $('<input>')
        .attr('type', 'hidden')
        .attr('value', id)
        .attr('name', 'ids[]')
      form.prepend input
    else if !handlebar.hasClass('selected')
      input.remove()

    true

  _init_selectable: ->
    $(document).on 'click', '.handlebars .hascontextmenu', (event) =>
      unless $(event.target).is('a')
        event.preventDefault()
      @click_on_issue $(event.target).closest('[data-issue-id]').data('issue-id'), event.ctrlKey

    $(document).on 'click', (event) =>
      if $(event.target).closest('.hascontextmenu').length == 0
        @unselect_all_issues()


  contextmenu:
    contextMenuRightClick: (event) ->
      target = $(event.target)
      handlebar = target.closest('.handlebar')
      if handlebar.length == 0
        HandlebarsPlugin.function_backup.contextMenuRightClick(event)
      else
        event.preventDefault()
        window.handlebarsPlugin.click_on_issue handlebar.data('issue-id'), event.ctrlKey, true
        contextMenuShow(event);

  _override_contextmenu_functions: ->
    for method in ["contextMenuRightClick"]
      HandlebarsPlugin.function_backup[method] = window[method]
      window[method] = @contextmenu[method]

window.handlebarsPlugin = new HandlebarsPlugin()
