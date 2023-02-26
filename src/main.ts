import { app, BrowserWindow, ipcMain } from "electron";
import path from "path";

const createWindow = () => {
  const win = new BrowserWindow({
    width: 1200,
    height: 900,
    resizable: true,
    webPreferences: {
      preload: path.join(__dirname, "preload.js"),
    },
  });
  ipcMain.handle("ping", () => "pong");
  win.loadFile("index.html");
  win.setMenu(null);
  win.webContents.openDevTools();
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
