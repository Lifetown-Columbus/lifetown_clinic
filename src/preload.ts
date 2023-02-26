import { contextBridge, ipcRenderer } from "electron";

contextBridge.exposeInMainWorld("api", {
  search: (text: String) => ipcRenderer.invoke("search", text),
});
