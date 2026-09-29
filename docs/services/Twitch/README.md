### Service Documentation - Twitch Provider

## Links

- [Reactions](#Reactions)
  - [Send Message in a Chat](#send-message-in-a-chat)
  - [Send Announcement to Your Chat](#send-announcement-to-your-chat)
  - [Create Clip](#create-clip)
  - [Ban User](#ban-user)
  - [Unban User](#unban-user)
  - [Add a Moderator](#add-a-moderator)
  - [Remove a Moderator](#remove-a-moderator)
  - [Add a VIP](#add-a-vip)
  - [Remove a VIP](#remove-a-vip)
  - [Block User](#block-user)
  - [Unblock User](#unblock-user)
  - [Send Whisper](#send-whisper)
  - [Health Check](#health-check)

- [Actions](#actions)
  - [Get New Followers](#get-new-followers)
  - [Get New Clips](#get-new-clips)
  - [Get New Blocked Users](#get-new-blocked-users)

### Reactions

#### Send Message in a Chat
- **Type**: Action
- **Endpoint**: `POST /twitch/send_message`
- **Parameters**:
  - `token`: The OAuth2 token for Twitch API.
  - `message`: The message to be sent.
  - `broadcaster`: The broadcaster's username.
- **Returns**: JSON response with the status of the operation.
- **Description**: This endpoint sends a message to the specified broadcaster's chat.
- **Twitch API Endpoint**: `POST https://api.twitch.tv/helix/chat/messages`

#### Send Announcement to Your Chat
- **Type**: Action
- **Endpoint**: `POST /twitch/send_announcement`
- **Parameters**:
  - `token`: The OAuth2 token for Twitch API.
  - `message`: The announcement message to be sent.
- **Returns**: JSON response with the status of the operation.
- **Description**: This endpoint sends an announcement to the broadcaster's chat.
- **Twitch API Endpoint**: `POST https://api.twitch.tv/helix/chat/announcements`

#### Create Clip
- **Type**: Action
- **Endpoint**: `POST /twitch/create_clip`
- **Parameters**:
  - `token`: The OAuth2 token for Twitch API.
  - `broadcaster`: The broadcaster's username.
- **Returns**: JSON response with the status of the operation.
- **Description**: This endpoint creates a clip for the specified broadcaster.
- **Twitch API Endpoint**: `POST https://api.twitch.tv/helix/clips`

#### Ban User
- **Type**: Action
- **Endpoint**: `POST /twitch/ban_user`
- **Parameters**:
  - `token`: The OAuth2 token for Twitch API.
  - `user`: The username of the user to be banned.
- **Returns**: JSON response with the status of the operation.
- **Description**: This endpoint bans a specified user from the broadcaster's chat.
- **Twitch API Endpoint**: `POST https://api.twitch.tv/helix/moderation/bans`

#### Unban User
- **Type**: Action
- **Endpoint**: `POST /twitch/unban_user`
- **Parameters**:
  - `token`: The OAuth2 token for Twitch API.
  - `user`: The username of the user to be unbanned.
- **Returns**: JSON response with the status of the operation.
- **Description**: This endpoint unbans a specified user from the broadcaster's chat.
- **Twitch API Endpoint**: `DELETE https://api.twitch.tv/helix/moderation/bans`

#### Add a Moderator
- **Type**: Action
- **Endpoint**: `POST /twitch/add_moderator`
- **Parameters**:
  - `token`: The OAuth2 token for Twitch API.
  - `user`: The username of the user to be added as a moderator.
- **Returns**: JSON response with the status of the operation.
- **Description**: This endpoint adds a specified user as a moderator for the broadcaster's chat.
- **Twitch API Endpoint**: `POST https://api.twitch.tv/helix/moderation/moderators`

#### Remove a Moderator
- **Type**: Action
- **Endpoint**: `POST /twitch/rm_moderator`
- **Parameters**:
  - `token`: The OAuth2 token for Twitch API.
  - `user`: The username of the user to be removed as a moderator.
- **Returns**: JSON response with the status of the operation.
- **Description**: This endpoint removes a specified user as a moderator from the broadcaster's chat.
- **Twitch API Endpoint**: `DELETE https://api.twitch.tv/helix/moderation/moderators`

#### Add a VIP
- **Type**: Action
- **Endpoint**: `POST /twitch/add_vip`
- **Parameters**:
  - `token`: The OAuth2 token for Twitch API.
  - `user`: The username of the user to be added as a VIP.
- **Returns**: JSON response with the status of the operation.
- **Description**: This endpoint adds a specified user as a VIP for the broadcaster's chat.
- **Twitch API Endpoint**: `POST https://api.twitch.tv/helix/channels/vips`

#### Remove a VIP
- **Type**: Action
- **Endpoint**: `POST /twitch/rm_vip`
- **Parameters**:
  - `token`: The OAuth2 token for Twitch API.
  - `user`: The username of the user to be removed as a VIP.
- **Returns**: JSON response with the status of the operation.
- **Description**: This endpoint removes a specified user as a VIP from the broadcaster's chat.
- **Twitch API Endpoint**: `DELETE https://api.twitch.tv/helix/channels/vips`

#### Block User
- **Type**: Action
- **Endpoint**: `POST /twitch/block_user`
- **Parameters**:
  - `token`: The OAuth2 token for Twitch API.
  - `user`: The username of the user to be blocked.
- **Returns**: JSON response with the status of the operation.
- **Description**: This endpoint blocks a specified user.
- **Twitch API Endpoint**: `PUT https://api.twitch.tv/helix/users/blocks`

#### Unblock User
- **Type**: Action
- **Endpoint**: `POST /twitch/unblock_user`
- **Parameters**:
  - `token`: The OAuth2 token for Twitch API.
  - `user`: The username of the user to be unblocked.
- **Returns**: JSON response with the status of the operation.
- **Description**: This endpoint unblocks a specified user.
- **Twitch API Endpoint**: `DELETE https://api.twitch.tv/helix/users/blocks`

#### Send Whisper
- **Type**: Action
- **Endpoint**: `POST /twitch/send_whisper`
- **Parameters**:
  - `token`: The OAuth2 token for Twitch API.
  - `user`: The username of the user to send the whisper to.
  - `message`: The whisper message to be sent.
- **Returns**: JSON response with the status of the operation.
- **Description**: This endpoint sends a whisper to a specified user.
- **Twitch API Endpoint**: `POST https://api.twitch.tv/helix/whispers`

#### Health Check
- **Type**: Action
- **Endpoint**: `GET /twitch/health`
- **Parameters**: None
- **Returns**: JSON response with the status of the service.
- **Description**: This endpoint checks the health of the service.

### Actions

#### Get New Followers
- **Type**: Reaction
- **Endpoint**: `GET /twitch/get_followers`
- **Parameters**:
  - `token`: The OAuth2 token for Twitch API.
  - `state`: The current state of the followers.
- **Returns**: JSON response with the new followers.
- **Description**: This endpoint retrieves new followers for the broadcaster.
- **Twitch API Endpoint**: `GET https://api.twitch.tv/helix/channels/followers`

#### Get New Clips
- **Type**: Reaction
- **Endpoint**: `GET /twitch/get_clips`
- **Parameters**:
  - `token`: The OAuth2 token for Twitch API.
  - `state`: The current state of the clips.
- **Returns**: JSON response with the new clips.
- **Description**: This endpoint retrieves new clips for the broadcaster.
- **Twitch API Endpoint**: `GET https://api.twitch.tv/helix/clips`

#### Get New Blocked Users
- **Type**: Reaction
- **Endpoint**: `GET /twitch/get_blocks`
- **Parameters**:
  - `token`: The OAuth2 token for Twitch API.
  - `state`: The current state of the blocked users.
- **Returns**: JSON response with the new blocked users.
- **Description**: This endpoint retrieves new blocked users for the broadcaster.
- **Twitch API Endpoint**: `GET https://api.twitch.tv/helix/users/blocks`