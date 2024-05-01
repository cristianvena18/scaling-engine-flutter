import {Child, Primitives, Screen} from '../index';
import {SnackBar} from '../components';

export class ErrorHandler {

  #component!: Child<any>;

  private constructor() {
  }

  static builder(): ErrorHandler {
    return new ErrorHandler();
  }

  snackbar(title: string, showTime?: number): ErrorHandler {
    this.#component = SnackBar.builder()
      .title(title)
      .color('red')
      .showTime(showTime);

    return this;
  }

  view(): Screen {
    this.#component = Screen.builder().type('error');

    return this.#component as Screen;
  }

  build(): Primitives {
    if (!this.#component) {

      console.log('Component has not been set, i will set a default')

      // TODO: change to error view

    }

    return {
      type: 'error',
      component: this.#component?.build()
    };
  }
}
