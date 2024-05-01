import { View } from '../components';
import { Primitives } from '../types';

type LayoutDirection = 'horizontal' | 'vertical'

export class SimpleLayout {
  #view?: View;
  private style: Partial<{ margin: string }>;
  #direction: LayoutDirection;
  constructor() {
    this.style = {}
    this.#direction = 'vertical'
  }

  static builder(): SimpleLayout {
    return new SimpleLayout();
  }

  margin(x: string, y: string): SimpleLayout {
    this.style = {
      ...this.style,
      margin: `${x} ${y}`,
    }
    return this;
  }

  screen(view: View): SimpleLayout {
    this.#view = view;
    return this;
  }

  direction(direction: LayoutDirection): SimpleLayout {
    this.#direction = direction;
    return this;
  }

  build(): Primitives {
    if (!this.#view) {
      throw new Error('view must be defined');
    }

    return {
      type: 'layout',
      style: this.style!,
      screen: this.#view.build()!,
      direction: this.#direction!,
    }
  }
}
