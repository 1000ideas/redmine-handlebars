# Handlebars Remine Plugin

Plugin allows you to track current user work. Show in pretty way, by very handle bars, how much work user have to do in current time.

## Instalation
1. Add plugin to your redmine's plugins directory
2. Restart application

## Common installation issues
1. Directory name inside redmine's plugins directory must be `handlebars`.

## Configuration

1. Configure plugin at `/settings/plugin/handlebars`:
  * Setup default user list for handlebars users. Users on the left have access to handlebars subpage. Users on right appears on thier handlebars subpages.
  * Set default feedback status. Issues with that status will by gray out.
2. Enable handlebars module for projects you want to see on handlebars subpage. You can enable it by default. Select `handlebars` plugin in modules list at `/settings?tab=projects`.
3. You can sort or hide users on handlebar list. Hide user by clicking \[-\] (minus) icon. Drag user name on bar header to sort.
4. You can change issue assignement by dragging issue on another user's name.

