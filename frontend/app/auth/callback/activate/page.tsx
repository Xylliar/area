'use client'

import React, { Suspense, useEffect, useState } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { activateUser } from '@/lib/api'
import { useToast } from "@/hooks/use-toast"
import { useGlobal } from "@/components/GlobalContext"

function ActivateContent() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const [error, setError] = useState<string>('')
  const [isActivating, setIsActivating] = useState(true)
  const [countdown, setCountdown] = useState(5)
  const { toast } = useToast()
  const { isTextBigger } = useGlobal()

  useEffect(() => {
    const activateAccount = async () => {
      try {
        const token = searchParams.get('token')
        if (!token) {
          throw new Error('No activation token provided')
        }
        await activateUser(token)
        toast({
          title: "Success",
          description: "Account activated successfully!",
          duration: 5000,
        })

        const interval = setInterval(() => {
          setCountdown(prev => {
            if (prev <= 1) {
              clearInterval(interval)
              try {
                window.close()
              } catch {
                console.log('Could not close window')
              }
              router.push('/explore')
            }
            return prev - 1
          })
        }, 1000)

        return () => clearInterval(interval)
      } catch (err) {
        let errorMessage: string

        if (err instanceof Error) {
          if (err.message.includes('Conflict')) {
            errorMessage = 'This account has already been activated. You can close this window.'
          } else {
            errorMessage = err.message
          }
        } else {
          errorMessage = 'Failed to activate account'
        }

        setError(errorMessage)
        toast({
          title: (err as Error).message.includes('Conflict') ? "Info" : "Error",
          description: errorMessage,
          variant: (err as Error).message.includes('Conflict') ? "default" : "destructive",
          duration: 5000,
        })
      } finally {
        setIsActivating(false)
      }
    }

    activateAccount()
  }, [searchParams, router, toast])

  const content = () => {
    if (isActivating) {
      return (
        <div className="text-center">
          <h1 className={`font-bold mb-4 ${isTextBigger ? 'text-2xl' : 'text-xl'}`}>
            Activating your account...
          </h1>
        </div>
      )
    }

    if (error) {
      const isAlreadyActivated = error.includes('already been activated')
      return (
        <div className="text-center">
          <h1 className={`font-bold mb-4 ${isAlreadyActivated ? 'text-primary' : 'text-destructive'} ${isTextBigger ? 'text-2xl' : 'text-xl'}`}>
            {isAlreadyActivated ? 'Already Activated' : 'Activation Failed'}
          </h1>
          <p className="text-muted-foreground">{error}</p>
        </div>
      )
    }

    return (
      <div className="text-center">
        <h1 className={`font-bold mb-4 text-primary ${isTextBigger ? 'text-2xl' : 'text-xl'}`}>
          Account Activated Successfully!
        </h1>
        <p className="text-muted-foreground mb-4">
          Your account has been activated. This window will close in {countdown} seconds...
        </p>
        <div className="w-full bg-secondary rounded-full h-2">
          <div
            className="bg-primary h-2 rounded-full transition-all duration-1000"
            style={{ width: `${(countdown / 5) * 100}%` }}
          />
        </div>
      </div>
    )
  }

  return (
    <div className="flex flex-col min-h-screen bg-background">
      <main className="flex-1 p-4 max-w-7xl mx-auto w-full mt-20">
        <div className="max-w-md mx-auto p-6 rounded-lg border bg-card">
          {content()}
        </div>
      </main>
    </div>
  )
}

export default function ActivatePage() {
  return (
    <Suspense fallback={
      <div className="flex flex-col min-h-screen bg-background">
        <main className="flex-1 p-4 max-w-7xl mx-auto w-full mt-20">
          <div className="max-w-md mx-auto p-6 rounded-lg border bg-card">
            <div className="text-center">
              <h1 className="font-bold mb-4 text-xl">Loading...</h1>
            </div>
          </div>
        </main>
      </div>
    }>
      <ActivateContent />
    </Suspense>
  )
}
