/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
  theme: {
    extend: {
      colors: {
        wa: '#25D366',
        'wa-dark': '#128C7E',
      },
    },
  },
  plugins: [],
};
