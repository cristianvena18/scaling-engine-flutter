import {Primitives} from "../types";

export abstract class Action {
  abstract build(): Primitives;
}
