import { NextResponse } from 'next/server';
import { cookies } from 'next/headers';
import { fetchUser } from '@/lib/api';
import { BASE_URL } from '@/lib/config';

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const token = searchParams.get('token');

  if (!token) {
    return NextResponse.redirect(new URL('/login', BASE_URL));
  }

  const cookieStore = cookies();
  cookieStore.set('auth_token', token, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict',
    path: '/',
  });

  try {
    const userData = await fetchUser();

    if (!userData) {
      cookieStore.delete('auth_token');
      return NextResponse.redirect(new URL('/login', BASE_URL));
    }

    return NextResponse.redirect(new URL('/', BASE_URL));
  } catch {
    cookieStore.delete('auth_token');
    return NextResponse.redirect(new URL('/login', BASE_URL));
  }
}