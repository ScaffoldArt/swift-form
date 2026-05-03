import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  base: '/swift-form/',
  title: "SAForm",
  lang: 'en',
  description: "Build better forms with a simple and flexible validation library for Swift and SwiftUI",
  head: [
    ['link', { rel: 'icon', type: 'image/png', href: '/scaffold-art-logo-icon.ico' }],
    ['meta', { name: 'theme-color', content: '#5f67ee' }],
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:site_name', content: 'SAForm' }],
    ['meta', { property: 'og:image', content: 'https://scaffoldart.github.io/swift-form/scaffoldart-og.png' }],
    ['meta', { property: 'og:url', content: 'https://scaffoldart.github.io/swift-form/' }]
  ],

  themeConfig: {
    logo: { src: '/scaffold-art-logo-min.png', width: 24, height: 24 },

    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Home', link: '/' },
      { text: 'API', link: '/api/' },
      { text: 'Validation Rules', link: '/validation-rules/' },
      { text: 'Examples', link: '/examples/' }
    ],

    sidebar: [
      { text: 'Overview', link: '/overview' },
      { text: 'Getting Started', link: '/getting-started' },
      {
        text: 'API',
        items: [
          { text: 'SAForm', link: '/api/saform' },
          { text: 'SAFormFields', link: '/api/saFormFields' },
          { text: 'SAFormGroup', link: '/api/saFormGroup' },
          { text: 'SAFormCollection', link: '/api/saFormCollection' },
          { text: 'SAFormField', link: '/api/saFormField' },
          { text: 'SAFormView', link: '/api/saFormView' },
          { text: 'SAFormControllerView', link: '/api/saFormControllerView' }
        ]
      },
      {
        text: 'Validation Rules',
        link: '/validation-rules/',
        items: [
          { text: 'String', link: '/validation-rules/string' },
          { text: 'Boolean', link: '/validation-rules/boolean'},
          { text: 'Integer', link: '/validation-rules/integer' },
          { text: 'Floating', link: '/validation-rules/floating' },
          { text: 'Decimal', link: '/validation-rules/decimal' },
          { text: 'Custom', link: '/validation-rules/custom' },
          { text: 'Union', link: '/validation-rules/union' },
        ]
      },
      {
        text: 'Examples',
        items: [
          { text: 'Login Form', link: '/examples/login-form' },
          { text: 'Initial Values', link: '/examples/initial-values' },
          { text: 'Server Errors', link: '/examples/server-errors'},
          { text: 'Server Validation', link: '/examples/server-validation' },
          // { text: 'Cross-Field Validation', link: '/' },
        ]
      }
    ],

    footer: {
      message: 'Released under the MIT License.',
      copyright: 'Copyright © 2025-present Drobyshev Artem'
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/ScaffoldArt/swift-form' }
    ],

    search: {
      provider: 'local'
    }
  }
})
