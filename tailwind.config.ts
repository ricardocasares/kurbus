import * as rdx from '@radix-ui/colors'
import daisy, {type Config as Daisy} from 'daisyui'
import {type Config} from 'tailwindcss'

export default {
  content: ['src/**/*.{ts,elm}', 'index.html'],
  plugins: [daisy],
  daisyui: {
    logs: false,
    themes: [
      {
        dark: {
          'color-scheme': 'dark',
          'base-content': rdx.grayDarkP3.gray12,
          'primary': rdx.grayDarkP3.gray1,
          'primary-content': rdx.grayDarkP3.gray12,
          'accent': rdx.indigoDarkP3.indigo5,
          'accent-content': rdx.indigoDarkP3.indigo12,
          'neutral': rdx.grayDarkP3.gray5,
          'neutral-content': rdx.grayDarkP3.gray10,
          'base-100': rdx.blackP3A.blackA12,
          'base-200': rdx.grayDarkP3.gray1,
          'base-300': rdx.grayDarkP3.gray3,
          'error': rdx.redDarkP3.red3,
          'error-content': rdx.redDarkP3.red11,
        },
      },
    ],
  } satisfies Daisy,
} satisfies Config
