#+--------------------------------------------------------------------+
#| katra.console.coffee
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

    fix = ($text) -> $text.replace(/\ /g, "&nbsp;").replace(/\n/g, "<br />")

    histpos     : 0     # current place in the history list
    history     : null  # the history list
    kb          : null  # the kb element
    output      : null  # the output element
    prompt      : null  # the prompt element
    default     :
      autofocus : true  # autofocus the console
      history   : true  # allow history (up/down keys)
      welcome   : ''    # inital message to display
      prompt    : '> '  # standard prompt
      promptAlt : '? '  # alternate prompt
      commandHandle: -> # callback to handle kb input
      cancelHandle: ->  # ctrl/c interrupt

    #
    # Create a new console
    #
    # @param  [Object]  DOM Node
    # @param  [Object]  options hash
    # @return [Void]
    #
    constructor: ($container, $options) ->

      $this = @
      @history = []
      @options = $options = $.extend(@default, $options)
      #
      # render the ui
      #

      $container.html """
          <span class="output"></span>
          <span class="enter">
          <span class="prompt"></span><span contenteditable class="input"></span>
          </span>
        """
      @output = $container.find('.output')
      @prompt = $container.find('span .prompt')
      @kb = $container.find('span .input')
      @kb.focus() if $options.autofocus

      @prompt.text $options.prompt
      @print "<div>#{$options.welcomeMessage}</div>"

      #
      # pass the focus to input
      #
      $(window).on 'click', ($e) =>
        @kb.focus()

      #
      # check for interrupt
      #
      $(document.body).on 'keydown', ($e) =>
        if $e.keyCode is KEY_ESC 
          $e.stopPropagation()
          $e.preventDefault()

      #
      # kb onclick
      #
      @kb.on 'click', ($e) =>
        @kb.text @kb.text() # Sets cursor to end of input.

      #
      # history (up/down)
      #
      @kb.on 'keyup', ($e) =>

        return unless $options.history
        $temp = 0

        if @history.length
          if $e.keyCode is KEY_UP or $e.keyCode is KEY_DOWN
            if @history[@histpos]
              @history[@histpos] = @kb.text()
            else
              $temp = @kb.text()

          if $e.keyCode is KEY_UP
            @histpos--
            if @histpos < 0
              @histpos = 0

          else if $e.keyCode is KEY_DOWN
            @histpos++
            if @histpos > @history.length
              @histpos = @history.length

          if $e.keyCode is KEY_UP or $e.keyCode is KEY_DOWN
            @kb.text(if @history[@histpos] then @history[@histpos] else $temp)
            @kb.text @kb.text() # Sets cursor to end of input.


      #
      # ctrl/key
      #
      @kb.on 'keydown', ($e) =>

        if ($e.ctrlKey or $e.metaKey)
          switch $e.keyCode

            when KEY_C  # CTRL/C - break
              $options.cancelHandle()
              $e.preventDefault()
              $e.stopPropagation()

            when KEY_R  # CTRL/R - reset
              @clear()
              $e.preventDefault()
              $e.stopPropagation()

            when KEY_S
              $container.toggleClass('flicker')
              $e.preventDefault()
              $e.stopPropagation()

      #
      # Enter
      #
      @kb.on 'keydown', ($e) =>

        switch $e.keyCode

          when KEY_BS
            return if not @kb.text()

          when KEY_TAB
            $e.preventDefault

          when KEY_CR
            if @kb.text()
              @history[@history.length] = @kb.text()
              @histpos = @history.length

            # Duplicate current input and append to output section.
            @output.append @kb.text()+"<br />"
            @kb.get(0).scrollIntoView()

            if (@kb.text() and @kb.text().trim())
              $options.commandHandle @kb.text()
            @kb.text('') # Clear/setup line for next input.



    #
    # Clear the console
    #
    # @return [Void]
    #
    clear: () ->
      @output.html ''

    #
    # Set the console prompt
    #
    # @param  [Number]  prompt selector
    # @return [Void]
    #
    setPrompt: ($prompt=false) ->
      @prompt.text if $prompt then @options.promptAlt else @options.prompt

    #
    # Print string to output
    #
    # @param  [String]  html string
    # @return [Void]
    #
    print: ($text='') ->
      @output.append fix($text)
      @kb.get(0).scrollIntoView()

    #
    # Print string to output
    #
    # @param  [String]  html string
    # @return [Void]
    #
    println: ($text='') ->
      @output.append fix("#{$text}\n")
      @kb.get(0).scrollIntoView()

    debug: ($text) ->
      @output.append "<span style=\"color: blue;\">"+fix("#{$text}\n")+"</span>"
      @kb.get(0).scrollIntoView()

    highlight: ($text) ->
      @output.append "<span style=\"color: yellow;\">"+fix("#{$text}\n")+"</span>"
      @kb.get(0).scrollIntoView()
