### Discord Provider Documentation

#### Actions

##### New Messages Action
- **Type**: Action
- **Endpoint**: `POST /discord/new_messages_action`
- **Parameters**:
  - `token`: The Discord bot token.
  - `state`: A map containing the state of the action.
  - `channel_id`: The ID of the channel to monitor for new messages.
- **Returns**: JSON response with the following fields:
  - `triggered`: A boolean indicating whether new messages were found.
  - `state`: The updated state of the action.
  - `messages`: (Optional) The new messages found in the channel.
- **Description**: This action monitors a Discord channel for new messages. It returns the new messages found since the last time the action was triggered.

#### Reactions

##### Send Message Reaction
- **Type**: Reaction
- **Endpoint**: `POST /discord/send_message_reaction`
- **Parameters**:
  - `token`: The Discord bot token.
  - `channel_id`: The ID of the channel to send the message to.
  - `content`: The content of the message to send.
- **Returns**: JSON response with the status of the operation.
- **Description**: This reaction sends a message to a Discord channel.

##### Send Message Webhook Reaction
- **Type**: Reaction
- **Endpoint**: `POST /discord/send_message_webhook_reaction`
- **Parameters**:
  - `webhook_url`: The URL of the Discord webhook.
  - `content`: The content of the message to send.
- **Returns**: JSON response with the status of the operation.
- **Description**: This reaction sends a message to a Discord channel using a webhook.

##### Disconnect Voice Channel Reaction
- **Type**: Reaction
- **Endpoint**: `POST /discord/disconnect_voice_channel_reaction`
- **Parameters**:
  - `token`: The Discord bot token.
  - `channel_id`: The ID of the voice channel to disconnect all members from.
- **Returns**: JSON response with the status of the operation.
- **Description**: This reaction disconnects all members from a Discord voice channel.

##### Add Role Reaction
- **Type**: Reaction
- **Endpoint**: `POST /discord/add_role_reaction`
- **Parameters**:
  - `token`: The Discord bot token.
  - `guild_id`: The ID of the Discord server.
  - `user_id`: The ID of the user to add the role to.
  - `role_id`: The ID of the role to add to the user.
- **Returns**: JSON response with the status of the operation.
- **Description**: This reaction adds a role to a user in a Discord server.

##### Kick Reaction
- **Type**: Reaction
- **Endpoint**: `POST /discord/kick_reaction`
- **Parameters**:
  - `token`: The Discord bot token.
  - `user_id`: The ID of the user to kick from the server.
  - `guild_id`: The ID of the Discord server.
- **Returns**: JSON response with the status of the operation.
- **Description**: This reaction kicks a user from a Discord server.

#### Other Endpoints

##### Health Check
- **Type**: Endpoint
- **Endpoint**: `GET /discord/health`
- **Returns**: JSON response with the status of the service.
- **Description**: This endpoint is used for health checks to determine the status of the service.