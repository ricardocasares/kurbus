import cfg from './_config'
import {autocompleteQuery, getStopByIdParam, stopPassages} from './_schemas'
import stops from './_stops.json'
import {zValidator} from '@hono/zod-validator'
import fuzzy from 'fuzzysort'
import {Hono} from 'hono'

const prepared = stops
  .filter(s => s.category !== 'other')
  .map(s => ({
    shortName: s.shortName,
    name: s.name,
    category: s.category,
    prepared: fuzzy.prepare(s.name),
  }))

async function getStop(id: string, url: URL) {
  const endpoint = new URL(
    `/internetservice/services/passageInfo/stopPassages/stop`,
    url,
  )

  endpoint.searchParams.set('stop', id)

  return fetch(endpoint, {cache: 'no-cache'})
    .then(r => r.json())
    .then(stopPassages.safeParse)
}

export default new Hono()
  .basePath('/api')
  .post('/autocomplete', zValidator('json', autocompleteQuery), async c =>
    c.json(
      fuzzy
        .go(c.req.valid('json').search, prepared, {
          key: 'name',
          limit: 10,
          threshold: 0.7,
        })
        .map(({obj: {shortName, name, category}}) => ({
          shortName,
          name,
          category,
        }))
        .slice(0, 5),
    ),
  )
  .get('/stop/bus/:id', zValidator('param', getStopByIdParam), async c => {
    const passages = await getStop(c.req.valid('param').id, cfg.BUS_URL)

    if (passages.error) {
      console.log(passages.error)
      return c.json({message: 'The API return an unexpected response'}, 500)
    }

    return c.json(passages.data)
  })
  .get('/stop/tram/:id', zValidator('param', getStopByIdParam), async c => {
    const passages = await getStop(c.req.valid('param').id, cfg.TRAM_URL)

    if (passages.error) {
      console.log(passages.error)
      return c.json({message: 'The API return an unexpected response'}, 500)
    }

    return c.json(passages.data)
  })
