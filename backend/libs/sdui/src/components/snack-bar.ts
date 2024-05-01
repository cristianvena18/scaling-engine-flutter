import {Child} from "./child";
import { Primitives } from '../types';

export class SnackBar extends Child<Primitives> {
  #title?: string;
  #showTime: number;
  #color?: string;

  private constructor() {
    super()
    this.#showTime = 15;
  }

  static builder(): SnackBar {
    return new SnackBar();
  }

  title(title: string): SnackBar {
    this.#title = title;
    return this;
  }

  showTime(time?: number) {
    if (time) {
      this.#showTime = time;
    }

    return this;
  }

  override build(): Primitives {
    return {
      type: 'snackbar',
      title: this.#title,
      props: {
        showTime: this.#showTime,
        color: this.#color,
      }
    }
  }

  color(color: string): SnackBar {
    this.#color = color
    return this;
  }
}
