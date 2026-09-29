### GitHub Provider Documentation

#### Actions

##### Push Action
- **Type**: Action
- **Endpoint**: `POST /github/push_action/create_webhook`
- **Parameters**:
  - `applet_id`: The ID of the applet that triggers the action.
  - `state`: A map containing the state of the action.
  - `token`: The GitHub access token.
  - `owner`: The owner of the repository.
  - `repository`: The name of the repository.
- **Returns**: JSON response with the state of the action.
- **Description**: This action creates a webhook for push events on a GitHub repository.

- **Endpoint**: `POST /github/push_action/delete_webhook`
- **Parameters**:
  - `applet_id`: The ID of the applet that triggers the action.
  - `state`: A map containing the state of the action.
  - `token`: The GitHub access token.
  - `owner`: The owner of the repository.
  - `repository`: The name of the repository.
- **Returns**: JSON response with the status of the operation.
- **Description**: This action deletes a webhook for push events on a GitHub repository.

- **Endpoint**: `POST /github/push_action/callback/{applet_id}`
- **Parameters**:
  - `applet_id`: The ID of the applet that triggers the action.
- **Returns**: JSON response with the push event data.
  - `pusher_name`: The name of the pusher.
  - `pusher_email`: The email of the pusher.
  - `commits_details`: Details about the commits in the push event.
- **Description**: This endpoint is the callback for the push webhook. It processes the push event data and returns the relevant information.

##### Issue Action
- **Type**: Action
- **Endpoint**: `POST /github/issue_action/create_webhook`
- **Parameters**:
  - `applet_id`: The ID of the applet that triggers the action.
  - `state`: A map containing the state of the action.
  - `token`: The GitHub access token.
  - `owner`: The owner of the repository.
  - `repository`: The name of the repository.
- **Returns**: JSON response with the state of the action.
- **Description**: This action creates a webhook for issue events on a GitHub repository.

- **Endpoint**: `POST /github/issue_action/delete_webhook`
- **Parameters**:
  - `applet_id`: The ID of the applet that triggers the action.
  - `state`: A map containing the state of the action.
  - `token`: The GitHub access token.
  - `owner`: The owner of the repository.
  - `repository`: The name of the repository.
- **Returns**: JSON response with the status of the operation.
- **Description**: This action deletes a webhook for issue events on a GitHub repository.

- **Endpoint**: `POST /github/issue_action/callback/{applet_id}`
- **Parameters**:
  - `applet_id`: The ID of the applet that triggers the action.
- **Returns**: JSON response with the issue event data.
  - `action`: The type of action that triggered the event.
  - `id`: The ID of the issue.
  - `number`: The number of the issue.
  - `title`: The title of the issue.
  - `body`: The body of the issue.
  - `issue_state`: The state of the issue.
  - `user`: The user who triggered the event.
  - `labels`: The labels associated with the issue.
  - `assignees`: The assignees of the issue.
  - `create_at`: The creation timestamp of the issue.
  - `update_at`: The last update timestamp of the issue.
- **Description**: This endpoint is the callback for the issue webhook. It processes the issue event data and returns the relevant information.

##### Pull Request Action
- **Type**: Action
- **Endpoint**: `POST /github/pull_request_action/create_webhook`
- **Parameters**:
  - `applet_id`: The ID of the applet that triggers the action.
  - `state`: A map containing the state of the action.
  - `token`: The GitHub access token.
  - `owner`: The owner of the repository.
  - `repository`: The name of the repository.
- **Returns**: JSON response with the state of the action.
- **Description**: This action creates a webhook for pull request events on a GitHub repository.

- **Endpoint**: `POST /github/pull_request_action/delete_webhook`
- **Parameters**:
  - `applet_id`: The ID of the applet that triggers the action.
  - `state`: A map containing the state of the action.
  - `token`: The GitHub access token.
  - `owner`: The owner of the repository.
  - `repository`: The name of the repository.
- **Returns**: JSON response with the status of the operation.
- **Description**: This action deletes a webhook for pull request events on a GitHub repository.

- **Endpoint**: `POST /github/pull_request_action/callback/{applet_id}`
- **Parameters**:
  - `applet_id`: The ID of the applet that triggers the action.
