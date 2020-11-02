import execa from 'execa';
import mapSeriesAsync from 'map-series-async';
import which from 'which';

export default async function install(yo) {
  await execa('git', ['init'], {
    cwd: yo.destinationPath('')
  });
  await execa('git', ['add', '.'], {
    cwd: yo.destinationPath('')
  });
  return npmUpgrade(yo, (await getCommand()) || 'npm');
}

export async function npmUpgrade(yo, npm = 'npm') {
  await execa(npm, ['upgrade', '--latest'], {
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
