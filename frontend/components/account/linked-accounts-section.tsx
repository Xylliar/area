'use client'

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { useToast } from "@/hooks/use-toast"
import { unlinkService, getLinkURL } from "@/lib/api"
import { ServiceAccount } from "@/lib/types"
import { Card } from "@/components/ui/card"
import { useGlobal } from "@/components/GlobalContext"

export function LinkedAccountsSection({ serviceAccounts }: { serviceAccounts: ServiceAccount[] }) {
  const [accounts, setAccounts] = useState(serviceAccounts)
  const { toast } = useToast()
  const { isButtonBigger, isTextBigger } = useGlobal()

  const handleServiceAction = async (serviceName: string, action: 'link' | 'unlink') => {
    try {
      if (action === 'link') {
        const linkURL = await getLinkURL(serviceName.toLowerCase())
        window.open(linkURL, '_blank')
      } else {
        await unlinkService(serviceName.toLowerCase())
        setAccounts(prevAccounts =>
          prevAccounts.map(account =>
            account.name === serviceName ? { ...account, isLinked: false } : account
          )
        )
      }
      toast({
        title: "Success",
        description: `${serviceName} account ${action === 'link' ? 'linked' : 'unlinked'} successfully.`,
        duration: 3000,
      })
    } catch (error) {
      console.error(`Error ${action}ing ${serviceName} account:`, error)
      toast({
        title: "Error",
        description: `Failed to ${action} ${serviceName} account.`,
        duration: 5000,
      })
    }
  }

  return (
    <Card className="bg-white shadow-none rounded-lg p-6 mb-8">
      <h2 className={`text-2xl font-semibold mb-4 ${isTextBigger ? 'text-3xl' : ''}`}>Linked Accounts</h2>
      <div className="space-y-4">
        {accounts.map((service) => (
          <Card key={service.name} className="flex items-center justify-between p-4 border rounded-lg shadow-none">
            <div>
              <h3 className={`text-lg font-semibold ${isTextBigger ? 'text-xl' : ''}`}>{service.name}</h3>
              <p className={`text-sm ${isTextBigger ? 'text-base' : ''} ${service.isLinked ? 'text-green-600' : 'text-red-600'}`}>
                {service.isLinked ? 'Linked' : 'Not Linked'}
              </p>
            </div>
            <Button
              onClick={() => handleServiceAction(service.name, service.isLinked ? 'unlink' : 'link')}
              variant={service.isLinked ? "destructive" : "default"}
              className={isButtonBigger ? 'text-lg py-4 px-6' : undefined}
            >
              {service.isLinked ? 'Unlink' : 'Link'}
            </Button>
          </Card>
        ))}
      </div>
    </Card>
  )
}