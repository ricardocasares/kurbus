import cfg from './_config'
import {autocompleteQuery, getStopByIdParam} from './_schemas'
import * as ttss from './_ttss'
import {zValidator} from '@hono/zod-validator'
import {Hono} from 'hono'

const kind = {
  bus: cfg.BUS_URL,
  tram: cfg.TRAM_URL,
} as const

export default new Hono()
  .basePath('/api')
  .post('/autocomplete', zValidator('json', autocompleteQuery), async c =>
    c.json(ttss.autocomplete(c.req.valid('json').search, 10)),
  )
  .get('/stop/:kind/:id', zValidator('param', getStopByIdParam), async c => {
    const params = c.req.valid('param')
    const passages = await ttss.stop(params.id, kind[params.kind])

    if (passages.error) return c.json({message: 'Unexpected response'}, 500)

    return c.json(passages.data)
  })
