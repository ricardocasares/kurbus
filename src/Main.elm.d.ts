export type UnknownPort = undefined;

export interface ElmApp {
  ports: {
    [key: string]: UnknownPort;
  };
}

export namespace Main {
  function init(options: { node?: HTMLElement | null; flags: Flags }): ElmApp;
}

export as namespace Elm;

export { Elm };


