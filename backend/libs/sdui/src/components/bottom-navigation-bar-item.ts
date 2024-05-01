import {Primitives} from "../types";
import {Action} from "../actions";

type BottomNavigationBarItemAttributes = 'caption' | 'icon'

export class BottomNavigationBarItem {
  readonly #attributes: Record<BottomNavigationBarItemAttributes, any>;
  #action: Action | undefined = undefined;

  private constructor() {
    // @ts-ignore
    this.#attributes = {}
  }

  static builder(): BottomNavigationBarItem {
    return new BottomNavigationBarItem();
  }

  build(): Primitives {
    return {
      type: 'bottomnavigationbaritem',
      attributes: this.#attributes,
      action: this.#action,
    }
  }
}
