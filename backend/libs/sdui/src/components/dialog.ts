import {Primitives} from "../types";

type DialogAttributes = 'title' | 'message' | 'type' | 'actions'

export class Dialog {
  readonly #attributes: Record<DialogAttributes, any>;

  private constructor() {
    // @ts-ignore
    this.#attributes = {}
  }

  static builder(): Dialog {
    return new Dialog()
  }

  type(type: 'confirm' | 'error' | 'warning'| 'information'): Dialog {
    this.#attributes['type'] = type;
    return this;
  }

  title(title: string): Dialog{
    this.#attributes['title'] = title;
    return this;
  }

  message(message: string): Dialog {
    this.#attributes['message'] = message;
    return this;
  }

  build(): Primitives {
    return {
      type: 'dialog',
      attributes: this.#attributes
    }
  }
}