- **Returns**: JSON response with the pull request event data.
  - `action`: The type of action that triggered the event.
  - `title`: The title of the pull request.
  - `body`: The body of the pull request.
  - `pull_request_state`: The state of the pull request.
  - `user`: The user who triggered the event.
  - `reviewers`: The reviewers of the pull request.
  - `assignees`: The assignees of the pull request.
  - `labels`: The labels associated with the pull request.
  - `create_at`: The creation timestamp of the pull request.
  - `update_at`: The last update timestamp of the pull request.
  - `closed_at`: The closure timestamp of the pull request.
  - `merged_at`: The merge timestamp of the pull request.
- **Description**: This endpoint is the callback for the pull request webhook. It processes the pull request event data and returns the relevant information.

##### Create Branch Action
- **Type**: Action
- **Endpoint**: `POST /github/create_branch_action/create_webhook`
- **Parameters**:
  - `applet_id`: The ID of the applet that triggers the action.
  - `state`: A map containing the state of the action.
  - `token`: The GitHub access token.
  - `owner`: The owner of the repository.
  - `repository`: The name of the repository.
- **Returns**: JSON response with the state of the action.
- **Description**: This action creates a webhook for create branch events on a GitHub repository.

- **Endpoint**: `POST /github/create_branch_action/delete_webhook`
- **Parameters**:
  - `applet_id`: The ID of the applet that triggers the action.
  - `state`: A map containing the state of the action.
  - `token`: The GitHub access token.
  - `owner`: The owner of the repository.
  - `repository`: The name of the repository.
- **Returns**: JSON response with the status of the operation.
- **Description**: This action deletes a webhook for create branch events on a GitHub repository.

- **Endpoint**: `POST /github/create_branch_action/callback/{applet_id}`
- **Parameters**:
  - `applet_id`: The ID of the applet that triggers the action.
- **Returns**: JSON response with the create branch event data.
  - `branch`: The name of the new branch.
  - `master_branch`: The name of the master branch.
  - `description`: The description of the new branch.
  - `pusher_type`: The type of pusher that triggered the event.
- **Description**: This endpoint is the callback for the create branch webhook. It processes the create branch event data and returns the relevant information.

#### Reactions

##### Create Issue Reaction
- **Type**: Reaction
- **Endpoint**: `POST /github/create_issue_reaction`
- **Parameters**:
  - `token`: The GitHub access token.
  - `owner`: The owner of the repository.
  - `repository`: The name of the repository.
  - `title`: The title of the issue.
  - `body`: The body of the issue.
- **Returns**: JSON response with the status of the operation.
- **Description**: This reaction creates a new issue in a GitHub repository.

##### Create File Reaction
- **Type**: Reaction
- **Endpoint**: `POST /github/create_file_reaction`
- **Parameters**:
  - `token`: The GitHub access token.
  - `owner`: The owner of the repository.
  - `repository`: The name of the repository.
  - `branch`: The branch where the file will be created.
  - `message`: The commit message.
  - `filepath`: The path of the file to be created.
  - `content`: The content of the file.
- **Returns**: JSON response with the status of the operation.
- **Description**: This reaction creates a new file in a GitHub repository.

##### Create Pull Request Reaction
- **Type**: Reaction
- **Endpoint**: `POST /github/create_pull_request_reaction`
- **Parameters**:
  - `token`: The GitHub access token.
  - `owner`: The owner of the repository.
  - `repository`: The name of the repository.
  - `title`: The title of the pull request.
  - `body`: The body of the pull request.
  - `base`: The base branch of the pull request.
  - `head`: The head branch of the pull request.
- **Returns**: JSON response with the status of the operation.
- **Description**: This reaction creates a new pull request in a GitHub repository.

##### Create Branch Reaction
- **Type**: Reaction
- **Endpoint**: `POST /github/create_branch_reaction`
- **Parameters**:
  - `token`: The GitHub access token.
  - `owner`: The owner of the repository.
  - `repository`: The name of the repository.
  - `new_branch`: The name of the new branch.
  - `base_branch`: The base branch for the new branch.
- **Returns**: JSON response with the status of the operation.
- **Description**: This reaction creates a new branch in a GitHub repository.

#### Other Endpoints

##### Health Check
- **Type**: Endpoint
- **Endpoint**: `GET /github/health`
- **Returns**: JSON response with the status of the service.
- **Description**: This endpoint is used for health checks to determine the status of the service.