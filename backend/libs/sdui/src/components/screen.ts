import {Child} from './child';
import {BottomNavigationBar} from "./bottom-navigation-bar";
import {Primitives} from "../types";

type ScreenAttributes = 'safe' | 'backgroundColor'
type ScreenType = 'error' | 'info' | 'warn'

export class Screen {

  readonly #attributes: Record<ScreenAttributes, any>;
  readonly #children: Child<any>[] = [];
  #bottomNavigationBar?: BottomNavigationBar = undefined;

  // eslint-disable-next-line @typescript-eslint/no-empty-function
  private constructor() {
    // @ts-ignore
    this.#attributes = {
      'safe': true,
    };
  }

  static builder(): Screen {
    return new Screen();
  }

  type(type: ScreenType): Screen {
    this.#attributes['backgroundColor'] = type;
    return this;
  }

  /**
   * appends children to array
   * @param children
   */
  children(children: Child<any>): Screen {
    this.#children.push(children);
    return this;
  }

  safe(): Screen {
    this.#attributes['safe'] = true;
    return this;
  }

  unsafe(): Screen {
    this.#attributes['safe'] = false;
    return this;
  }

  bottomNavigationBar(bar: BottomNavigationBar): Screen {
    this.#bottomNavigationBar = bar
    return this;
  }


  build(): Primitives {
    return {
      children: this.#children.map(c => c.build()),
      type: 'screen',
      attributes: this.#attributes,
      bottomNavigationBar: this.#bottomNavigationBar?.build() || undefined
    };
  }
}
