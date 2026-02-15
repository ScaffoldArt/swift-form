---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: "Form Craft"
  tagline: "Build type-safe SwiftUI forms with composable validation."
  actions:
    - theme: brand
      text: Getting Started
      link: /getting-started
    - theme: alt
      text: GitHub
      link: https://github.com/ArtyCodingart/form-craft
  image:
    src: /form-craft-start-logo.png
    alt: FormCraft

features:
  - icon: ✨
    title: Type-safe form data, by default.
    details: Define fields once and submit strongly typed, validated values. FormCraft helps you move from raw input to trusted data without manual casting or fragile plumbing.
  - icon: ⚡️
    title: Field rules + cross-field refine.
    details: Combine per-field validation with form-level refinement for real-world scenarios like password confirmation, dependent fields, and business constraints.
  - icon: 📦
    title: SwiftUI-native developer experience.
    details: Built for modern SwiftUI with observable form state, binding-friendly controllers, async validation support, and an API that stays predictable as forms grow.
  - icon: 🏗️
    title: Composable today, extensible tomorrow.
    details: Start with built-in chainable rules, then add custom validators, localization, and reusable patterns. The architecture is designed to scale with your product and your team.
---
