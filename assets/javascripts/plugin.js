// Generated by CoffeeScript 1.6.3
(function() {
  var HandlebarsPlugin;

  HandlebarsPlugin = (function() {
    HandlebarsPlugin.refresh_time = 60;

    HandlebarsPlugin.function_backup = {};

    function HandlebarsPlugin() {
      this._override_contextmenu_functions();
      this._init_auto_refresh();
      this._init_hide_show_column();
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

    HandlebarsPlugin.prototype.refresh = function(done) {
      var _this = this;
      if (done == null) {
        done = (function() {
          return _this._reset_auto_refresh();
        });
      }
      return $.ajax({
        url: location.href,
        dataType: 'html',
        success: function(data) {
          return $(data).filter('form').replaceAll('#handlebars-form');
        },
        complete: done
      });
    };

    HandlebarsPlugin.prototype._init_auto_refresh = function() {
      var _this = this;
      return this.refresh_timeout_id = setTimeout(function() {
        return _this.refresh(function() {
          return _this._init_auto_refresh();
        });
      }, HandlebarsPlugin.refresh_time * 1000);
    };

    HandlebarsPlugin.prototype._clear_auto_refresh = function() {
      return clearTimeout(this.refresh_timeout_id);
    };

    HandlebarsPlugin.prototype._reset_auto_refresh = function() {
      this._clear_auto_refresh();
      return this._init_auto_refresh();
    };

    HandlebarsPlugin.prototype._init_hide_show_column = function() {
      return $(document).on('click', '.handlebars .user-name .hide', function(event) {
        var hidden;
        event.preventDefault();
        $(event.target).parents('.handlebars').toggleClass('hidden');
        hidden = $('.handlebars.hidden').map(function(idx, el) {
          return $(el).data('user-id');
        });
        document.cookie = "handlebars-hidden=" + (JSON.stringify(hidden.toArray()).replace(',', '|'));
        if ($(event.target).parents('.handlebars').hasClass('hidden')) {
          return $(event.target).attr('title', $(event.target).prev().text());
        } else {
          return $(event.target).removeAttr('title');
        }
      });
    };

    HandlebarsPlugin.prototype.contextMenuRightClick = function(event) {
      var handlebar, issue_id, target;
      target = $(event.target);
      handlebar = target.closest('.handlebar');
      if (handlebar.length === 0) {
        return HandlebarsPlugin.function_backup.contextMenuRightClick(event);
      } else {
        event.preventDefault();
        issue_id = handlebar.data('issue-id');
        handlebar.parents('form').first().find('.issue-id-placeholder').val(issue_id);
        return contextMenuShow(event);
      }
    };

    HandlebarsPlugin.prototype._override_contextmenu_functions = function() {
      var method, _i, _len, _ref, _results;
      _ref = ["contextMenuRightClick"];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        method = _ref[_i];
        HandlebarsPlugin.function_backup[method] = window[method];
        _results.push(window[method] = this[method]);
      }
      return _results;
    };

    return HandlebarsPlugin;

  })();

  window.handlebarsPlugin = new HandlebarsPlugin();

}).call(this);
