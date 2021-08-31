server = require "@zbryikt/template/bin/lib/server"
require! <[@plotdb/srcbuild]>

opt = open: true
process.chdir 'web'
server.init opt
  .then ~> srcbuild.i18n(opt.i18n or {})
  .then (i18n) -> srcbuild.lsp {base: '.', i18n, bundle: {configFile: 'bundle.json'}, lsc: {use-glslify: true}}


