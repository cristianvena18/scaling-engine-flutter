import { Primitives } from '../types';

export abstract class Child<T extends Primitives> {
  constructor() {
    //
  }

  abstract build(): T;
}
