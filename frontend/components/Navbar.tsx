'use client';

import { useState, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { Menu, X, LogOut } from "lucide-react";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import Link from "next/link";
import { getAuthToken, removeAuthToken } from "@/lib/getCookies";
import { useRouter } from "next/navigation";
import { useGlobal } from "@/components/GlobalContext";
import { usePathname } from 'next/navigation';

const AreaNavbar = () => {
  const [isScrolled, setIsScrolled] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const router = useRouter();
  const pathname = usePathname();
  const { isTextBigger, isButtonBigger } = useGlobal();

  const checkAuthStatus = async () => {
    const token = await getAuthToken();
    setIsLoggedIn(!!token);
  };

  useEffect(() => {
    checkAuthStatus();
  }, [pathname]);

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 20);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const handleLogout = async () => {
    await removeAuthToken();
    setIsLoggedIn(false);
    router.push('/');
  };

  return (
    <header className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${isScrolled ? 'bg-white shadow-md' : 'bg-transparent'}`}>
      <div className="w-full px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          <div className="flex items-center">
            <Link href="/" className="flex-shrink-0">
              <h1 className={`text-primary font-bold ${isTextBigger ? 'text-3xl' : 'text-2xl'}`}>Area</h1>
            </Link>
            <nav className="hidden md:block ml-10">
              <ul className="flex space-x-4">
                {isLoggedIn && (
                  <>
                    <li>
                      <Link href="/explore" className={`hover:text-primary transition-colors ${isTextBigger ? 'text-lg' : 'text-base'} text-gray-700`}>Explore</Link>
                    </li>
                    <li>
                      <Link href="/applet" className={`hover:text-primary transition-colors ${isTextBigger ? 'text-lg' : 'text-base'} text-gray-700`}>My Applets</Link>
                    </li>
                  </>
                )}
              </ul>
            </nav>
          </div>
          {isLoggedIn ? (
            <div className="hidden md:flex items-center space-x-4">
              <Link href="/applet/create">
                <Button variant="default" className={isButtonBigger ? 'py-4 text-lg' : ''}>Create</Button>
              </Link>
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Avatar>
                    <AvatarImage src="https://t4.ftcdn.net/jpg/02/15/84/43/360_F_215844325_ttX9YiIIyeaR7Ne6EaLLjMAmy4GvPC69.jpg" alt="User avatar" />
                    <AvatarFallback>Profile</AvatarFallback>
                  </Avatar>
                </DropdownMenuTrigger>
                <DropdownMenuContent>
                  <DropdownMenuLabel>My Account</DropdownMenuLabel>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem asChild>
                    <Link href="/account" className={`${isTextBigger ? 'text-lg' : ''} ${isButtonBigger ? 'text-lg py-4' : ''}`}>Profile</Link>
                  </DropdownMenuItem>
                  <DropdownMenuItem asChild>
                    <Link href="/applet" className={`${isTextBigger ? 'text-lg' : ''} ${isButtonBigger ? 'text-lg py-4' : ''}`}>My Applets</Link>
                  </DropdownMenuItem>
                  <DropdownMenuItem onClick={handleLogout}>
                    <LogOut className={`mr-2 h-4 w-4 ${isTextBigger ? 'text-lg' : ''} ${isButtonBigger ? 'text-lg py-4' : ''}`} />
                    <span>Logout</span>
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
            </div>
          ) : (
            <div className="hidden md:block">
              <Link href="/login">
                <Button variant="default" className={isButtonBigger ? 'py-4 text-lg' : ''}>Login</Button>
              </Link>
            </div>
          )}
          <div className="md:hidden">
            <button
              onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
              className={`text-gray-700 hover:text-primary transition-colors ${isTextBigger ? 'text-lg' : 'text-base'}`}
              aria-label={isMobileMenuOpen ? "Close menu" : "Open menu"}
            >
              {isMobileMenuOpen ? <X /> : <Menu />}
            </button>
          </div>
        </div>
      </div>
      {/* Mobile menu */}
      <div
        className={`md:hidden fixed inset-0 z-40 bg-white transition-transform duration-300 ease-in-out ${
          isMobileMenuOpen ? 'translate-x-0' : '-translate-x-full'
        }`}
      >
        <div className="flex justify-end p-4">
          <button
            onClick={() => setIsMobileMenuOpen(false)}
            className="text-gray-700 hover:text-primary transition-colors"
            aria-label="Close menu"
          >
            <X />
          </button>
        </div>
        <nav className="px-2 pt-2 pb-3 space-y-1 sm:px-3">
          {isLoggedIn ? (
            <>
              <Link href="/explore" className={`block px-3 py-2 font-medium transition-colors ${isTextBigger ? 'text-lg' : 'text-base'} text-gray-700 hover:text-primary`}>Explore</Link>
              <Link href="/applet" className={`block px-3 py-2 font-medium transition-colors ${isTextBigger ? 'text-lg' : 'text-base'} text-gray-700 hover:text-primary`}>My Applets</Link>
              <Link href="/account" className={`block px-3 py-2 font-medium transition-colors ${isTextBigger ? 'text-lg' : 'text-base'} text-gray-700 hover:text-primary`}>Account</Link>
              <div className="pt-4 flex flex-col space-y-2 px-3">
                <Link href="/applet/create">
                  <Button variant="default" className={`w-full ${isButtonBigger ? 'py-4 text-lg' : ''}`}>Create</Button>
                </Link>
                <Button variant="ghost" onClick={handleLogout} className={`justify-start w-full ${isButtonBigger ? 'py-4 text-lg' : ''}`}>
                  <LogOut className="mr-2 h-4 w-4" />
                  <span>Logout</span>
                </Button>
              </div>
            </>
          ) : (
            <div className="pt-4 flex flex-col space-y-2 px-3">
              <Link href="/" className={`block px-3 py-2 font-medium transition-colors ${isTextBigger ? 'text-lg' : 'text-base'} text-gray-700 hover:text-primary`}>Area</Link>
              <Link href="/login">
                <Button variant="default" className={`w-full ${isButtonBigger ? 'py-4 text-lg' : ''}`}>Login</Button>
              </Link>
            </div>
          )}
        </nav>
      </div>
    </header>
  );
};

export default AreaNavbar;
