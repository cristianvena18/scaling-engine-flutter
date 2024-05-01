import { SimpleLayout } from './simple-layout';

export class Layout {

  private constructor() {
  }

  static builder(): Layout {
    return new Layout();
  }

  simple(): SimpleLayout {
    return new SimpleLayout()
  }
}
