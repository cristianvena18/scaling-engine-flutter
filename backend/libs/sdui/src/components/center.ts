import {Child} from "./child";
import {Primitives} from "../types";

export class Center {

  readonly #children: Array<Child<any>> = []

  private constructor() {
  }

  static builder(): Center {
    return new Center()
  }

  children(child: Child<any>): Center {
    this.#children.push(child);
    return this;
  }

  build(): Primitives {
    return {
      type: 'center',
      children: this.#children.map(c => c.build())
    }
  }
}
