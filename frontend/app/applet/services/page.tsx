import ServiceHeader from "@/components/services/header"
import ActionReactionList from "@/components/services/aReaList"
import { fetchService, fetchServiceActions, fetchServiceReactions } from "@/lib/api"

type Props = {
  searchParams: { serviceid?: string }
}

export default async function ServicePreviewPage({ searchParams }: Props) {
  const serviceId = searchParams.serviceid

  if (!serviceId) {
    return <div className="flex justify-center items-center h-screen">Service ID is required</div>
  }

  const [service, actions, reactions] = await Promise.all([
    fetchService(serviceId),
    fetchServiceActions(serviceId),
    fetchServiceReactions(serviceId),
  ])

  if (!service) {
    return <div className="flex justify-center items-center h-screen">Service not found</div>
  }

  return (
    <div className="flex flex-col min-h-screen bg-background mt-24">
      <ServiceHeader service={service} />
      <main className="flex-1 p-6 max-w-7xl mx-auto w-full mt-6">
        <ActionReactionList items={actions} title="Actions" type="actions" serviceColor={service.color} serviceid={serviceId} />
        <ActionReactionList items={reactions} title="Reactions" type="reactions" serviceColor={service.color} serviceid={serviceId} />
      </main>
    </div>
  )
}