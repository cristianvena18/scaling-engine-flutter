import { Primitives } from '../types';

type InputAttributes =
  'type'
  | 'name'
  | 'required'
  | 'caption'
  | 'maxLines'
  | 'maxLength'
  | 'hideText'
  | 'readOnly'
  | 'enabled'
  | 'imageSource'
  | 'minLength'
  | 'uploadUrl'

type InputType = 'text' | 'email' | 'number' | 'url' | 'date' | 'time' | 'phone' | 'submit' | 'file' | 'image' | 'video'


export class Input {
  protected readonly attributes: Record<InputAttributes, any>;

  private constructor() {
    // @ts-ignore
    this.attributes = {};
  }

  static builder() {
    return new Input();
  }

  name(name: string): Input {
    this.attributes['name'] = name;
    return this;
  }

  placeholder(placeholder: string): Input {
    this.attributes['caption'] = placeholder;
    return this;
  }

  type(type: InputType): Input {
    this.attributes['type'] = type;
    return this;
  }


  build(): Primitives {
    return {
      type: 'input',
      attributes: this.attributes,
    }
  }

  required(): Input {
    this.attributes['required'] = true;
    return this;
  }
}

export type Inputs = Input[]
