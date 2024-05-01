import {Primitives} from "../types";

type BottomNavigationBarAttributes = 'background' | 'selectedItemColor' | 'unselectedItemColor' | 'iconSize' | 'elevation' | 'currentIndex' | 'fontSize'

export class BottomNavigationBar {
  readonly #attributes: Record<BottomNavigationBarAttributes, any>;

  private constructor() {
    // @ts-ignore
    this.#attributes = {}
  }

  static builder(): BottomNavigationBar {
    return new BottomNavigationBar();
  }

  build(): Primitives {
    return {
      type: 'bottomnavigationbar',
      attributes: this.#attributes,
    }
  }
}
