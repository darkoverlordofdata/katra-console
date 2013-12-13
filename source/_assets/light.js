// Generated by CoffeeScript 1.6.3
(function($, window, document) {
  var Plugin, defaults, pluginName;
  Plugin = function(element, options) {
    this.element = element;
    this.options = $.extend({}, defaults, options);
    this._defaults = defaults;
    this._name = pluginName;
    return this.init();
  };
  pluginName = "defaultPluginName";
  defaults = {
    propertyName: "value"
  };
  Plugin.prototype.init = function() {};
  return $.fn[pluginName] = function(options) {
    return this.each(function() {
      if (!$.data(this, "plugin_" + pluginName)) {
        return $.data(this, "plugin_" + pluginName, new Plugin(this, options));
      }
    });
  };
})(jQuery, window, document);
