export default class Hello {
  constructor(public world: string = 'texas') {}
}

const logger = console;

const hello = new Hello();
logger.info(`Howdy, ${hello.world}!`);
