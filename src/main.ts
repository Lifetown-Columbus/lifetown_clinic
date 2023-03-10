import { app, BrowserWindow, ipcMain, IpcMainInvokeEvent } from "electron";
import DB from "./db";
import path from "path";

const search = async (event: IpcMainInvokeEvent, ...args: any[]) => {
  console.log("searched for: ", args[0]);
};

const createWindow = () => {
  const win = new BrowserWindow({
    width: 1200,
    height: 900,
    resizable: true,
    webPreferences: {
      preload: path.join(__dirname, "preload.js"),
    },
  });

  ipcMain.handle("search", search);

  // DB.connect();
  win.loadFile("index.html");
  win.setMenu(null);
  win.webContents.openDevTools({ mode: "detach" });
};

app.whenReady().then(() => {
  createWindow();
  app.on("activate", () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on("window-all-closed", () => {
  if (process.platform !== "darwin") app.quit();
});
