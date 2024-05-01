import {Primitives} from "../types";

type BadgeAttributes =
  'shape'
  | 'backgroundColor'
  | 'color'
  | 'caption'
  | 'borderRadius'
  | 'position'
  | 'elevation'
  | 'fontSize'
  | 'padding';

type BadgePosition = 'center' | 'topend' | 'topstart' | 'bottomend' | 'bottomstart';

export class Badge {

  readonly #attributes: Record<BadgeAttributes, any>;

  private constructor() {
    // @ts-ignore
    this.#attributes = {}
  }

  static builder(): Badge {
    return new Badge()
  }

  shape(shape: 'square' | 'circle'): Badge {
    this.#attributes['shape'] = shape;
    return this;
  }

  position(position: BadgePosition): Badge {
    this.#attributes['position'] = position

    return this;
  }

  build(): Primitives {
    return {
      type: 'badge',
      attributes: this.#attributes,
    }
  }
}
