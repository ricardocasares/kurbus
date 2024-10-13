import {z} from 'zod'

const config = z.object({
  BUS_URL: z
    .string()
    .url()
    .transform(x => new URL(x)),
  TRAM_URL: z
    .string()
    .url()
    .transform(x => new URL(x)),
})

export default config.parse(process.env)
