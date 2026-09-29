'use client'

import { useState, useEffect } from "react"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { Label } from "@/components/ui/label"
import { Card } from "@/components/ui/card"
import { User, UpdateUserPayload } from "@/lib/types"
import { updateUserDetails } from "@/lib/api"
import { Separator } from "@/components/ui/separator"
import { Switch } from "@/components/ui/switch"
import { Skeleton } from "@/components/ui/skeleton"
import { useGlobal } from "../GlobalContext"

export function PersonalInfoSection({ userDetails }: { userDetails: User }) {
  const [formData, setFormData] = useState({ name: '', email: '', password: '' })
  const [isClient, setIsClient] = useState(false)
  const { isTextBigger, setIsTextBigger, isButtonBigger, setIsButtonBigger } = useGlobal()

  useEffect(() => {
    setIsClient(true)
    setFormData({ name: userDetails.name, email: userDetails.email, password: '' })
  }, [userDetails])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    try {
      const updateData: UpdateUserPayload = {}

      if (formData.name) updateData.name = formData.name
      if (formData.email) updateData.email = formData.email
      if (formData.password) updateData.password = formData.password

      await updateUserDetails({ ...userDetails, ...updateData })

    } catch (error) {
      throw new Error('Failed to update user details: ' + error)
    }
  }

  const SkeletonForm = () => (
    <>
      <Skeleton className="h-8 w-3/4 mb-4" />
      <div className="space-y-4">
        <div>
          <Skeleton className="h-5 w-1/4 mb-2" />
          <Skeleton className="h-10 w-full" />
        </div>
        <div>
          <Skeleton className="h-5 w-1/4 mb-2" />
          <Skeleton className="h-10 w-full" />
        </div>
        <div>
          <Skeleton className="h-5 w-1/4 mb-2" />
          <Skeleton className="h-10 w-full" />
        </div>
        <Skeleton className="h-10 w-full" />
      </div>
      <Skeleton className="h-px w-full my-6" />
      <div className="space-y-4">
        <Skeleton className="h-7 w-1/2 mb-4" />
        <div className="flex items-center justify-between">
          <Skeleton className="h-5 w-1/3" />
          <Skeleton className="h-6 w-12" />
        </div>
        <div className="flex items-center justify-between">
          <Skeleton className="h-5 w-1/3" />
          <Skeleton className="h-6 w-12" />
        </div>
      </div>
    </>
  )

  return (
    <Card className="cursor-pointer transition-all duration-300 bg-gradient-to-br from-background to-accent/10 shadow-none rounded-lg p-6 mb-8">
      {!isClient ? (
        <SkeletonForm />
      ) : (
        <>
          <h2 className={`text-2xl font-semibold mb-4 ${isTextBigger ? 'text-3xl' : ''}`}>Personal Information</h2>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <Label htmlFor="email" className={`text-sm font-medium ${isTextBigger ? 'text-lg' : ''}`}>Email</Label>
              <Input
                type="text"
                id="email"
                value={formData.email}
                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                placeholder={userDetails.email}
                className={`mt-1 ${isTextBigger ? 'text-lg' : ''}`}
              />
            </div>
            <div>
              <Label htmlFor="name" className={`text-sm font-medium ${isTextBigger ? 'text-lg' : ''}`}>Name</Label>
              <Input
                type="text"
                id="name"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                placeholder={userDetails.name}
                className={`mt-1 ${isTextBigger ? 'text-lg' : ''}`}
              />
            </div>
            <div>
              <Label htmlFor="password" className={`text-sm font-medium ${isTextBigger ? 'text-lg' : ''}`}>Password</Label>
              <Input
                type="password"
                id="password"
                value={formData.password}
                onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                placeholder="••••••••"
                className={`mt-1 ${isTextBigger ? 'text-lg' : ''}`}
              />
            </div>
            <Button type="submit"  className={`w-full ${isButtonBigger ? 'py-6 text-lg' : 'py-4'}`}>Update Profile</Button>
          </form>
          <Separator className="mt-6" />
          <div className="mt-6">
            <h3 className={`text-xl font-semibold mb-4 ${isTextBigger ? 'text-2xl' : ''}`}>Accessibility</h3>
            <div className="flex items-center justify-between mb-4">
              <span className={`text-base font-medium ${isTextBigger ? 'text-2xl' : 'text-xl'}`}>Make text bigger</span>
              <Switch
                checked={isTextBigger}
                onCheckedChange={setIsTextBigger}
                className={`h-6 w-12 ${isTextBigger ? 'h-8 w-16' : ''}`}
              />
            </div>
            <div className="flex items-center justify-between">
              <span className={`text-base font-medium ${isTextBigger ? 'text-xl' : ''}`}>Make button bigger</span>
              <Switch
                checked={isButtonBigger}
                onCheckedChange={setIsButtonBigger}
                className={`h-10 w-16 ${isButtonBigger ? 'h-12 w-24' : ''}`}
              />
            </div>
          </div>
        </>
      )}
    </Card>
  )
}