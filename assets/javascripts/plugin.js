// Generated by CoffeeScript 1.6.3
(function() {
  var HandlebarsPlugin;

  HandlebarsPlugin = (function() {
    HandlebarsPlugin.refresh_time = 60;

    HandlebarsPlugin.function_backup = {};

    function HandlebarsPlugin() {
      var _this = this;
      this._override_contextmenu_functions();
      this._init_auto_refresh();
      this._init_hide_show_column();
      this._init_selectable();
      jQuery(function() {
        _this._init_sortable();
        return _this._init_drag_n_drop_assigment();
      });
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
          $(data).filter('form').replaceAll('#handlebars-form');
          _this._init_drag_n_drop_assigment();
          return _this._init_sortable();
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

    HandlebarsPlugin.prototype.hide_user = function(id) {
      var name;
      name = $(".handlebars[data-user-id=" + id + "]").addClass('hidden').find('h3').text();
      $('<li>').attr('data-user-id', id).append($('<a>').attr('href', '#').addClass('show-user').text(name)).appendTo('.hidden-handlebars-users ul');
      if ($(".hidden-handlebars-users ul li").length > 0) {
        $(".hidden-handlebars-users").removeClass('hide');
      }
      return this.set_hidden_users_cookie();
    };

    HandlebarsPlugin.prototype.show_user = function(id) {
      $(".handlebars[data-user-id=" + id + "]").removeClass('hidden');
      $(".hidden-handlebars-users ul li[data-user-id=" + id + "]").remove();
      if ($(".hidden-handlebars-users ul li").length === 0) {
        $(".hidden-handlebars-users").addClass('hide');
      }
      return this.set_hidden_users_cookie();
    };

    HandlebarsPlugin.prototype.set_hidden_users_cookie = function() {
      var exdate, hidden;
      hidden = $('.hidden-handlebars-users ul li').map(function(idx, el) {
        return $(el).data('user-id');
      });
      exdate = new Date();
      exdate.setDate(exdate.getDate() + 356);
      return document.cookie = "handlebars-hidden=" + (JSON.stringify(hidden.toArray()).replace(/,/g, '|')) + "; expires=" + (exdate.toUTCString());
    };

    HandlebarsPlugin.prototype.set_users_order_cookie = function() {
      var exdate, users;
      users = $('.handlebars-table .handlebars').map(function(idx, el) {
        return $(el).data('user-id');
      });
      exdate = new Date();
      exdate.setDate(exdate.getDate() + 356);
      return document.cookie = "handlebars-order=" + (JSON.stringify(users.toArray()).replace(/,/g, '|')) + "; expires=" + (exdate.toUTCString());
    };

    HandlebarsPlugin.prototype._init_hide_show_column = function() {
      var _this = this;
      $(document).on('click', '.handlebars .user-name .hide', function(event) {
        event.preventDefault();
        return _this.hide_user($(event.target).parents('.handlebars').data('user-id'));
      });
      return $(document).on('click', '.hidden-handlebars-users', function(event) {
        event.preventDefault();
        return _this.show_user($(event.target).parent().data('user-id'));
      });
    };

    HandlebarsPlugin.prototype.unselect_all_issues = function() {
      $('.hascontextmenu').removeClass('selected');
      return $('#handlebars-form input[name="ids[]"]').remove();
    };

    HandlebarsPlugin.prototype.click_on_issue = function(id, ctrl, left) {
      var form, handlebar, input, selected_count;
      if (ctrl == null) {
        ctrl = false;
      }
      if (left == null) {
        left = false;
      }
      selected_count = $('.hascontextmenu.selected').length;
      handlebar = $("[data-issue-id=" + id + "]");
      form = handlebar.closest('form');
      if (!(ctrl || left)) {
        this.unselect_all_issues();
      }
      if (left) {
        if (!handlebar.hasClass('selected')) {
          this.unselect_all_issues();
        }
        handlebar.addClass('selected');
      } else {
        handlebar.toggleClass('selected');
      }
      input = form.find("input[type=hidden][value=" + id + "]");
      if (handlebar.hasClass('selected') && input.length === 0) {
        input = $('<input>').attr('type', 'hidden').attr('value', id).attr('name', 'ids[]');
        form.prepend(input);
      } else if (!handlebar.hasClass('selected')) {
        input.remove();
      }
      return true;
    };

    HandlebarsPlugin.prototype._init_drag_n_drop_assigment = function() {
      var _this = this;
      $('.handlebar').draggable({
        distance: 10,
        revert: 'invalid',
        zIndex: 999,
        helper: 'clone',
        appendTo: 'body',
        cursorAt: {
          left: -5,
          top: -5
        },
        start: function() {
          return _this._clear_auto_refresh();
        },
        stop: function() {
          return _this._init_auto_refresh();
        }
      });
      return $('.handlebars .user-name').droppable({
        accept: function(element) {
          return element.hasClass('handlebar') && $(this).siblings().filter(element).length === 0;
        },
        activeClass: 'ui-droppable-active',
        hoverClass: 'ui-droppable-hover',
        tolerance: 'pointer',
        drop: function(event, ui) {
          var assignee, issue, link, params;
          assignee = $(event.target).parent().data('user-id');
          issue = $(ui.draggable).data('issue-id');
          params = $.param({
            back_url: location.href,
            ids: [issue],
            issue: {
              assigned_to_id: assignee
            }
          });
          link = $('<a>').attr('href', "/issues/bulk_update?" + params).data('method', 'post');
          return $.rails.handleMethod(link);
        }
      });
    };

    HandlebarsPlugin.prototype._init_selectable = function() {
      var _this = this;
      $(document).on('click', '.handlebars .hascontextmenu', function(event) {
        if (!$(event.target).is('a')) {
          event.preventDefault();
        }
        return _this.click_on_issue($(event.target).closest('[data-issue-id]').data('issue-id'), event.ctrlKey);
      });
      return $(document).on('click', function(event) {
        if ($(event.target).closest('.hascontextmenu').length === 0) {
          return _this.unselect_all_issues();
        }
      });
    };

    HandlebarsPlugin.prototype._init_sortable = function() {
      var _this = this;
      return $('.handlebars-table').sortable({
        handle: '.user-name h3',
        items: '.handlebars',
        start: function() {
          return _this._clear_auto_refresh();
        },
        stop: function() {
          return _this._init_auto_refresh();
        },
        update: function(event, ui) {
          return _this.set_users_order_cookie();
        }
      });
    };

    HandlebarsPlugin.prototype.contextmenu = {
      contextMenuRightClick: function(event) {
        var handlebar, target;
        target = $(event.target);
        handlebar = target.closest('.handlebar');
        if (handlebar.length === 0) {
          return HandlebarsPlugin.function_backup.contextMenuRightClick(event);
        } else {
          event.preventDefault();
          window.handlebarsPlugin.click_on_issue(handlebar.data('issue-id'), event.ctrlKey, true);
          return contextMenuShow(event);
        }
      }
    };

    HandlebarsPlugin.prototype._override_contextmenu_functions = function() {
      var method, _i, _len, _ref, _results;
      _ref = ["contextMenuRightClick"];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        method = _ref[_i];
        HandlebarsPlugin.function_backup[method] = window[method];
        _results.push(window[method] = this.contextmenu[method]);
      }
      return _results;
    };

    return HandlebarsPlugin;

  })();

  window.handlebarsPlugin = new HandlebarsPlugin();

}).call(this);
