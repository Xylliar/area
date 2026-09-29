import { fetchUser, fetchApplets, fetchLinkStatus } from "@/lib/api"
import { PersonalInfoSection } from "@/components/account/personal-info-section"
import { LinkedAccountsSection } from "@/components/account/linked-accounts-section"

const services = ["Google", "GitHub", "Discord", "Spotify", "Twitch"]

export default async function AccountSettings() {
  const [userData, serviceData] = await Promise.all([
    fetchUser(),
    Promise.all(services.map(service =>
      fetchLinkStatus(service.toLowerCase())
    )),
    fetchApplets()
  ])

  const serviceAccounts = serviceData.map((isLinked, index) => ({
    name: services[index],
    isLinked
  }))

  return (
    <div className="container mx-auto p-4 max-w-4xl mt-16">
      <h1 className="text-3xl font-bold mb-6 text-center">Account Settings</h1>
      <PersonalInfoSection userDetails={userData} />
      <LinkedAccountsSection serviceAccounts={serviceAccounts} />
    </div>
  )
}