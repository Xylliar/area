import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { validateToken } from './lib/api';

export async function middleware(request: NextRequest) {
  const token = request.cookies.get('auth_token');
  const response = await validateToken();

  if (token) {
    try {
      if (response === true) {
        return NextResponse.next();
      } else {
        return NextResponse.redirect(new URL('/login', request.url));
      }
    } catch (error) {
      request.cookies.delete('auth_token');
      return NextResponse.redirect(new URL('/login', request.url));
    }
  } else {
    return NextResponse.redirect(new URL('/login', request.url));
  }
}

export const config = {
  matcher: [
    '/account/:path*',
    '/applet/:path*',
    '/explore/:path*',
  ],
};