import { Cta } from '../actions';
import { Primitives } from '../types';

export class Toolbar {

  #icon?: string;
  #title?: string;
  #styles?: Record<string, string>;
  #primaryCta?: Cta;

  // eslint-disable-next-line @typescript-eslint/no-empty-function
  private constructor() {
    this.#styles = {}
  }
  static builder(): Toolbar {
    return new Toolbar()
  }

  title(title: string): Toolbar {
    this.#title = title;
    return this;
  }

  icon(icon: string): Toolbar {
    this.#icon = icon;
    return this;
  }

  styles(styles: Record<string, string>) : Toolbar{
    this.#styles = styles
    return this;
  }

  cta(cta: Cta): Toolbar {
    this.#primaryCta = cta
    return this;
  }

  build(): Primitives {
    return {
      type: 'toolbar',
      icon: {
        url: this.#icon,
        cta: this.#primaryCta?.build(),
      },
      title: this.#title,
      styles: this.#styles,
    }
  }
}
