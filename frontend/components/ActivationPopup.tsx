"use client";

import { Dialog, DialogContent, DialogHeader, DialogFooter, DialogTitle, DialogDescription } from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { useGlobal } from '@/components/GlobalContext';
import { resendActivationEmail } from '@/lib/api';
import { removeAuthToken } from '@/lib/getCookies';

export default function ActivationPopup() {
  const { showPopup, setShowPopup, isTextBigger, isButtonBigger } = useGlobal();

  if (!showPopup) {
    return null;
  }

  const handleResendEmail = async () => {
    try {
      await resendActivationEmail();
    } catch (error) {
      console.error('Error resending activation email:', error);
    }
  };

  const handleLogout = async () => {
    await removeAuthToken();
  };

  return (
    <Dialog open={showPopup} onOpenChange={setShowPopup} disableClose={true}>
      <DialogContent disableClose={true} disableOutsideClick={true} className="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle className={isTextBigger ? 'text-3xl' : 'text-2xl'}>Account Activation Required</DialogTitle>
          <DialogDescription className={isTextBigger ? 'text-lg' : 'text-base'}>
            Please activate your account by verifying your email address.
          </DialogDescription>
        </DialogHeader>
        <DialogFooter>
          <Button onClick={handleLogout} className={isButtonBigger ? 'py-4 text-lg' : ''}>Logout</Button>
          <Button onClick={handleResendEmail} className={isButtonBigger ? 'py-4 text-lg' : ''}>Resend Activation Email</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}