import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"
import { getAuthToken } from "@/lib/getCookies"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export function isLogged() {
  return !!getAuthToken();
}
