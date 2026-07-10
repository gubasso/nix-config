chrome.commands.onCommand.addListener((command) => {
  if (command === "open-temp-chat") {
    chrome.tabs.create({ url: "https://chatgpt.com/?temporary-chat=true&hints=search" });
  }
});
