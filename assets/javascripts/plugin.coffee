class HandlebarsPlugin
  @function_backup = {}
  
  constructor: ->
    @_override_contextmenu_functions()

    $(document).tooltip
      items: "[data-tooltip]"
      track: true
      hide: false
      content: ->
        $(this).data('tooltip')
    true

  contextMenuRightClick: (event) ->
    target = $(event.target)
    handlebar = target.closest('.handlebar')
    if handlebar.length == 0
      HandlebarsPlugin.function_backup.contextMenuRightClick(event)
    else
      event.preventDefault()
      issue_id = handlebar.data('issue-id')
      handlebar.parents('form').first().find('#ids').val(issue_id)
      contextMenuShow(event);

  _override_contextmenu_functions: ->
    for method in ["contextMenuRightClick"]
      console.log("replace #{method}")
      HandlebarsPlugin.function_backup[method] = window[method]
      window[method] = @[method]

window.handlebarsPlugin = new HandlebarsPlugin()