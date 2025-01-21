import express, { Request, Response } from 'express';

import { postgraphile } from "postgraphile"
import PostGraphileConnectionFilterPlugin from "postgraphile-plugin-connection-filter"
import dotenv from "dotenv"

dotenv.config()
const app = express()

// const DATABASE_URL = process.env.DATABASE_URL
// const PORT = process.env.PORT || 3002

// if (!DATABASE_URL) {
//   throw new Error("DATABASE_URL is missing")
// }

// app.use(
//   postgraphile(DATABASE_URL, "public", {
//     graphqlRoute: "/graphql",
//     graphiql: true,
//     enhanceGraphiql: true,
//     // exportGqlSchemaPath: './generated/graphql-schema.graphql', // Use the pre-generated schema
//     enableCors: true,
//     allowExplain: true,
//     appendPlugins: [PostGraphileConnectionFilterPlugin],
//   })
// )

app.get('/', (req: Request, res: Response) => {
  res.send("Express on Vercel");
});

app.listen(3000, () => {
  console.log(`🚀 Server is running at http://localhost:${PORT}/graphql`)
})

module.exports = app;
