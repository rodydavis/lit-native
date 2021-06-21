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
    main {
      display: block;
      border: solid 1px gray;
      margin: 10px;
      padding: 16px;
      max-width: 800px;
    }
    button {
      touch-action: manipulation;
    }

    @media (prefers-color-scheme: dark) {
      main {
        /* background-color: black; */
        color: white;
        border-color: white;
      }
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
      <main>
        <h1>Hello, ${this.name}!</h1>
        <button @click=${this._onClick} part="button">
          Click Count: ${this.count}
        </button>
        <slot></slot>
      </main>
    `;
  }

  private _onClick() {
    this.count++;
    document.dispatchEvent(
      new CustomEvent("native", {
        bubbles: true,
        cancelable: true,
        detail: { type: "dialog", title: "Alert", message: "Hello from Web!" },
      })
    );
  }

  async firstUpdated() {
    this.addEventListener(
      "response",
      (e: any) => {
        // const { title, detail } = e.detail;
        console.log("event", e);
        this.name = "WebKit";
        this.requestUpdate();
      },
      false
    );
    window.addEventListener(
      "resize",
      () => {
        this.name = `${window.innerWidth}x${window.innerHeight}`;
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
