import execa from 'execa';
import mapSeriesAsync from 'map-series-async';
import which from 'which';

export default async function install(yo) {
  await execa('git', ['init'], {
    cwd: yo.destinationPath('')
  });
  const installChar = yo.options.install
    ? yo.options.install[0].toLowerCase()
    : 'y';
  if (!yo.answers.install || installChar === 'n' || installChar === 'f') {
    return false;
  }
  await npmInstall(yo, (await getCommand()) || 'npm');
  return yo.installDependencies({
    npm: false,
    bower: false,
    yarn: false
  });
}

export async function npmInstall(yo, npm = 'npm') {
  await execa(npm, ['install'], {
    cwd: yo.destinationPath(''),
    stdio: 'inherit'
  });
}

export async function getCommand(commands = ['pnpm', 'yarn', 'npm']) {
  let result = null;
  await mapSeriesAsync(commands, async (command) => {
    if (!result && (await which(command))) result = command;
  });
  return result;
}
