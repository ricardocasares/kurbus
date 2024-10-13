import app from './_api'
import {handle} from 'hono/vercel'

export const config = {
  runtime: 'edge',
}

export default handle(app)
