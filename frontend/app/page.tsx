export const dynamic = 'force-dynamic'

import HeroSection from "@/components/landing/Hero"
import StatsSection from "@/components/landing/Stats"
import FeaturesSection from "@/components/landing/Features"
import PopularServicesSection from "@/components/landing/PopularServices"
import HowItWorksSection from "@/components/landing/Explain"
import UseCasesSection from "@/components/landing/UseCases"
import CTASection from "@/components/landing/CTA"
import { API_URL } from "@/lib/config"

async function getStats() {
  try {
    const [services, actions, reactions, applets] = await Promise.all([
      fetch(`${API_URL}/services`, { cache: 'no-store' }).then(res => res.json()),
      fetch(`${API_URL}/actions`, { cache: 'no-store' }).then(res => res.json()),
      fetch(`${API_URL}/reactions`, { cache: 'no-store' }).then(res => res.json()),
      fetch(`${API_URL}/applets`, { cache: 'no-store' }).then(res => res.json()),
    ])

    return {
      servicesCount: Array.isArray(services) ? services.length : 0,
      actionsCount: Array.isArray(actions) ? actions.length : 0,
      reactionsCount: Array.isArray(reactions) ? reactions.length : 0,
      appletsCount: Array.isArray(applets) ? applets.length : 0,
    }
  } catch (error) {
    console.error('Error fetching stats:', error)
    return {
      servicesCount: 0,
      actionsCount: 0,
      reactionsCount: 0,
      appletsCount: 0,
    }
  }
}

async function getPopularServices() {
  try {
    const services = await fetch(`${API_URL}/services`, { cache: 'no-store' }).then(res => res.json())
    if (!Array.isArray(services)) return []
    return services.slice(0, 6)
  } catch (error) {
    console.error('Error fetching services:', error)
    return []
  }
}

export default async function Home() {
  const [stats, popularServices] = await Promise.all([
    getStats(),
    getPopularServices()
  ])

  return (
    <main className="flex flex-col min-h-screen font-mono">
      <HeroSection />
      <StatsSection stats={stats} />
      <FeaturesSection />
      <PopularServicesSection services={popularServices} />
      <HowItWorksSection />
      <UseCasesSection />
      <CTASection />
    </main>
  )
}