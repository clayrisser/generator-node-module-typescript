export default class Hello {
  public world: string;

  constructor() {
    this.world = 'texas';
  }
}

const logger = console;

const hello = new Hello();
logger.info(`Howdy, ${hello.world}!`);
