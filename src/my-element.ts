import { LitElement, html, customElement, property, css } from "lit-element";

/**
 * An example element.
 *
 * @slot - This element has a slot
 * @csspart button - The button
 */
@customElement("my-element")
export class MyElement extends LitElement {
  static styles = css`
    :host {
      display: block;
      border: solid 1px gray;
      padding: 16px;
      max-width: 800px;
    }
    button {
      touch-action: manipulation;
    }
  `;

  /**
   * The name to say "Hello" to.
   */
  @property()
  name = "World";

  /**
   * The number of times the button has been clicked.
   */
  @property({ type: Number })
  count = 0;

  render() {
    return html`
      <h1>Hello, ${this.name}!</h1>
      <button @click=${this._onClick} part="button">
        Click Count: ${this.count}
      </button>
      <slot></slot>
    `;
  }

  private _onClick() {
    this.count++;
    document.dispatchEvent(
      new CustomEvent("native-alert", {
        bubbles: true,
        cancelable: true,
        detail: { title: "Alert", message: "Hello from Web!" },
      })
    );
  }

  foo(): string {
    return "foo";
  }

  async firstUpdated() {
    this.addEventListener(
      "response",
      (e: any) => {
        console.log("event", e);
        this.name = "WebKit!";
        this.requestUpdate();
      },
      false
    );
  }
}

declare global {
  interface HTMLElementTagNameMap {
    "my-element": MyElement;
  }
}
