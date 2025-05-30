const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.html.haml",
    "./app/views/**/*.haml",
    "./app/lib/form_builders/tailwind_form_builder.rb",
  ],
  safelist: [
    "field",
    "field_with_errors",
    "primary_button",
    {
      pattern: /button/,
    },
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ["Inter var", ...defaultTheme.fontFamily.sans],
      },

      width: (theme) => ({
        auto: "auto",
        ...theme("spacing"),
        "1_2": "50%",
        "1_3": "33.333333%",
        "2_3": "66.666667%",
        "1_4": "25%",
        "2_4": "50%",
        "3_4": "75%",
        "1_5": "20%",
        "2_5": "40%",
        "3_5": "60%",
        "4_5": "80%",
        "1_6": "16.666667%",
        "2_6": "33.333333%",
        "3_6": "50%",
        "4_6": "66.666667%",
        "5_6": "83.333333%",
        "1_12": "8.333333%",
        "2_12": "16.666667%",
        "3_12": "25%",
        "4_12": "33.333333%",
        "5_12": "41.666667%",
        "6_12": "50%",
        "7_12": "58.333333%",
        "8_12": "66.666667%",
        "9_12": "75%",
        "10_12": "83.333333%",
        "11_12": "91.666667%",
        full: "100%",
        screen: "100vw",
      }),
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/aspect-ratio"),
    require("@tailwindcss/typography"),
    require("@tailwindcss/container-queries"),
  ],
};
