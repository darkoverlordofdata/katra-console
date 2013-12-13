// Generated by CoffeeScript 1.6.3
(function($, window, document) {
  var Console;
  $.prototype.console = function($options) {
    var _ref;
    if ($options == null) {
      $options = {};
    }
    return (_ref = $.data(this, 'console')) != null ? _ref : $.data(this, 'console', new Console(this, $options));
  };
  return Console = (function() {
    var KEY_BS, KEY_C, KEY_CR, KEY_DOWN, KEY_ESC, KEY_S, KEY_TAB, KEY_UP, output, _history, _histpos, _input, _output;

    KEY_BS = 8;

    KEY_TAB = 9;

    KEY_CR = 13;

    KEY_ESC = 27;

    KEY_UP = 38;

    KEY_DOWN = 40;

    KEY_C = 67;

    KEY_S = 83;

    _histpos = 0;

    _history = [];

    _input = null;

    _output = null;

    output = function(html) {
      _output.append(html);
      return _input.get(0).scrollIntoView();
    };

    function Console($container, $options) {
      $container.html("<output></output>\n<div id=\"input-line\" class=\"input-line\">\n<div class=\"prompt\">$&gt;</div><div><input class=\"cmdline\" autofocus /></div>\n</div>");
      _input = $container.find('#input-line .cmdline');
      _output = $container.find('output');
      $(window).on('click', function(e) {
        return _input.focus();
      });
      $(document.body).on('keydown', function(e) {
        if (e.keyCode === KEY_ESC) {
          e.stopPropagation();
          return e.preventDefault();
        }
      });
      _input.on('click', function(e) {
        return this.value = this.value;
      });
      _input.on('keydown', function(e) {
        if ((e.ctrlKey || e.metaKey) && e.keyCode === KEY_S) {
          $container.toggleClass('flicker');
          output('<div>Screen flicker: ' + ($container.hasClass('flicker') ? 'on' : 'off') + '</div>');
          e.preventDefault();
          return e.stopPropagation();
        }
      });
      _input.on('keyup', function(e) {
        var $temp;
        $temp = 0;
        if (_history.length) {
          if (e.keyCode === KEY_UP || e.keyCode === KEY_DOWN) {
            if (_history[_histpos]) {
              _history[_histpos] = this.value;
            } else {
              $temp = this.value;
            }
          }
          if (e.keyCode === KEY_UP) {
            _histpos--;
            if (_histpos < 0) {
              _histpos = 0;
            }
          } else if (e.keyCode === KEY_DOWN) {
            _histpos++;
            if (_histpos > _history.length) {
              _histpos = _history.length;
            }
          }
          if (e.keyCode === KEY_UP || e.keyCode === KEY_DOWN) {
            this.value = _history[_histpos] ? _history[_histpos] : $temp;
            return this.value = this.value;
          }
        }
      });
      _input.on('keydown', function(e) {
        var args, cmd, input, line;
        switch (e.keyCode) {
          case KEY_BS:
            if (!this.value) {

            }
            break;
          case KEY_TAB:
            return e.preventDefault;
          case KEY_CR:
            if (this.value) {
              _history[_history.length] = this.value;
              _histpos = _history.length;
            }
            line = this.parentNode.parentNode.cloneNode(true);
            line.removeAttribute('id');
            line.classList.add('line');
            input = line.querySelector('input.cmdline');
            input.autofocus = false;
            input.readOnly = true;
            _output.append(line);
            if (this.value && this.value.trim()) {
              args = this.value.split(' ').filter(function(val, i) {
                return val;
              });
              cmd = args[0].toLowerCase();
              args = args.splice(1);
            }
            output(cmd);
            return this.value = '';
        }
      });
      output("<div>" + $options.welcome + "</div>");
    }

    Console.prototype.clear = function($input) {
      _output.html('');
      return $input.value = '';
    };

    return Console;

  })();
})(jQuery, window, document);
