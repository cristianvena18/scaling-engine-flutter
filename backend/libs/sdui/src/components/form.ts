import {Input, Inputs} from "./input";
import {Child} from "./child";
import {Action, Cta} from "../actions";
import {Primitives} from "../types";

type FormAttributes = ''

export class Form extends Child<any> {

  readonly #attributes: Record<FormAttributes, any>
  #inputs: Inputs = []
  #cta?: Cta;
  #secondaryAction?: Action;


  private constructor() {
    super()
    // @ts-ignore
    this.#attributes = {}
  }

  static builder() {
    return new Form();
  }

  addInput(input: Input): Form {
    this.#inputs.push(input);
    return this;
  }

  cta(cta: Cta): Form {
    this.#cta = cta;
    return this;
  }

  secondaryAction(cta: Action): Form {
    this.#secondaryAction = cta;
    return this;
  }

  public build(): Primitives {
    return {
      type: 'form',
      attributes: this.#attributes,
      children: this.#inputs
        .map(c => c.build())
        .concat(
          this.#cta?.build(),
          this.#secondaryAction?.build()
        )
        .filter(Boolean),
    }
  }
}
