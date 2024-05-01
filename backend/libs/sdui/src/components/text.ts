import { Primitives } from '../types';

type TextAttributes = 'caption' | 'overflow' | 'color' | 'bold' | 'italic' | 'size' | 'alignment' | 'decoration' | 'maxLines';

export class Text {

  readonly #attributes: Record<TextAttributes, any>;

  private constructor() {
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore
    this.#attributes = {}
  }

  static builder(text: string): Text {
    const t = new Text()
    t.#attributes['caption'] = text;
    return t;
  }

  overflow(overflow: 'clip' | 'ellipsis' | 'fade' | 'visible'): Text {
    this.#attributes['overflow'] = overflow
    return this;
  }

  alignment(alignment: 'left' | 'right' | 'center' | 'justify' | 'end' | 'start'): Text {
    this.#attributes['alignment'] = alignment
    return this;
  }

  build(): Primitives {
    return {
      type: 'text',
      attributes: this.#attributes,
    }
  }
}
