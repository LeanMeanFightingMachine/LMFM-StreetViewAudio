require.config({
  paths: {
    "jquery": "../vendor/jquery"
  },
  shim: {
    app: ["jquery"]
  }
});

require(["app"], function(App) {
  return new App();
});

//# sourceMappingURL=main.js.map
