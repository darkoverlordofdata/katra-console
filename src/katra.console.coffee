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

    KEY_BS    = 8
    KEY_TAB   = 9
    KEY_CR    = 13
    KEY_ESC   = 27
    KEY_UP    = 38
    KEY_DOWN  = 40
    KEY_C     = 67
    KEY_S     = 83

    _histpos    = 0
    _history    = []
    _input      = null
    _output     = null

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
        @value = @value

      #
      # ctrl/key
      #
      _input.on 'keydown',  (e) ->

        if (e.ctrlKey or e.metaKey) and e.keyCode is KEY_S  # crtl+s
          $container.toggleClass('flicker')
          output '<div>Screen flicker: ' +
          (if $container.hasClass('flicker') then 'on' else 'off') + '</div>'
          e.preventDefault()
          e.stopPropagation()

      #
      # history (up/down)
      #
      _input.on 'keyup', (e) -> # Tab needs to be keydown.

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
      # Enter
      #
      _input.on 'keydown', (e) ->

        # Backspace and no value on command line.
        return if not @value and e.keyCode is KEY_BS

        if e.keyCode is KEY_TAB
          e.preventDefault

        else if e.keyCode is KEY_CR

          # Save shell _history.
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



