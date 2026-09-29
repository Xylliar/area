export interface Applet {
    id: string
    title: string
    description: string
    tags: string[]
    color: string
    active: boolean
}

export interface Service {
    id: string
    name: string
    title: string
    color: string
    description?: string
    tags?: string[]
}

export interface User {
    id: string;
    name: string;
    surname: string;
    email: string;
    gender: string;
    birthdate: string;
    role: string;
    is_activated: boolean;
}

export interface InputField {
    name: string;
    regex: string;
    example: string;
}

export interface ServiceAccount {
    name: string;
    isLinked: boolean;
}

export interface UpdateUserPayload {
    name?: string
    email?: string
    password?: string
}

export interface Action {
    id: string;
    title: string;
    description: string;
    input_fields?: InputField[];
    output_fields?: string[];
    frequency?: string;
    outputExample?: string;
}

export interface Reaction {
    id: string;
    title: string;
    description: string;
    input_fields?: InputField[];
    output_fields?: string[];
}

export interface Service {
    id: string
    name: string
    color: string
    logo: string
    actions: ActionReaction[]
    reactions: ActionReaction[]
}

export interface ActionReaction {
    id: string
    title: string
    description: string
    input_fields?: InputField[]
    output_fields?: string[]
    frequency?: string
    outputExample?: string
}

export interface ApiItem {
    id: string;
    title: string;
    description: string;
    service_name: string;
    service_id: string;
}

export interface ReactionInstance extends ApiItem {
    instanceId: string;
}

export interface AboutJsonService {
  name: string;
  actions: AboutJsonAction[];
  reactions: AboutJsonReaction[];
}

export interface AboutJsonAction {
  name: string;
  description: string;
}

export interface AboutJsonReaction {
  name: string;
  description: string;
}

export interface AboutJsonResponse {
  client: {
    host: string;
  };
  server: {
    current_time: number;
    services: AboutJsonService[];
  };
}