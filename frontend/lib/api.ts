import { getAuthToken } from "@/lib/getCookies"
import { InputField, User, Action, Reaction } from "@/lib/types"
import { API_URL, PUBLIC_API_URL } from "@/lib/config"

async function fetchWithAuth(endpoint: string, options: RequestInit = {}) {
  try {
    const token = await getAuthToken();
    if (!token) {
      throw new Error('No auth token');
    }

    const headers = {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`,
      ...options.headers,
    };

    const response = await fetch(`${API_URL}${endpoint}`, { ...options, headers });
    if (response.status === 401) {
      throw new Error('Unauthorized');
    }
    if (!response.ok) {
      throw new Error(`API request failed: ${response.statusText}`);
    }

    return response.json();
  } catch {
    return null;
  }
}

async function fetchWithoutAuth(endpoint: string, options: RequestInit = {}) {
  const headers = {
    'Content-Type': 'application/json',
    ...options.headers,
  }

  const response = await fetch(`${API_URL}${endpoint}`, { ...options, headers })
  if (!response.ok) {
    throw new Error(`API request failed: ${response.statusText}`);
  }
  return response.json()
}


export async function getActions() {
  return fetchWithAuth('/actions')
}


export async function getReactions() {
  return fetchWithAuth('/reactions')
}


export async function getActionById(id: string) {
  const data = await fetchWithAuth(`/actions/${id}`);
  return {
    ...data,
    input_fields: data.input_fields.reduce(
      (acc: Record<string, { regex: string; example: string }>, field: InputField) => {
        acc[field.name] = { regex: field.regex, example: field.example };
        return acc;
      },
      {}
    ),
    output_fields: data.output_fields,
  };
}

export async function getReactionById(id: string) {
  const data = await fetchWithAuth(`/reactions/${id}`);
  return {
    ...data,
    input_fields: data.input_fields.reduce((acc: Record<string, { regex: string; example: string }>, field: InputField) => {
      acc[field.name] = { regex: field.regex, example: field.example };
      return acc;
    }, {}),
  };
}

export async function createApplet(
  actionId: string,
  title: string,
  description: string,
  tags: string[],
  actionInputs: Record<string, string>,
  reactions: Array<{
    reaction_id: string,
    reaction_inputs: Record<string, string>
  }>
) {
  const body = {
    title,
    description,
    tags,
    action_id: actionId,
    action_inputs: actionInputs,
    reactions: reactions
  };

  return fetchWithAuth('/users/me/applets', {
    method: 'POST',
    body: JSON.stringify(body),
  });
}

export async function createPublicApplet(
  actionId: string,
  title: string,
  description: string,
  tags: string[],
  actionInputs: Record<string, string>,
  reactions: Array<{
    reaction_id: string,
    reaction_inputs: Record<string, string>
  }>
) {
  const body = {
    title,
    description,
    tags,
    action_id: actionId,
    action_inputs: actionInputs,
    reactions: reactions
  };

  return fetchWithAuth('/applets', {
    method: 'POST',
    body: JSON.stringify(body),
  });
}

export async function validateToken() {
    return fetchWithAuth('/auth/acces-token-validity')
}


export async function fetchApplets() {
  return fetchWithAuth('/users/me/applets')
}


export async function updateApplet(id: string, active: boolean) {
  return fetchWithAuth(`/users/me/applets/${id}`, {
    method: 'PATCH',
    body: JSON.stringify({ active }),
  });
}


export async function deleteApplet(id: string) {
  return fetchWithAuth(`/users/me/applets/${id}`, { method: 'DELETE' });
}

export async function deletePublicApplet(id: string) {
  return fetchWithAuth(`/applets/${id}`, { method: 'DELETE' });
}

export async function fetchUser() {
  return fetchWithAuth('/users/me')
}


export async function copyApplet(id: string) {
  return fetchWithAuth(`/users/me/applets/${id}`, { method: 'POST' });
}


export async function getServiceColor(serviceId: string): Promise<string> {
  const response = await fetchWithAuth(`/services/${serviceId}`);
  return response.color;
}


export async function unlinkService(serviceName: string): Promise<void> {
  await fetchWithAuth(`/auth/${serviceName}/link?device=browser`, {
    method: 'DELETE',
  });
}


export async function isActivated(): Promise<boolean> {
  const response = await fetchWithAuth('/users/me');
  return response.is_activated;
}


export async function resendActivationEmail(): Promise<Response> {
  return fetchWithAuth('/auth/send-activation-token', { method: 'POST' });
}


export async function sendResetPassword(email: string): Promise<Response> {
  return fetchWithoutAuth(`/auth/send-password-reset-token/${encodeURIComponent(email).toString()}`, {
    method: 'POST',
    body: JSON.stringify({}),
  });
}


export async function changePassword(token: string, password: string): Promise<Response> {
  return fetchWithoutAuth(`/auth/reset-password?password=${encodeURIComponent(password)}&token=${encodeURIComponent(token)}`, {
    method: 'PATCH',
  });
}


export async function getLinkURL(serviceName: string): Promise<string> {
  const response = await fetchWithAuth(`/auth/${serviceName}/link?device=browser`);
  return response;
}


export async function fetchLinkStatus(serviceName: string): Promise<boolean> {
  return fetchWithAuth(`/auth/${serviceName}/link-status`);
}


export async function updateUserDetails(userDetails: User) {
  return fetchWithAuth('/users/me', {
    method: 'PATCH',
    body: JSON.stringify(userDetails),
  });
}


export async function fetchServices() {
  return fetchWithoutAuth('/services')
}


export async function fetchService(serviceId: string) {
  return fetchWithoutAuth(`/services/${serviceId}`)
}


export async function fetchServiceActions(serviceId: string) {
  const actions: Action[] = await fetchWithoutAuth(`/services/${serviceId}/actions`);
  const detailedActions = await Promise.all(actions.map(async (action: Action) => {
    const actionDetails = await fetchActionDetails(action.id);
    return actionDetails;
  }));
  return detailedActions;
}


export async function fetchServiceReactions(serviceId: string) {
  const reactions: Reaction[] = await fetchWithoutAuth(`/services/${serviceId}/reactions`);
  const detailedReactions = await Promise.all(reactions.map(async (reaction: Reaction) => {
    const reactionDetails = await fetchReactionDetails(reaction.id);
    return reactionDetails;
  }));
  return detailedReactions;
}


export async function fetchServiceLogo(serviceId: string) : Promise<string> {
  return fetchWithAuth(`/services/${serviceId}/icon`)
}

export async function fetchServiceIcon(serviceId: string): Promise<string> {
  try {
    const token = await getAuthToken();
    return `${PUBLIC_API_URL}/services/${serviceId}/icon${token ? `?token=${token}` : ''}`;
  } catch (error) {
    console.error('Error preparing service icon URL:', error);
    return '/placeholder-icon.png';
  }
}

export async function fetchActionDetails(actionId: string): Promise<Action> {
  return fetchWithoutAuth(`/actions/${actionId}`);
}


export async function fetchReactionDetails(reactionId: string): Promise<Reaction> {
  return fetchWithoutAuth(`/reactions/${reactionId}`)
}

export async function activateUser(token: string) {
  return fetchWithoutAuth(`/auth/activate?token=${token}`, {
    method: 'PATCH',
  });
}

export async function isAdmin() {
  const response = await fetchWithAuth('/users/me');
  return response?.role === 'admin';
}