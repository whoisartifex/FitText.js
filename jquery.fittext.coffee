###!
FitText.js 1.1

Copyright 2011, Dave Rupert http://daverupert.com
Released under the WTFPL license
http://sam.zoy.org/wtfpl/
###
(($) ->
  DEFAULT_OPTIONS =
    minFontSize: Number.NEGATIVE_INFINITY
    maxFontSize: Number.POSITIVE_INFINITY
    compressorScale: 10
    preserveLineHeight: true
    debounce: 100

  # Attempts to typecast the given value to a float,
  # returning the default if unsuccessful
  forceFloat = (value, fallback = 0) ->
    value = parseFloat value
    if isNaN(value) then fallback else value

  # Simplified debounce function, taken from underscore.js
  debounce = (fn, wait) ->
    timeout = null
    result = null
    return ->
      context = this
      args = arguments
      later = ->
        timeout = null
        result = fn.apply(context, args)
      clearTimeout(timeout)
      timeout = setTimeout(later, wait)
      return result

  # fitText changes the font size of the elements based on their width.
  $.fn.fitText = (compressor = 1, options = {}) ->
    options = $.extend {}, DEFAULT_OPTIONS, options
    options.minFontSize = forceFloat options.minFontSize, DEFAULT_OPTIONS.minFontSize
    options.maxFontSize = forceFloat options.maxFontSize, DEFAULT_OPTIONS.maxFontSize
    compressor *= options.compressorScale

    @each ->
      $this = $(this)
      lineHeight = forceFloat($this.css('line-height')) / forceFloat($this.css('font-size'))

      resizer = ->
        fontSize = $this.width() / compressor
        fontSize = Math.max Math.min(fontSize, options.maxFontSize), options.minFontSize
        $this.css 'font-size', fontSize
        if options.preserveLineHeight and lineHeight > 0
          $this.css 'line-height', "#{fontSize * lineHeight}px"

      $(window).on 'resize.fitText', debounce(resizer, options.debounce)
      resizer()

  # Automatically run fitText on elements with a [data-fit-text]
  # attribute, which can be set to the vale of the compressor:
  #
  #   <h1 data-fit-text="1.2" data-max-font-size="100">Header</h1>
  #
  $ ->
    $('[data-fit-text]').each ->
      $this = $(this)
      compressor = $this.attr('data-fit-text') or 1
      options =
        minFontSize: $this.attr 'data-min-font-size'
        maxFontSize: $this.attr 'data-max-font-size'
      $this.fitText(compressor, options)
)(jQuery)
