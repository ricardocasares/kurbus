import {stopPassages} from './_schemas'
import stops from './_stops.json'
import fuzzy from 'fuzzysort'

const prepared = stops
  .filter(s => s.category !== 'other')
  .map(s => ({
    shortName: s.shortName,
    name: s.name,
    category: s.category,
    prepared: fuzzy.prepare(s.name),
  }))

export function autocomplete(
  search: string,
  limit: number = 10,
  threshold: number = 0.7,
) {
  return fuzzy
    .go(search, prepared, {
      key: 'name',
      limit,
      threshold,
    })
    .map(({obj: {shortName, name, category}}) => ({
      shortName,
      name,
      category,
    }))
}

export async function stop(id: string, url: URL) {
  const endpoint = new URL(
    `/internetservice/services/passageInfo/stopPassages/stop`,
    url,
  )

  endpoint.searchParams.set('stop', id)

  return fetch(endpoint, {cache: 'no-cache'})
    .then(r => r.json())
    .then(stopPassages.safeParse)
}
