import {z} from 'zod'

export type Stop = z.infer<typeof stop>
export const stop = z.object({
  name: z.string(),
  shortName: z.string(),
  category: z.enum(['bus', 'tram', 'other']),
  latitude: z.number().transform(x => x / 3600000.0),
  longitude: z.number().transform(x => x / 3600000.0),
})

export type StopsResponse = z.infer<typeof stopsResponse>
export const stopsResponse = z.object({
  stops: z.array(stop),
})

export type AutocompleteQuery = z.infer<typeof autocompleteQuery>
export const autocompleteQuery = z.object({
  search: z.string(),
})

export type GetStopByIdParam = z.infer<typeof getStopByIdParam>
export const getStopByIdParam = z.object({
  id: z.string(),
  kind: z.enum(['bus', 'tram']),
})

export type Passage = z.infer<typeof passage>
export const passage = z.object({
  actualRelativeTime: z.number(),
  actualTime: z.string().optional(),
  direction: z.string(),
  mixedTime: z.string(),
  passageid: z.string(),
  patternText: z.string(),
  plannedTime: z.string(),
  routeId: z.string(),
  status: z.string(),
  tripId: z.string(),
  vehicleId: z.string().optional(),
})

export type Route = z.infer<typeof route>
export const route = z.object({
  authority: z.string(),
  directions: z.array(z.string()),
  id: z.string(),
  name: z.string(),
  routeType: z.string(),
  shortName: z.string(),
})

export type StopPassages = z.infer<typeof stopPassages>
export const stopPassages = z.object({
  actual: z.array(passage),
  firstPassageTime: z.number(),
  lastPassageTime: z.number(),
  old: z.array(passage),
  routes: z.array(route),
  stopName: z.string(),
  stopShortName: z.string(),
})
