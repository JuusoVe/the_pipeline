import { Context, APIGatewayProxyResult, APIGatewayEvent } from 'aws-lambda';
import { migrate } from "postgres-migrations"
import pg from "pg"


export const lambdaHandler = async (
    event: APIGatewayEvent,
    context: Context
): Promise<APIGatewayProxyResult> => {
    console.log(`Event: ${JSON.stringify(event, null, 2)}`);
    console.log(`Context: ${JSON.stringify(context, null, 2)}`);
    const { DB_HOST, DB_PASSWORD, DB_USERNAME } = process.env
    // const pool = await createPool(`postgres://${DB_USERNAME}:${DB_PASSWORD}@${DB_HOST}:5432`)

    const dbConfig = {
        database: "main",
        user: DB_USERNAME,
        password: DB_PASSWORD,
        host: DB_HOST,
        port: 5432,
    }

    const client = new pg.Client(dbConfig) // or a Pool, or a PoolClient
    await client.connect()
    try {
        await migrate({ client }, "./migrations")
    } finally {
        await client.end()
    }

    return {
        statusCode: 200,
        body: JSON.stringify({
            message: 'Much pipeline.',
        }),
    };
};
