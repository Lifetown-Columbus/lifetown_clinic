export {};

declare global {
  interface Window {
    api: Api;
  }
}

interface Api {
  search: (text: String) => Promise<void>;
}
