import {Primitives} from "../types";
import {Action} from "../actions";

type AppBarAttributes = 'title' | 'elevation' | 'foregroundColor' | 'backgroundColor' | 'leading' | 'bottom' | 'automaticallyImplyLeading' | 'actions'

export class AppBar {

  readonly #attributes: Record<AppBarAttributes, any>;

  private constructor() {
    // @ts-ignore
    this.#attributes = {}
  }

  static builder(): AppBar {
    return new AppBar();
  }

  attribute(attribute: AppBarAttributes, value: string): AppBar {
    this.#attributes[attribute] = value;
    return this;
  }

  action(action: Action): AppBar {
    if (!this.#attributes['actions']) {
      this.#attributes['actions'] = []
    }

    this.#attributes['actions'].push(action.build());
    return this;
  }

  build(): Primitives {
    return {
      type: 'appbar',
      attributes: this.#attributes,
    };
  }
}
