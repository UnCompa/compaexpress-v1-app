/* Amplify Params - DO NOT EDIT
	AUTH_COMPAEXPRESS1BFC17D6_USERPOOLID
	ENV
	REGION
Amplify Params - DO NOT EDIT */

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */
import {
  CognitoIdentityProviderClient,
  ListUsersCommand,
  ListUsersInGroupCommand,
} from "@aws-sdk/client-cognito-identity-provider";

const cognito = new CognitoIdentityProviderClient({});
const USER_POOL_ID = process.env.AUTH_COMPAEXPRESS1BFC17D6_USERPOOLID;

export const handler = async (event) => {
  // Extract query parameters from API Gateway event
  const { groupName, negocioId } = event.queryStringParameters || {};

  try {
    // Validate input
    if (!USER_POOL_ID) {
      throw new Error('USER_POOL_ID environment variable is missing');
    }
    if (groupName && typeof groupName !== 'string') {
      throw new Error('Invalid groupName provided');
    }
    if (negocioId && typeof negocioId !== 'string') {
      throw new Error('Invalid negocioId provided');
    }

    let users = [];
    let nextToken = undefined;

    if (groupName) {
      // List users in a group
      do {
        const command = new ListUsersInGroupCommand({
          UserPoolId: USER_POOL_ID,
          GroupName: groupName,
          Limit: 60,
          NextToken: nextToken,
        });

        const response = await cognito.send(command);
        let groupUsers = response.Users || [];
        
        // Apply negocioId filter if provided
        if (negocioId) {
          groupUsers = groupUsers.filter(user =>
            user.Attributes?.find((a) => a.Name === 'custom:negocioid')?.Value === negocioId
          );
        }
        
        users.push(...groupUsers);
        nextToken = response.NextToken;
      } while (nextToken);
    } else if (negocioId) {
      // List users filtered by negocioId
      do {
        const command = new ListUsersCommand({
          UserPoolId: USER_POOL_ID,
          Limit: 60,
          PaginationToken: nextToken,
        });

        const response = await cognito.send(command);
        let fetchedUsers = response.Users || [];
        
        // Filter users by negocioId in-memory
        fetchedUsers = fetchedUsers.filter(user =>
          user.Attributes?.find((a) => a.Name === 'custom:negocioid')?.Value === negocioId
        );
        
        users.push(...fetchedUsers);
        nextToken = response.PaginationToken;
      } while (nextToken);
    } else {
      // List all users
      do {
        const command = new ListUsersCommand({
          UserPoolId: USER_POOL_ID,
          Limit: 60,
          PaginationToken: nextToken,
        });

        const response = await cognito.send(command);
        users.push(...(response.Users || []));
        nextToken = response.PaginationToken;
      } while (nextToken);
    }

    const formattedUsers = users.map((user) => ({
      id: user.Attributes?.find((a) => a.Name === 'sub')?.Value || '',
      username: user.Username || '',
      enabled: user.Enabled ?? false,
      status: user.UserStatus || 'UNKNOWN',
      createdAt: user.UserCreateDate || null,
      email: user.Attributes?.find((a) => a.Name === 'email')?.Value || '',
      negocioId: user.Attributes?.find((a) => a.Name === 'custom:negocioid')?.Value || null,
    }));

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({ users: formattedUsers }),
    };
  } catch (err) {
    console.error('Error listing users:', JSON.stringify(err, null, 2));
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({ error: err.message, details: err.name }),
    };
  }
};