/* Amplify Params - DO NOT EDIT
    AUTH_COMPAEXPRESS1BFC17D6_USERPOOLID
    ENV
    REGION
Amplify Params - DO NOT EDIT */
/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */
const { AdminDisableUserCommand, ListUsersCommand, CognitoIdentityProviderClient } = require('@aws-sdk/client-cognito-identity-provider');

const client = new CognitoIdentityProviderClient({});

exports.handler = async (event) => {
    try {
        // Validar el cuerpo de la solicitud
        if (!event.body) {
            return {
                statusCode: 400,
                body: JSON.stringify({ error: 'El cuerpo de la solicitud está vacío' }),
            };
        }

        const body = JSON.parse(event.body);
        const { email } = body;

        if (!email) {
            return {
                statusCode: 400,
                body: JSON.stringify({ error: 'El correo electrónico es requerido' }),
            };
        }

        // Buscar usuario por email
        const listUsersCommand = new ListUsersCommand({
            UserPoolId: process.env.AUTH_COMPAEXPRESS1BFC17D6_USERPOOLID,
            Filter: `email = "${email}"`,
            Limit: 1,
        });

        const listUsersResponse = await client.send(listUsersCommand);

        if (!listUsersResponse.Users || listUsersResponse.Users.length === 0) {
            return {
                statusCode: 404,
                body: JSON.stringify({ error: 'Usuario no encontrado' }),
            };
        }

        const username = listUsersResponse.Users[0].Username;

        // Desactivar al usuario
        const disableCommand = new AdminDisableUserCommand({
            UserPoolId: process.env.AUTH_COMPAEXPRESS1BFC17D6_USERPOOLID,
            Username: username,
        });

        await client.send(disableCommand);

        return {
            statusCode: 200,
            body: JSON.stringify({ message: `El usuario con correo ${email} ha sido desactivado` }),
        };
    } catch (error) {
        console.error('Error al desactivar el usuario:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: 'Error al desactivar el usuario', details: error.message }),
        };
    }
};