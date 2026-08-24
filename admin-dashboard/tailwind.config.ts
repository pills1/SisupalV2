import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        background: "#0D0B26",
        foreground: "#F8FAFC",
        primary: {
          50: "#EEF2FF",
          100: "#E0E7FF",
          200: "#C7D2FE",
          300: "#A5B4FC",
          400: "#818CF8",
          500: "#6366F1",
          600: "#4F46E5",
          700: "#4338CA",
          800: "#3730A3",
          900: "#312E81",
        },
        sisu: {
          dark: "#0D0B26",
          card: "#16123D",
          surface: "#1F1A4D",
          border: "#2E2866",
          purple: "#6C5CE7",
          lilac: "#A29BFE",
          coral: "#FF7675",
          amber: "#FFA502",
          teal: "#00CEC9",
          emerald: "#2ED573",
        },
      },
      fontFamily: {
        sans: ["var(--font-inter)", "sans-serif"],
      },
    },
  },
  plugins: [],
};

export default config;
