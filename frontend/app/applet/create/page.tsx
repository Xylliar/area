import { Suspense } from 'react'
import { getActions, getReactions } from '@/lib/api'
import AppletAutomationClient from './AppletAutomationClient'

export default async function AppletAutomationPage() {
  let actions = []
  let reactions = []

  try {
    const [actionsData, reactionsData] = await Promise.all([
      getActions(),
      getReactions()
    ])
    actions = actionsData || []
    reactions = reactionsData || []
  } catch (error) {
    console.error('Error fetching data:', error)
  }

  const hasValidData = Array.isArray(actions) &&
                      Array.isArray(reactions) &&
                      actions.length > 0 &&
                      reactions.length > 0

  return (
    <Suspense fallback={<div className="text-base">Loading...</div>}>
      {hasValidData ? (
        <AppletAutomationClient
          initialActions={actions}
          initialReactions={reactions}
        />
      ) : (
        <div className="text-base">
          Error: Unable to load actions and reactions. Please try again later.
        </div>
      )}
    </Suspense>
  )
}
