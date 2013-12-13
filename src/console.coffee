#+--------------------------------------------------------------------+
#| console.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2013
#+--------------------------------------------------------------------+
#|
#| This file is a part of Katra
#|
#| Katra is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
# jQuery console plugin
#

#
# Define a plugin
#
# @param  [Object]  jQuery
# @param  [object]  window
# @param  [object]  document
# @return [Void]
#
do ($ = jQuery, window, document) ->


  #
  # Console Plugin
  #
  # @param  [Object]  options hash
  # @return [Object]  the plugin
  #
  $::console = ($options = {}) ->

    $.data(@, 'console') ? $.data(@, 'console', new Console(@, $options))


  class Console

    KEY_BS      = 8     # Backspace
    KEY_TAB     = 9     # Tab
    KEY_CR      = 13    # Enter
    KEY_ESC     = 27    # Escape
    KEY_UP      = 38    # Up Arrow
    KEY_DOWN    = 40    # Down Arrow
    KEY_C       = 67    # 'C'
    KEY_S       = 83    # 'S'

    _histpos    = 0     # current place in the history list
    _history    = []    # the history list
    _input      = null  # the input element
    _output     = null  # the output element

    #
    # Print string to output
    #
    # @param  [String]  html string
    # @return [Void]
    #
    output = (html) ->
      _output.append html
      _input.get(0).scrollIntoView()

    #
    # Create a new console
    #
    # @param  [Object]  DOM Node
    # @param  [Object]  options hash
    # @return [Void]
    #
    constructor: ($container, $options) ->

      #
      # render the console ui
      #
      $container.html """
          <output></output>
          <div id="input-line" class="input-line">
          <div class="prompt">$&gt;</div><div><input class="cmdline" autofocus /></div>
          </div>
        """
      _input = $container.find('#input-line .cmdline')
      _output = $container.find('output')

      #
      # pass the focus to input
      #
      $(window).on 'click', (e) ->
        _input.focus()

      #
      # check for interrupt
      #
      $(document.body).on 'keydown', (e) ->
        if e.keyCode is KEY_ESC 
          e.stopPropagation()
          e.preventDefault()

      #
      # input onclick
      #
      _input.on 'click',  (e) ->
        @value = @value # Sets cursor to end of input.

      #
      # history (up/down)
      #
      _input.on 'keyup', (e) ->

        $temp   = 0

        if _history.length
          if e.keyCode is KEY_UP or e.keyCode is KEY_DOWN
            if _history[_histpos]
              _history[_histpos] = @value
            else
              $temp = @value

          if e.keyCode is KEY_UP
            _histpos--
            if _histpos < 0
              _histpos = 0

          else if e.keyCode is KEY_DOWN
            _histpos++
            if _histpos > _history.length
              _histpos = _history.length

          if e.keyCode is KEY_UP or e.keyCode is KEY_DOWN
            @value = if _history[_histpos] then _history[_histpos] else $temp
            @value = @value # Sets cursor to end of input.


      #
      # ctrl/key
      #
      _input.on 'keydown',  (e) ->

        if (e.ctrlKey or e.metaKey)
          switch e.keyCode

            when KEY_C

            when KEY_S
              $container.toggleClass('flicker')
              e.preventDefault()
              e.stopPropagation()

      #
      # Enter
      #
      _input.on 'keydown', (e) ->

        switch e.keyCode

          when KEY_BS
            return if not @value

          when KEY_TAB
            e.preventDefault

          when KEY_CR
            if @value
              _history[_history.length] = @value
              _histpos = _history.length

            # Duplicate current input and append to output section.
            line = @parentNode.parentNode.cloneNode(true)
            line.removeAttribute 'id'
            line.classList.add 'line'
            input = line.querySelector('input.cmdline')
            input.autofocus = false
            input.readOnly = true
            _output.append line

            # Parse out command, args, and trim off whitespace.
            if (@value and @value.trim())
              args = @value.split(' ').filter((val, i) -> val)
              cmd = args[0].toLowerCase()
              args = args.splice(1) # Remove cmd from arg list.

            output cmd
            @value = '' # Clear/setup line for next input.


      output "<div>#{$options.welcome}</div>"

    clear: ($input) ->
      _output.html ''
      $input.value = ''



