import {Action} from "./action";
import {Dialog} from "../components/dialog";
import {Primitives} from "../types";

type CommandAttributes = 'caption' | 'type' | 'name'

export class Cta extends Action {

  readonly #attributes: Record<CommandAttributes, any>
  #url?: string;
  #prompt?: Dialog;

  private constructor() {
    super()
    // @ts-ignore
    this.#attributes = {
      type: 'submit',
      name: 'submit'
    }
  }

  static builder(): Cta {
    return new Cta()
  }

  prompt(dialog: Dialog): Cta {
    this.#prompt = dialog
    return this;
  }

  request(url: string, text: string): Cta {
    this.#url = url;
    this.#attributes['caption'] = text;
    return this;
  }

  build(): Primitives {
    return {
      type: 'input',
      action: {
        type: 'command',
        url: this.#url,
        prompt: this.#prompt?.build()
      },
      attributes: this.#attributes,
    }
  }
}
