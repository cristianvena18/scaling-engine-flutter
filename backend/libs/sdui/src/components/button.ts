import {Primitives} from "../types";

type ButtonAttributes = 'caption' | 'type' | 'padding' | 'stretched' | 'icon' | 'iconSize' | 'color' | 'iconColor' | 'fontSize';

export class Button {

  readonly #attributes: Record<ButtonAttributes, any>;

  private constructor() {
    // @ts-ignore
    this.#attributes = {}
  }

  static builder(): Button {
    return new Button();
  }

  build(): Primitives {
    return {
      type: 'button',
      attributes: this.#attributes,
    }
  }
}
