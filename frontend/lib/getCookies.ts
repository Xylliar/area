"use server";

import { cookies } from "next/headers";

export async function getAuthToken() {
  const cookieStore = cookies();
  const token = cookieStore.get('auth_token')?.value;
  return token;
}

export async function removeAuthToken() {
  const cookieStore = cookies();
  cookieStore.delete('auth_token');
}