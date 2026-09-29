import { fetchApplets } from "@/lib/api"
import { Applet } from "@/lib/types"
import AppletPageClient from "@/components/applet/AppletPageClient"

export default async function AppletPage() {
  let applets: Applet[] = []
  let errorMessage: string | null = null

  try {
    const data = await fetchApplets()
    if (Array.isArray(data)) {
      if (data.length === 0) {
        errorMessage = 'No applets found'
      } else {
        applets = data
      }
    } else {
      errorMessage = 'Invalid data format'
    }
  } catch (error) {
    console.error('Fetch error:', error)
    errorMessage = 'Failed to fetch applets'
  }

  return <AppletPageClient initialApplets={applets} initialErrorMessage={errorMessage} />
}