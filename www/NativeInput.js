
/**
 * Native Input Plugin
 */
(function() {
  var exec = require("cordova/exec") ,
      SERVICE_NAME = "NativeInput" ,
      NativeInput = {};

  NativeInput.setup = function(params, cb, err) {

    params = params || {};

    exec(cb, err, SERVICE_NAME, "setup", [params.panel,
                                          params.input,
                                          params.leftButton,
                                          params.rightButton]);
  };

  NativeInput.show = function(text, cb, err) {
    exec(cb, err, SERVICE_NAME, "show", [text]);
  };

  NativeInput.closeKeyboard = function(cb, err) {
    exec(cb, err, SERVICE_NAME, "closeKeyboard", []);
  };

  NativeInput.onButtonAction = function(cb, err) {
    exec(cb, err, SERVICE_NAME, "onButtonAction", []);
  };

  NativeInput.onKeyboardClose = function(cb, err) {
    exec(cb, err, SERVICE_NAME, "onKeyboardClose", []);
  };

  NativeInput.onKeyboardAction = function(autoClose, cb, err) {
    autoClose = autoClose || true;
    exec(cb, err, SERVICE_NAME, "onKeyboardAction", [autoClose]);
  };

  NativeInput.hide = function(cb, err) {
    exec(cb, err, SERVICE_NAME, "hide", []);
  };

  NativeInput.onChange = function(cb, err) {
    exec(cb, err, SERVICE_NAME, "onChange", []);
  };

  NativeInput.getValue = function(cb, err) {
    exec(cb, err, SERVICE_NAME, "getValue", []);
  };

  NativeInput.setValue = function(value, cb, err) {
    exec(cb, err, SERVICE_NAME, "setValue", [value]);
  };

  module.exports = NativeInput;

})();
