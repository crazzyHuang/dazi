// .pnpmfile.cjs
'use strict';

function readPackage(pkg, context) {
  // 可以在这里修改包的配置
  // 例如：重定向依赖版本、添加脚本等

  return pkg;
}

module.exports = {
  hooks: {
    readPackage
  }
};