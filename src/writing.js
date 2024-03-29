import _ from 'lodash';

export default async function writing(yo) {
  yo.fs.copyTpl(
    yo.templatePath('template/shared/src/**'),
    yo.destinationPath('src'),
    yo.context
  );
  yo.fs.copyTpl(
    yo.templatePath('template/shared/_vscode/**'),
    yo.destinationPath('.vscode'),
    yo.context
  );
  if (yo.context.bin) {
    yo.fs.copy(
      yo.templatePath('template/shared/bin/bin.js'),
      yo.destinationPath(`bin/${_.camelCase(yo.context.name)}.js`)
    );
    yo.fs.copy(
      yo.templatePath('template/shared/src/bin.ts'),
      yo.destinationPath('src/bin.ts')
    );
  }
  if (!yo.context.lock) {
    yo.fs.copy(
      yo.templatePath('template/shared/_npmrc'),
      yo.destinationPath('.npmrc')
    );
  }
  yo.fs.copy(
    yo.templatePath('template/shared/_eslintrc.js'),
    yo.destinationPath('.eslintrc.js')
  );
  yo.fs.copy(
    yo.templatePath('template/shared/Makefile'),
    yo.destinationPath('Makefile')
  );
  yo.fs.copy(
    yo.templatePath('template/shared/blackmagic.mk'),
    yo.destinationPath('blackmagic.mk')
  );
  yo.fs.copy(
    yo.templatePath('template/shared/_babelrc'),
    yo.destinationPath('.babelrc')
  );
  yo.fs.copyTpl(
    yo.templatePath('template/shared/_gitignore'),
    yo.destinationPath('.gitignore'),
    yo.context
  );
  yo.fs.copyTpl(
    yo.templatePath('template/shared/_package.json'),
    yo.destinationPath('package.json'),
    yo.context
  );
  yo.fs.copyTpl(
    yo.templatePath('template/shared/webpack.config.js'),
    yo.destinationPath('webpack.config.js'),
    yo.context
  );
  yo.fs.copyTpl(
    yo.templatePath('template/shared/tsconfig.json'),
    yo.destinationPath('tsconfig.json'),
    yo.context
  );
  yo.fs.copy(
    yo.templatePath('template/shared/tsconfig.app.json'),
    yo.destinationPath('tsconfig.app.json')
  );
  yo.fs.copy(
    yo.templatePath('template/shared/default.nix'),
    yo.destinationPath('default.nix')
  );
  yo.fs.copy(
    yo.templatePath('template/shared/_envrc'),
    yo.destinationPath('.envrc')
  );
  yo.fs.copyTpl(
    yo.templatePath('template/shared/tests'),
    yo.destinationPath('tests'),
    yo.context
  );
  yo.fs.copy(
    yo.templatePath('template/shared/tests_eslintrc'),
    yo.destinationPath('tests/.eslintrc')
  );
}
