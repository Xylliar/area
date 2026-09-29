"use client";

import { useEffect } from 'react';

const CloseTab = () => {
  useEffect(() => {
    window.open('', '_self')?.close();
  }, []);

  return null;
};

export default CloseTab;
