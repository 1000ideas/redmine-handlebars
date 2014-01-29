// Generated by CoffeeScript 1.6.3
(function() {
  var HandlebarsPlugin;

  HandlebarsPlugin = (function() {
    HandlebarsPlugin.function_backup = {};

    function HandlebarsPlugin() {
      this._override_contextmenu_functions();
      $(document).tooltip({
        items: "[data-tooltip]",
        track: true,
        hide: false,
        content: function() {
          return $(this).data('tooltip');
        }
      });
      true;
    }

    HandlebarsPlugin.prototype.contextMenuRightClick = function(event) {
      var handlebar, issue_id, target;
      target = $(event.target);
      handlebar = target.closest('.handlebar');
      if (handlebar.length === 0) {
        return HandlebarsPlugin.function_backup.contextMenuRightClick(event);
      } else {
        event.preventDefault();
        issue_id = handlebar.data('issue-id');
        handlebar.parents('form').first().find('#ids').val(issue_id);
        return contextMenuShow(event);
      }
    };

    HandlebarsPlugin.prototype._override_contextmenu_functions = function() {
      var method, _i, _len, _ref, _results;
      _ref = ["contextMenuRightClick"];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        method = _ref[_i];
        console.log("replace " + method);
        HandlebarsPlugin.function_backup[method] = window[method];
        _results.push(window[method] = this[method]);
      }
      return _results;
    };

    return HandlebarsPlugin;

  })();

  window.handlebarsPlugin = new HandlebarsPlugin();

}).call(this);
