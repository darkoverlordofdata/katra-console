#+--------------------------------------------------------------------+
#| consol$e.coffee
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
    KEY_R       = 82    # 'R'
    KEY_S       = 83    # 'S'

    fix = ($text) -> $text.replace(/\n/g, "<br />")

    histpos     : 0     # current place in the history list
    history     : null  # the history list
    input       : null  # the input element
    output      : null  # the output element
    prompt      : null  # the prompt element
    default     :
      autofocus : true  # autofocus the console
      history   : true  # allow history (up/down keys)
      welcome   : ''    # inital message to display
      prompt    : '> '  # standard prompt
      promptAlt : '? '  # alternate prompt
      handle    : ->    # callback to handle input
      break     : ->    # ctrl/c interrupt

    #
    # Create a new console
    #
    # @param  [Object]  DOM Node
    # @param  [Object]  options hash
    # @return [Void]
    #
    constructor: ($container, $options) ->

      $this = @
      $this.history = []
      $options = $.extend(@default, $options)
      $auto = if $options.autofocus then 'autofocus' else ''
      #
      # render the ui
      #
      $container.html """
          <output></output>
          <div id="input-line" class="input-line">
          <div class="prompt"></div><div><input class="cmdline" #{$auto} /></div>
          </div>
        """
      @output = $container.find('output')
      @prompt = $container.find('#input-line .prompt')
      @input = $container.find('#input-line .cmdline')

      @prompt.text $options.prompt
      @print "<div>#{$options.welcome}</div>"

      #
      # pass the focus to input
      #
      $(window).on 'click', ($e) ->
        $this.input.focus()

      #
      # check for interrupt
      #
      $(document.body).on 'keydown', ($e) ->
        if $e.keyCode is KEY_ESC 
          $e.stopPropagation()
          $e.preventDefault()

      #
      # input onclick
      #
      @input.on 'click', ($e) ->
        @value = @value # Sets cursor to end of input.

      #
      # history (up/down)
      #
      @input.on 'keyup', ($e) ->

        return unless $options.history
        $temp = 0

        if $this.history.length
          if $e.keyCode is KEY_UP or $e.keyCode is KEY_DOWN
            if $this.history[$this.histpos]
              $this.history[$this.histpos] = @value
            else
              $temp = @value

          if $e.keyCode is KEY_UP
            $this.histpos--
            if $this.histpos < 0
              $this.histpos = 0

          else if $e.keyCode is KEY_DOWN
            $this.histpos++
            if $this.histpos > $this.history.length
              $this.histpos = $this.history.length

          if $e.keyCode is KEY_UP or $e.keyCode is KEY_DOWN
            @value = if $this.history[$this.histpos] then $this.history[$this.histpos] else $temp
            @value = @value # Sets cursor to end of input.


      #
      # ctrl/key
      #
      @input.on 'keydown',  ($e) ->

        if ($e.ctrlKey or $e.metaKey)
          switch $e.keyCode

            when KEY_C  # CTRL/C - break
              $options.break @
              $e.preventDefault()
              $e.stopPropagation()

            when KEY_R  # CTRL/R - reset
              $this.clear @
              $e.preventDefault()
              $e.stopPropagation()

            when KEY_S
              $container.toggleClass('flicker')
              $e.preventDefault()
              $e.stopPropagation()

      #
      # Enter
      #
      @input.on 'keydown', ($e) ->

        switch $e.keyCode

          when KEY_BS
            return if not @value

          when KEY_TAB
            $e.preventDefault

          when KEY_CR
            if @value
              $this.history[$this.history.length] = @value
              $this.histpos = $this.history.length

            # Duplicate current input and append to output section.
            $line = @parentNode.parentNode.cloneNode(true)
            $line.removeAttribute 'id'
            $line.classList.add 'line'
            $input = $line.querySelector('input.cmdline')
            $input.autofocus = false
            $input.readOnly = true
            $this.output.append $line

            if (@value and @value.trim())
              $options.handle @value
            @value = '' # Clear/setup line for next input.



    #
    # Clear the console
    #
    # @param  [String]  html string
    # @return [Void]
    #
    clear: ($input) ->
      @output.html ''
      $input.value = ''

    #
    # Set the console prompt
    #
    # @param  [Number]  prompt selector
    # @return [Void]
    #
    prompt: ($prompt=0) ->
      if $prompt is 0
        @prompt.text $options.prompt
      else
        @prompt.text $options.promptAlt

    #
    # Print string to output
    #
    # @param  [String]  html string
    # @return [Void]
    #
    print: ($text='') ->
      @output.append fix($text)
      @input.get(0).scrollIntoView()

    #
    # Print string to output
    #
    # @param  [String]  html string
    # @return [Void]
    #
    println: ($text='') ->
      @print "#{$text}\n"

    debug: ($text) ->
      @println "<span style=\"color: blue;\">#{$text}</span>"

    highlight: ($text) ->
      @println "<span style=\"color: yellow;\">#{$text}</span>"
