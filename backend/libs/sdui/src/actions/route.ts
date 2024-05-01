import {Primitives} from "../types";
import {Action} from "./action";

export class Route extends Action {
  #url: string | undefined;
  #trackEvent?: string;
  #replacement: boolean = false;
  #productId?: string;
  #parameters: Record<string, any> = {};

  private constructor() {
    super();
  }

  static builder(): Route {
    return new Route();
  }

  url(uri: string): Route {
    this.#url = uri;
    return this;
  }

  replacement(): Route {
    this.#replacement = true;
    return this;
  }

  trackEvent(eventName: string, productId: string): Route {
    this.#trackEvent = eventName;
    this.#productId = productId;
    return this;
  }

  parameters(parameters: Record<string, any>): Route {
    this.#parameters = parameters;
    return this;
  }

  backNavigation(): Route {
    this.#url = 'route:/..';
    return this;
  }

  override build(): Primitives {
    return {
      type: 'route',
      url: this.#url,
      replacement: this.#replacement,
      trackEvent: this.#trackEvent,
      trackProductId: this.#productId,
      parameters: this.#parameters,
    }
  }
}
