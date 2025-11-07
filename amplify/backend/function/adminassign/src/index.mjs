

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */
import {
  AdminAddUserToGroupCommand,
  AdminConfirmSignUpCommand,
  CognitoIdentityProviderClient
} from "@aws-sdk/client-cognito-identity-provider";

const client = new CognitoIdentityProviderClient({});

export const handler = async (event) => {
  try {
    const body = JSON.parse(event.body);
    const { username, groupName } = body;

    if (!username || !groupName) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: "username and groupName are required" }),
      };
    }

    // Confirmar al usuario
    const confirmCommand = new AdminConfirmSignUpCommand({
      UserPoolId: process.env.USER_POOL_ID,
      Username: username,
    });

    await client.send(confirmCommand);

    // Agregar al grupo
    const groupCommand = new AdminAddUserToGroupCommand({
      UserPoolId: process.env.USER_POOL_ID,
      Username: username,
      GroupName: groupName,
    });

    await client.send(groupCommand);

    return {
      statusCode: 200,
      body: JSON.stringify({ message: `User ${username} confirmed and added to ${groupName}` }),
    };
  } catch (error) {
    console.error(error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Error assigning user to group", details: error.message }),
    };
  }
};
