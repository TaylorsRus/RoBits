import { defineConfig } from "vitepress";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  base: "/RobloxUtil/",
  title: "RobloxUtil",
  description: "A collection of Roblox, and sometimes pure Luau utilities.",
  lang: "en-UK",
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: "Home", link: "/" },
      { text: "GitHub", link: "https://github.com/TaylorsRus/RobloxUtil" },
    ],

    sidebar: [
      {
        text: "Introduction",
        items: [{ text: "Getting Started", link: "/getting-started" }],
      },
      {
        text: "Modules",
        items: [{ text: "Bin", link: "/modules/bin" }],
      },
    ],

    socialLinks: [{ icon: "github", link: "https://github.com/TaylorsRus" }],
  },
});
