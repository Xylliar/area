'use client';

import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { getAuthToken } from '@/lib/getCookies';
import { isActivated } from '@/lib/api';

interface GlobalContextType {
  isActivated: boolean;
  showPopup: boolean;
  setShowPopup: React.Dispatch<React.SetStateAction<boolean>>;
  isTextBigger: boolean;
  setIsTextBigger: React.Dispatch<React.SetStateAction<boolean>>;
  isButtonBigger: boolean;
  setIsButtonBigger: React.Dispatch<React.SetStateAction<boolean>>;
  isLoggedIn: boolean;
  checkAuthStatus: () => Promise<void>;
}

const GlobalContext = createContext<GlobalContextType | null>(null);

export const useGlobal = (): GlobalContextType => {
  const context = useContext(GlobalContext);
  if (!context) {
    throw new Error('useGlobal must be used within a GlobalProvider');
  }
  return context;
};

export const GlobalProvider = ({ children }: { children: ReactNode }) => {
  const [activated, setActivated] = useState(false);
  const [showPopup, setShowPopup] = useState(false);
  const getInitialTextBigger = () => {
    if (typeof window !== 'undefined') {
      return JSON.parse(localStorage.getItem('isTextBigger') || 'false');
    }
    return false;
  };

  const getInitialButtonBigger = () => {
    if (typeof window !== 'undefined') {
      return JSON.parse(localStorage.getItem('isButtonBigger') || 'false');
    }
    return false;
  };

  const [isTextBigger, setIsTextBigger] = useState(getInitialTextBigger);
  const [isButtonBigger, setIsButtonBigger] = useState(getInitialButtonBigger);
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  const checkAuthStatus = async () => {
    try {
      const token = await getAuthToken();
      setIsLoggedIn(!!token);
    } catch {
      setIsLoggedIn(false);
    }
  };

  useEffect(() => {
    const checkActivationStatus = async () => {
      try {
        const activated = await isActivated();
        setActivated(activated);
        if (!activated) {
          setShowPopup(true);
        }
      } catch {
        setActivated(false);
      }
    };

    if (isLoggedIn) {
      checkActivationStatus();
    }
  }, [isLoggedIn]);

  useEffect(() => {
    checkAuthStatus();
  }, []);

  useEffect(() => {
    if (typeof window !== 'undefined') {
      localStorage.setItem('isTextBigger', JSON.stringify(isTextBigger));
    }
  }, [isTextBigger]);

  useEffect(() => {
    if (typeof window !== 'undefined') {
      localStorage.setItem('isButtonBigger', JSON.stringify(isButtonBigger));
    }
  }, [isButtonBigger]);

  return (
    <GlobalContext.Provider value={{
      isActivated: activated,
      showPopup,
      setShowPopup,
      isTextBigger,
      setIsTextBigger,
      isButtonBigger,
      setIsButtonBigger,
      isLoggedIn,
      checkAuthStatus
    }}>
      {children}
    </GlobalContext.Provider>
  );
};
