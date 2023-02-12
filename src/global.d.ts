export {};

declare global {
    interface Window {
        versions: Versions
    }
}

interface Versions {
    node: () => string,
    chrome: () => string,
    electron: () => string,
    ping: () => Promise<void>,
}